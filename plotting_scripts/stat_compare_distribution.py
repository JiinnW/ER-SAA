import pandas as pd
from scipy.stats import kstest
import os

# Base directory
baseDirName = "../output/"

def read_and_combine(start_idx, end_idx, method_name):
    data = []
    for i in range(start_idx, end_idx + 1):
        file_path = os.path.join(
            baseDirName, f"case1_{method_name}", f"mod_{i}", 
            "deg_1", "rep_1", "ols", "samp_3", f"{method_name}_obj.txt")
        if os.path.exists(file_path):
            with open(file_path, 'r') as file:
                number = float(file.readline().strip())
                data.append(number)
        else:
            print(f"File {file_path} not found, skipping.")
    return data

def compare_distributions(array1,array2):

    if array1 and array2:
        ks_stat, p_value = kstest(array1, array2)
        print(f"KS Statistic: {ks_stat:.4f}")
        print(f"P-value: {p_value:.4f}")
    else:
        print(f"Insufficient data for KS test.")
    return

if __name__ == "__main__":
    # Compare distributions for both columns

    for method in ['ersaa', 'pointpred']:
        print(f"Comparing distributions for {method}:")

        first_100 = read_and_combine(1, 100, method)
        last_100 = read_and_combine(101, 200, method)

        compare_distributions(first_100, last_100)
