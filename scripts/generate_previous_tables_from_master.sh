#!/bin/bash
set -e
declare -a changed_paths
echo ""
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
    if [[ $previous_patch ]]; then
        echo "=======$table_path========="
        echo ""
        git show origin/master:$folder_name/$previous_patch > $previous_name
        echo "Comparing to master's \"$previous_patch\":"
        git --no-pager diff --no-index --color $previous_name $table_path || true
        echo ""
        changed_paths+=("$table_path")
        continue
    fi
    previous_minor="$(ls $folder_name | grep "$major.[0-$minor]" | grep -v "$(basename $table_path)" | tail -n 1)"
    if [[ $previous_minor ]]; then
        echo "=======$table_path========="
        echo ""
        git show origin/master:$folder_name/$previous_minor > $previous_name
        echo "Comparing to master's \"$previous_minor\":"
        git --no-pager diff --no-index --color $previous_name $table_path || true
        echo ""
        changed_paths+=("$table_path")
        continue
    fi
    previous_major="$(ls $folder_name | grep "v[0-${major:1}]" | grep -v "$(basename $table_path)" | tail -n 1)"
    if [[ $previous_major ]]; then
        # this isn't  breaking, so no need to add to changed_paths, but helpful to see the diff.
        echo "=======$table_path========="
        echo ""
        git show origin/master:$folder_name/$previous_major > $previous_name
        echo "Comparing to master's \"$previous_major\":"
        git --no-pager diff --no-index --color $previous_name $table_path || true
        echo ""
    fi
done

# for modified tables, we get the previous version from master
for table_path in $modified_tables
do
    file_name="$(basename $table_path)"
    previous_name="$(dirname $table_path)/previous-$file_name"
    echo "=======$table_path========="
    echo ""
    git show origin/master:$table_path > $previous_name
    echo "Comparing to master's \"$file_name\":"
    git --no-pager diff --no-index --color $previous_name $table_path || true
    echo ""
    changed_paths+=("$table_path")
done
echo "======================Summary======================"
echo "Added and modified files that need to be validated:"
echo "${changed_paths[*]}"
