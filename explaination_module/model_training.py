import pathlib
import joblib
from typing import Iterable, Tuple

import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler


EXCEL_PATH = pathlib.Path("C:\\Users\\intsys\\Desktop\\XAI-Evaluation\\Experiments\\ethanol-simulator\\ai_simulation\\Process_data.xlsx")  # <- update
SHEETS = ["Sheet1", "Sheet3", "Sheet4", "Sheet5", "Sheet7", "Sheet8", "Sheet10"]
NORMAL_SAMPLES = 15  # first 15 rows are normal
LABEL_COL = "fault_label"
PROCESS_VARIABLE_COLUMNS = [
    "F101_FeedFlow_Lhr",
    "F102_CoolantFlow_Lhr",
    "T101_CoolantTemp_C",
    "T102_JacketTemp_C",
    "F105_DistillFlow_Lhr",
    "T106_Tray3Temp_C",
    "T105_Tray5Temp_C",
    "T104_Tray8Temp_C",
    "T103_CSTRTemp_C",
    "C101_EthanolConc_molL",
    "L101_CSTRLevel_m",
]
RANDOM_SEED = 42
TEST_SIZE = 0.2
ARTIFACT_DIR = pathlib.Path(__file__).resolve().parent / "model_artifacts"
MODEL_PATH = ARTIFACT_DIR / "fault_fnn.keras"
SCALER_PATH = ARTIFACT_DIR / "scaler.joblib"
LABEL_MAP_PATH = ARTIFACT_DIR / "label_map.joblib"
BASELINE_PATH = ARTIFACT_DIR / "baseline.joblib"


def _sheet_label_value(sheet_id) -> int:
    if isinstance(sheet_id, str):
        digits = "".join(ch for ch in sheet_id if ch.isdigit())
        if digits:
            return int(digits)
        raise ValueError(f"Sheet name '{sheet_id}' has no numeric label")
    return int(sheet_id)


def load_and_label_sheets(
    excel_path: pathlib.Path,
    sheets: Iterable,
    normal_samples: int = NORMAL_SAMPLES,
) -> pd.DataFrame:
    frames = []
    print(f"Loading Excel file: {excel_path}")
    print(f"Sheets to load: {list(sheets)}")
    print(f"Normal samples per sheet: {normal_samples}")
    for sheet_id in sheets:
        label_value = _sheet_label_value(sheet_id)
        print(f"\nReading sheet: {sheet_id}")
        df = pd.read_excel(excel_path, sheet_name=sheet_id)
        df = df.reset_index(drop=True)
        print(f"dtaframe shape: {df.shape} from sheet {sheet_id}")
        print(df.head(5))
        print(f"Rows read: {len(df)}")

        missing_cols = [c for c in PROCESS_VARIABLE_COLUMNS if c not in df.columns]
        if missing_cols:
            print(f"Missing expected columns in sheet {sheet_id}: {missing_cols}")

        labels = np.zeros(len(df), dtype=int)
        if len(df) > normal_samples:
            labels[normal_samples:] = label_value
        df[LABEL_COL] = labels
        df["fault_case"] = label_value
        unique, counts = np.unique(labels, return_counts=True)
        label_dist = dict(zip(unique.tolist(), counts.tolist()))
        print(f"Label distribution for sheet {sheet_id}: {label_dist}")
        frames.append(df)

    combined = pd.concat(frames, ignore_index=True)
    print(f"\nTotal rows after concatenation: {len(combined)}")
    return combined


def preprocess_and_split(
    df: pd.DataFrame,
    label_col: str = LABEL_COL,
    feature_cols: Iterable[str] = PROCESS_VARIABLE_COLUMNS,
    test_size: float = TEST_SIZE,
    random_seed: int = RANDOM_SEED,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, StandardScaler]:
    print("\nPreprocessing...")
    print(f"Initial rows: {len(df)}")
    missing_feature_cols = [c for c in feature_cols if c not in df.columns]
    if missing_feature_cols:
        print(f"Missing feature columns in combined data: {missing_feature_cols}")

    before_drop = len(df)
    df = df.dropna(axis=0).reset_index(drop=True)
    after_drop = len(df)
    print(f"Rows after dropna: {after_drop} (dropped {before_drop - after_drop})")

    X = df.loc[:, list(feature_cols)]
    y = df[label_col].to_numpy()

    print(f"Feature matrix shape: {X.shape}")
    unique, counts = np.unique(y, return_counts=True)
    label_dist = dict(zip(unique.tolist(), counts.tolist()))
    print(f"Overall label distribution: {label_dist}")

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_seed, shuffle=True
    )
    print(f"Train split: X={X_train.shape}, y={y_train.shape}")
    print(f"Test split: X={X_test.shape}, y={y_test.shape}")

    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    print("Scaling complete (StandardScaler).")

    return X_train_scaled, X_test_scaled, y_train, y_test, scaler


def main() -> None:
    print("Starting data pipeline...")
    df = load_and_label_sheets(EXCEL_PATH, SHEETS, NORMAL_SAMPLES)
    X_train, X_test, y_train, y_test, scaler = preprocess_and_split(df)

    print("Train shape:", X_train.shape, y_train.shape)
    print("Test shape:", X_test.shape, y_test.shape)

    print("\nTraining FNN (TensorFlow Keras)...")
    label_values = np.unique(np.concatenate([y_train, y_test]))
    label_to_index = {label: idx for idx, label in enumerate(label_values)}
    print(f"Label mapping: {label_to_index}")

    y_train_idx = np.array([label_to_index[v] for v in y_train], dtype=int)
    y_test_idx = np.array([label_to_index[v] for v in y_test], dtype=int)

    num_classes = len(label_values)
    y_train_oh = tf.keras.utils.to_categorical(y_train_idx, num_classes=num_classes)
    y_test_oh = tf.keras.utils.to_categorical(y_test_idx, num_classes=num_classes)

    tf.random.set_seed(RANDOM_SEED)

    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(X_train.shape[1],)),
            tf.keras.layers.Dense(64, activation="relu"),
            tf.keras.layers.Dense(32, activation="relu"),
            tf.keras.layers.Dense(num_classes, activation="softmax"),
        ]
    )

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )

    history = model.fit(
        X_train,
        y_train_oh,
        validation_split=0.2,
        epochs=50,
        batch_size=32,
        verbose=1,
    )

    y_pred_probs = model.predict(X_test)
    y_pred = np.argmax(y_pred_probs, axis=1)

    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test_idx, y_pred))

    print("\nClassification Report (Precision, Recall, F1):")
    print(classification_report(y_test_idx, y_pred, digits=4))

    # Compute baseline as mean of normal class (label=0) from scaled training data
    normal_mask = y_train == 0
    if np.any(normal_mask):
        baseline = X_train[normal_mask].mean(axis=0)
        print(f"\nComputed baseline from {normal_mask.sum()} normal samples")
        print(f"Baseline shape: {baseline.shape}")
    else:
        print("\nWarning: No normal samples found, using zeros as baseline")
        baseline = np.zeros(X_train.shape[1])

    ARTIFACT_DIR.mkdir(parents=True, exist_ok=True)
    model.save(MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)
    joblib.dump(label_to_index, LABEL_MAP_PATH)
    joblib.dump(baseline, BASELINE_PATH)
    print(f"\nSaved model: {MODEL_PATH}")
    print(f"Saved scaler: {SCALER_PATH}")
    print(f"Saved label map: {LABEL_MAP_PATH}")
    print(f"Saved baseline: {BASELINE_PATH}")


if __name__ == "__main__":
    main()
