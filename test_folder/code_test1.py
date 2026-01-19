# code_test1.py
import pandas as pd
import numpy as np

def get_dataframe():
    """
    Returns a sample Pandas DataFrame
    """
    data = np.array([[10, 20, 30],
                     [40, 50, 60],
                     [70, 80, 90]])
    df = pd.DataFrame(data, columns=['X', 'Y', 'Z'])
    return df
