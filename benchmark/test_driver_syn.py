import argparse
from datetime import datetime
import json
import os
import time

import pandas as pd
import forms as fs
from forms.core.globals import forms_global

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test Driver for FormS")
    parser.add_argument("--filename", type=str, required=True)
    parser.add_argument("--formula_str", type=str, required=True)
    parser.add_argument("--function_executor", type=str, default="df_pandas_executor")
    parser.add_argument("--cost_model", type=str, default="loadbalance")
    parser.add_argument("--enable_sumif_opt", action="store_true")
    parser.add_argument("--along_row_first", type=bool, default=False)
    parser.add_argument("--row_num", type=int)
    parser.add_argument("--output_path", type=str, required=True)

    args = parser.parse_args()
    filename = args.filename
    formula_str = args.formula_str.strip()
    dir = os.path.dirname(os.path.abspath(__file__))
    filepath = os.path.join(dir, "spreadsheets")
    filepath = os.path.join(filepath, filename)
    df = pd.read_csv(filepath)
    if args.row_num:
        df = df.iloc[0 : args.row_num]
    df.iloc[:, 4] = [20 * (i + 1) for i in range(len(df))]
    fs.config(
        cores=1,
        scheduler="simple",
        enable_logical_rewriting=False,
        enable_physical_opt=False,
        function_executor=args.function_executor,
        cost_model=args.cost_model,
        enable_communication_opt=False,
        enable_sumif_opt=args.enable_sumif_opt,
        along_row_first=args.along_row_first,
        partition_shape=(256, 1),
        synchronous=True,
    )
    time_start = time.time()
    result = fs.compute_formula(df, formula_str)
    metrics = forms_global.get_metrics()
    time_end = time.time()
    config = {
        "timestamp": str(datetime.now()),
        "cores": 1,
        "scheduler": "simple",
        "enable_logical_rewriting": False,
        "enable_physical_opt": False,
        "function_executor": args.function_executor,
        "cost_model": args.cost_model,
        "enable_communication_opt": False,
        "enable_sumif_opt": args.enable_sumif_opt,
        "along_row_first": args.along_row_first,
        "partition_shape": (256, 1),
        "row_num": df.shape[0],
        "filename": args.filename,
        "formula_str": args.formula_str,
        "distributing_data_time_in_ms": metrics["distributing_data_time"] * 1000,
        "execution_time_in_ms": metrics["computation_time"] * 1000,
        "planning_time_in_ms": metrics["planning_time"] * 1000,
        "timecost_in_ms": (time_end - time_start) * 1000,
    }
    output_path = os.path.join(dir, args.output_path)
    # result.to_csv(os.path.join(output_path, "result.csv"))
    config_path = os.path.join(output_path, "config.json")
    with open(config_path, "w") as outfile:
        outfile.write(json.dumps(config, indent=4))
