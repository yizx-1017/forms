#!/bin/bash

declare -a RUN_OPTIONS=(1 2 3)
declare -a ROWS_OPTIONS=(2000 4000 6000 8000 10000)
declare -a EXECUTORS=("df_pandas_executor" "df_formulas_executor")
declare FILENAME='weather.csv'
declare FORMULA=formula_in_all_types.csv
declare CORES=12

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
        FILE_DIR="results/TEST-ROWS-1CORE/${n}/${EXECUTOR}/${ROWS}ROWS/RUN${RUN}"
        mkdir -p $FILE_DIR
        rm -f $FILE_DIR/*
        if [ $n == 7 ] || [ $n == 8 ]
        then
          if [ $EXECUTOR == "df_formulas_executor" ]
          then
              timeout 5m python3 test_driver.py \
              --filename "$FILENAME" \
              --formula_str "$FORMULA_STR" \
              --function_executor "$EXECUTOR" \
              --cores "$CORES" \
              --logical_rewriting \
              --physical_opt \
              --row_num "$ROWS" \
              --output_path "$FILE_DIR" &> $FILE_DIR/run.log
          else
            timeout 5m python3 test_driver.py \
                --filename "$FILENAME" \
                --formula_str "$FORMULA_STR" \
                --cores "$CORES" \
                --function_executor "$EXECUTOR" \
                --row_num "$ROWS" \
                --enable_sumif_opt \
                --output_path "$FILE_DIR" &> $FILE_DIR/run.log
          fi
        else
          if [ $EXECUTOR == "df_formulas_executor" ]
          then
              timeout 5m python3 test_driver.py \
                --filename "$FILENAME" \
                --formula_str "$FORMULA_STR" \
                --cores "$CORES" \
                --function_executor "$EXECUTOR" \
                --logical_rewriting \
                --physical_opt \
                --row_num "$ROWS" \
                --output_path "$FILE_DIR" &> $FILE_DIR/run.log
          else
            timeout 5m python3 test_driver.py \
                  --filename "$FILENAME" \
                  --formula_str "$FORMULA_STR" \
                  --cores "$CORES" \
                  --function_executor "$EXECUTOR" \
                  --row_num "$ROWS" \
                  --output_path "$FILE_DIR" &> $FILE_DIR/run.log
          fi
        fi
        echo "finished $FILE_DIR"
      done
    done
  done
done

