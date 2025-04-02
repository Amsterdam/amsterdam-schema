#!/bin/bash
declare -a changed_paths

added_tables=$(git diff --name-only --diff-filter=A origin/master..origin/$1  -- 'datasets/**/v*.json')
modified_tables=$(git diff --name-only --diff-filter=M origin/master..origin/$1  -- 'datasets/**/v*.json')

# for added tables, we have to find a potential previous version
# that may or may not exist
for table_path in $added_tables
do
    folder_name="$(dirname $table_path)"
    file_name="$(basename $table_path)"
    previous_name="$folder_name/previous-$file_name"
    semver=(${file_name//./ })
    major=${semver[0]}
    minor=${semver[1]}
    patch=${semver[2]}
    previous_patch="$(ls $folder_name | grep "$major.$minor.[^0-$patch]" | grep -v "$(basename $table_path)" | tail -n 1)"
    echo $previous_patch
    if [[ $previous_patch ]]; then
        git show origin/master:$folder_name/$previous_patch > $previous_name
        echo "created \"previous-$file_name\" from master's \"$previous_patch\" for \"$table_path\""
        changed_paths+=("$table_path")
        continue
    fi
    previous_minor="$(ls $folder_name | grep "$major.[0-$minor]" | grep -v "$(basename $table_path)" | tail -n 1)"
    echo $previous_minor
    if [[ $previous_minor ]]; then
        git show origin/master:$folder_name/$previous_minor > $previous_name
        echo "created \"previous-$file_name\" from master's \"$previous_minor\" for \"$table_path\""
        changed_paths+=("$table_path")
    fi
done

# for modified tables, we get the previous version from master
for table_path in $modified_tables
do
    file_name="$(basename $table_path)"
    previous_name="$(dirname $table_path)/previous-$file_name"
    git show origin/master:$table_path > $previous_name
    echo "created \"previous-$file_name\" for \"$table_path\""
    changed_paths+=("$table_path")
done
echo "${changed_paths[*]}"
