#!/bin/bash

declare -a RUN_OPTIONS=(1 2 3)
declare -a ROWS_OPTIONS=(10000000)
declare -a EXECUTORS=("df_pandas_executor")
declare FILENAME='weather_10M.csv'
declare FORMULA=formula_in_all_types.csv
declare CORES=1

n=0
sed 1d $FORMULA | while IFS="," read -r FORMULA_STR
do
  echo $FORMULA_STR
  n=$(($n+1))
	for RUN in "${RUN_OPTIONS[@]}"
  do
    for ROWS in "${ROWS_OPTIONS[@]}"
    do
      for EXECUTOR in "${EXECUTORS[@]}"
      do
        FILE_DIR="results/TEST-ROWS-NODASK/${n}/${EXECUTOR}/${ROWS}ROWS/RUN${RUN}"
        mkdir -p $FILE_DIR
        rm -f $FILE_DIR/*
        if [ $n == 7 ] || [ $n == 8 ]
        then
          timeout 5m python3 test_driver_syn.py \
                --filename "$FILENAME" \
                --formula_str "$FORMULA_STR" \
                --function_executor "$EXECUTOR" \
                --row_num "$ROWS" \
                --enable_sumif_opt \
                --output_path "$FILE_DIR" &> $FILE_DIR/run.log
        else
          timeout 5m python3 test_driver_syn.py \
                  --filename "$FILENAME" \
                  --formula_str "$FORMULA_STR" \
                  --function_executor "$EXECUTOR" \
                  --row_num "$ROWS" \
                  --output_path "$FILE_DIR" &> $FILE_DIR/run.log
        fi
        echo "finished $FILE_DIR"
      done
    done
  done
done


