#!/usr/bin/env bash
set -euo pipefail

# Ensure data folder exists
mkdir -p data

echo "[1/2] Downloading Kaggle dataset archive to data/ ..."
kaggle datasets download -d jpmiller/healthcare -p data/ -w

ZIPFILE="$(ls -1t data/*.zip | head -n1)"
if [ -z "${ZIPFILE}" ]; then
  echo "Dataset zip not found in data/. Exiting."
  exit 1
fi

echo "[2/2] Unzipping ${ZIPFILE} into data/ ..."
unzip -o "${ZIPFILE}" -d data/

echo "Done. You should now have hospitals.csv and hospital_prices.csv under data/"