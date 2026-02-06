"""
Integrated Gradients implementation for model interpretability.

This module provides a class-based implementation of integrated gradients for
neural network models, enabling attribution analysis to understand feature importance.
"""

import numpy as np
import tensorflow as tf


class IntegratedGradients:
    """
    Integrated Gradients explainer for neural network models.

    This class implements the Integrated Gradients method for computing feature
    attributions, helping explain model predictions by identifying important features.

    Attributes:
        model: The neural network model to explain.
        baseline: Default baseline input for attribution computation.
        m_steps: Number of interpolation steps for path integral.
        batch_size: Batch size for gradient computation.
    """

    def __init__(self, model, baseline=None, m_steps=500, batch_size=32):
        """
        Initialize the IntegratedGradients explainer.

        Args:
            model: The trained neural network model.
            baseline: Default baseline input (optional).
            m_steps: Number of steps for integral approximation (default: 500).
            batch_size: Batch size for gradient computation (default: 32).
        """
        self.model = model
        self.baseline = baseline
        self.m_steps = m_steps
        self.batch_size = batch_size

    def explain(self, sample, target_class_idx, baseline=None, m_steps=None):
        """
        Compute integrated gradients for a single sample.

        Args:
            sample: Input sample to explain.
            target_class_idx: Target class index for attribution.
            baseline: Optional baseline (overrides instance baseline).
            m_steps: Optional number of steps (overrides instance m_steps).

        Returns:
            Tuple of (integrated_gradients, sample_baseline_diff, avg_gradients).
        """
        baseline = baseline if baseline is not None else self.baseline
        m_steps = m_steps if m_steps is not None else self.m_steps

        if baseline is None:
            raise ValueError("Baseline must be provided either at initialization or during explain call")

        alphas = tf.linspace(start=0.0, stop=1.0, num=m_steps + 1)
        alphas = tf.cast(alphas, tf.float64)

        gradient_batches = tf.TensorArray(tf.float64, size=m_steps + 1)

        for alpha in tf.range(0, len(alphas), self.batch_size):
            from_ = alpha
            to = tf.minimum(from_ + self.batch_size, len(alphas))
            alpha_batch = alphas[from_:to]

            interpolated_batch = self._interpolate_samples(
                baseline=baseline,
                sample=sample,
                alphas=alpha_batch
            )

            gradient_batch = self._compute_gradients(
                samples=interpolated_batch,
                target_class_idx=target_class_idx
            )

            gradient_batches = gradient_batches.scatter(
                tf.range(from_, to),
                gradient_batch
            )

        total_gradients = gradient_batches.stack()
        avg_gradients = self._integral_approximation(gradients=total_gradients)
        integrated_gradients = (sample - baseline) * avg_gradients

        return integrated_gradients, (sample - baseline), avg_gradients

    def explain_batch(self, samples, predictions, baseline=None, m_steps=None):
        """
        Compute attributions for multiple samples.

        Args:
            samples: Array of input samples.
            predictions: Array of predicted class indices.
            baseline: Optional baseline (overrides instance baseline).
            m_steps: Optional number of steps (overrides instance m_steps).

        Returns:
            Tuple of (attributions, sample_baseline_diff, avg_gradients) arrays.
        """
        baseline = baseline if baseline is not None else self.baseline
        m_steps = m_steps if m_steps is not None else self.m_steps

        if baseline is None:
            raise ValueError("Baseline must be provided either at initialization or during explain_batch call")

        num_samples = len(samples)
        num_features = len(baseline)

        ig_list = tf.constant([0.0] * num_features, dtype='float64')
        sb_list = tf.constant([0.0] * num_features, dtype='float64')
        ag_list = tf.constant([0.0] * num_features, dtype='float64')

        for i in range(num_samples):
            i_g, sb, ag = self.explain(
                sample=samples[i],
                target_class_idx=predictions[i],
                baseline=baseline,
                m_steps=m_steps
            )

            ig_list = tf.concat([ig_list, i_g], 0)
            sb_list = tf.concat([sb_list, sb], 0)
            ag_list = tf.concat([ag_list, ag], 0)

        ig_array = ig_list.numpy().reshape((num_samples + 1, num_features))
        sb_array = sb_list.numpy().reshape((num_samples + 1, num_features))
        ag_array = ag_list.numpy().reshape((num_samples + 1, num_features))

        return ig_array[1:, :], sb_array[1:, :], ag_array[1:, :]

    def compute_window_attribution(self, attributions, window_size):
        """
        Compute moving window average of attributions.

        Args:
            attributions: Attribution data array (samples x features).
            window_size: Size of the moving window.

        Returns:
            Window-averaged attribution array.
        """
        num_rows, _ = attributions.shape
        window_attri_list = []

        for i in range(num_rows + 1):
            if i < window_size:
                mean_attri = np.mean(attributions[:i, :], axis=0)
            else:
                mean_attri = np.mean(attributions[i - window_size:i, :], axis=0)
            window_attri_list.append(mean_attri)

        window_attri = np.array(window_attri_list)
        return window_attri[1:, :]

    def _interpolate_samples(self, baseline, sample, alphas):
        """
        Generate interpolated samples between baseline and input.

        Args:
            baseline: Baseline input tensor.
            sample: Target input tensor.
            alphas: Interpolation coefficients in range [0, 1].

        Returns:
            Interpolated samples along the path.
        """
        alphas_x = alphas[:, tf.newaxis]
        baseline_x = tf.expand_dims(baseline, axis=0)
        input_x = tf.expand_dims(sample, axis=0)
        delta = input_x - baseline_x
        samples = baseline_x + alphas_x * delta
        return samples

    def _compute_gradients(self, samples, target_class_idx):
        """
        Compute gradients of model output with respect to inputs.

        Args:
            samples: Input samples tensor.
            target_class_idx: Target class index.

        Returns:
            Gradients of the target class probability.
        """
        with tf.GradientTape() as tape:
            tape.watch(samples)
            logits = self.model(samples)
            probs = logits[:, target_class_idx]
        return tape.gradient(probs, samples)

    def _integral_approximation(self, gradients):
        """
        Approximate integral using trapezoidal Riemann sum.

        Args:
            gradients: Gradients computed at interpolated points.

        Returns:
            Integrated gradients approximation.
        """
        grads = (gradients[:-1] + gradients[1:]) / tf.constant(2.0, dtype='float64')
        integrated_gradients = tf.math.reduce_mean(grads, axis=0)
        return integrated_gradients