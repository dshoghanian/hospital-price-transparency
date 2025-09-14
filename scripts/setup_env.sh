#!/usr/bin/env bash
set -euo pipefail

echo "Creating Conda environment (healthcare_env) ..."
conda env create -f environment.yml || conda env update -f environment.yml
echo "Activating environment ..."
# shellcheck disable=SC1091
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate healthcare_env
python -m ipykernel install --user --name=healthcare_env --display-name "Python (healthcare_env)"
echo "Done."