#!/bin/bash

set -euo pipefail

# if [[ $# -lt 1 ]]; then
    # echo "Usage: $0 <instance-list>"
    # echo "  instance-list: file with one benchmark path per line"
    # exit 1
# fi

INSTANCE_LIST="$1"
BASE_URL="http://benchmark-database.de/file"

missing=0
downloaded=0
failed=0

while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue

    filepath="$line"
    dir="$(dirname "$filepath")"
    filename="$(basename "$filepath")"

    if [[ -f "$filepath" ]]; then
        printf 'exists:  %s\n' "$filepath"
        continue
    fi

    hash="${filename%%-*}"
    url="$BASE_URL/$hash"
    missing=$((missing + 1))

    mkdir -p "$dir"
    printf 'missing: %s -> downloading %s\n' "$filepath" "$url"
    if (cd "$dir" && wget -q --content-disposition "$url"); then
        printf 'ok:      %s\n' "$filepath"
        downloaded=$((downloaded + 1))
    else
        printf 'FAILED:  %s\n' "$filepath" >&2
        failed=$((failed + 1))
    fi
done < "$INSTANCE_LIST"

echo
echo "Done. missing=$missing downloaded=$downloaded failed=$failed"
