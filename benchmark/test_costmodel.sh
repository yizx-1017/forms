#!/bin/bash

declare -a RUN_OPTIONS=(1 2 3)
declare -a ROWS_OPTIONS=(2000 4000 6000 8000 10000)
declare FILENAME='weather_10M.csv'
declare CORES=16

for ROWS in "${ROWS_OPTIONS[@]}"
  do
  FORMULA_STR="=IRR(E\$1:E1)"
	for RUN in "${RUN_OPTIONS[@]}"
  do
    FILE_DIR="results/TEST-COSTMODEL/SIMPLE/${ROWS}ROWS/RUN${RUN}"
    mkdir -p $FILE_DIR
    rm -f $FILE_DIR/*
    timeout 5m python3 test_driver.py \
              --filename "$FILENAME" \
              --formula_str "$FORMULA_STR" \
              --cores "$CORES" \
              --cost_model "simple" \
              --row_num "$ROWS" \
              --output_path "$FILE_DIR" &> $FILE_DIR/run.log
    echo "finished $FILE_DIR"

    FILE_DIR="results/TEST-COSTMODEL/LOAD-BALANCE/${ROWS}ROWS/RUN${RUN}"
    mkdir -p $FILE_DIR
    rm -f $FILE_DIR/*
    timeout 5m python3 test_driver.py \
              --filename "$FILENAME" \
              --formula_str "$FORMULA_STR" \
              --cores "$CORES" \
              --row_num "$ROWS" \
              --output_path "$FILE_DIR" &> $FILE_DIR/run.log
    echo "finished $FILE_DIR"
  done
done

