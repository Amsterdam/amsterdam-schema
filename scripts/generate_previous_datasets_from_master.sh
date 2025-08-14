#!/bin/bash
set -e
declare -a changed_paths
echo ""
modified_datasets=$(git diff --name-only --diff-filter=M origin/master..origin/$1  -- 'datasets/**/dataset.json')

# for modified datasets, we get the previous version from master
for dataset_path in $modified_datasets
do
    file_name="$(basename $dataset_path)"
    previous_name="$(dirname $dataset_path)/previous-$file_name"
    echo "=======$dataset_path========="
    echo ""
    git show origin/master:$dataset_path > $previous_name
    echo "Comparing to master's \"$file_name\":"
    git --no-pager diff --no-index --color $previous_name $dataset_path || true
    echo ""
    changed_paths+=("$dataset_path")
done
echo "======================Summary======================"
echo "Added and modified files that need to be validated:"
echo "${changed_paths[*]}"
