#!/bin/bash
set -e;

# Directory where the script is placed.
source "../utils/functions_check.inc.sh" || exit 1;

overwrite=false;
verbose=false
wspace="@";
help_message="
Usage: ${0##*/} [options]

Options:
  --overwrite  : (type = boolean, default = $overwrite)
                 Overwrite previously created files.
  --wspace     : (type = string, default = \"$wspace\")
                 Use this symbol to represent the whitespace character.
  --verbose    : (type = boolean, default = $verbose)
                 Print when skipping.
";
source "../utils/parse_options.inc.sh" || exit 1;

check_all_programs sed sort tr || exit 1;

mkdir -p "data/lang/all"

all_ch="data/lang/all/char.txt"

num_lines_original=$(find "data/original" -name "*.txt" | wc -l)

num_lines_computed=$(cat "$all_ch" | wc -l || 0)

[[ "$overwrite" = false && -s "$all_ch" && "$num_lines_original" -eq "$num_lines_computed" ]] ||
for filename in data/original/*.txt; do
  echo "$(basename $filename .jpg.txt)" "$(cat $filename | tr " " "@wspace" | sed 's/\(.\)/\1 /g' | sed 's/\s$//')"
done | sort -k1 > "$all_ch";

out_dir="data/lang/split"
mkdir -p "$out_dir"
for split in tr te va; do
  split_path="data/splits/$split.lst"
  out_path="$out_dir/$split.txt"
  [[ "$overwrite" = false && -s "$out_dir/$split.txt" &&
  ( ! "$out_path" -ot  "$split_path")
  ]] && ([[ "$verbose" = true ]] && echo "skip") ||
    join -1 1 "$split_path" "$all_ch" > "$out_path" ||
      { echo "ERROR: Creating file \"$odir/$p.txt\"!" >&2 && exit 1; }
done;
