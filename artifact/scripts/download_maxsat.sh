
#!/bin/bash
set -euo pipefail
BASE_DIR="/app/benchmarks/maxsat"
BASE_URL="https://www.cs.helsinki.fi/group/coreo/MSE2024-instances"

mkdir -p "$BASE_DIR"

for name in mse24-anytime-unweighted mse24-anytime-weighted; do
    zipfile="$BASE_DIR/$name.zip"
    url="$BASE_URL/$name.zip"

    echo "Downloading $url ..."
    wget -O "$zipfile" "$url"

    echo "Extracting $zipfile ..."
    unzip -o "$zipfile" -d "$BASE_DIR/$name/"

    echo "Cleaning up $zipfile ..."
    rm -f "$zipfile"

done

echo "Done. Benchmarks saved to $BASE_DIR"

