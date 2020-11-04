#!/bin/bash
set -e;

# Directory where the script is placed.
source "../utils/functions_check.inc.sh" || exit 1;

overwrite=false
val_ratio=0.1;
test_ratio=0.2;
verbose=false
help_message="
Usage: ${0##*/} [options]

Options:
  --overwrite  : (type = boolean, default = $overwrite)
                 Overwrite previously created files.
  --val_ratio  : (type = float, default = $val_ratio)
                 Validation data ratio.
  --test_ratio : (type = float, default = \"$test_ratio\")
                 Test data ratio.
  --verbose    : (type = boolean, default = $verbose)
                 Print when skipping.
";
source "../utils/parse_options.inc.sh" || exit 1;


mkdir -p "data/splits"

tr_path="data/splits/tr.lst"
va_path="data/splits/va.lst"
te_path="data/splits/te.lst"

val_test_ratio=$(awk "BEGIN {print $val_ratio+$test_ratio; exit}")
train_ratio=$(awk "BEGIN {print 1.0-$val_test_ratio; exit}")
test_ratio=$(awk "BEGIN {print $test_ratio/$val_test_ratio; exit}")
val_ratio=$(awk "BEGIN {print $val_ratio/$val_test_ratio; exit}")

awk "BEGIN { if ($train_ratio >= 0) {exit 0} else {exit 1}}" ||
(echo "Validation + Test ratios cannot be bigger than 1." &&
exit 1);

basenames=$(find data/original -name "*.txt" -execdir basename -s '.jpg.txt' {} + | shuf)

num_examples=$(echo "$basenames" | wc -l)
num_train_examples=$(awk "BEGIN {printf \"%.0f\", $train_ratio*$num_examples; exit}")
num_val_test_examples=$(( "$num_examples" - "$num_train_examples"))
num_test_examples=$(awk "BEGIN {printf \"%.0f\", $test_ratio*$num_val_test_examples; exit}")
num_val_examples=$(( "$num_val_test_examples" - "$num_test_examples" ))

[[ "$overwrite" = false &&
  -s "$tr_path" &&  -s "$te_path" && -s "$va_path" &&
  "$num_train_examples" -eq $(wc -l < "$tr_path") &&
  "$num_test_examples" -eq $(wc -l < "$te_path") &&
  "$num_val_examples" -eq $(wc -l < "$va_path")
  ]] && ([[ "$verbose" = true ]] && echo "skip") && exit 0;

train_examples=$(echo "$basenames" | head -n "$num_train_examples")
test_examples=$(echo "$basenames" | head -n $(( "$num_train_examples" + "$num_test_examples" )) | tail -n "$num_test_examples")
val_examples=$(echo "$basenames" | tail -n "$num_val_examples")

echo "$train_examples" | sort > "$tr_path"
echo "$test_examples" | sort > "$te_path"
echo "$val_examples" | sort > "$va_path"




