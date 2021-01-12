#!/usr/bin/env bash

function usage() {
    script_name=$(basename $0)

    cat <<EOF

usage: ${script_name} json_top_level_directory markdown_top_level_directory

example:

    # Generate Hugo content/guides/ *.md files from sample set #2 JSON files repo
    ./${script_name} ~/dlts-finding-aids-json-generated-from-ead-sample-set-2/json/ ~/dlts-findingaids-hugo/content/guides/

EOF
}

if [ $# -lt 2 ]
then
    usage
    exit 1
fi

JSON_TOP_LEVEL_DIRECTORY=$1
MARKDOWN_TOP_LEVEL_DIRECTORY=$2

if [ ! -d $JSON_TOP_LEVEL_DIRECTORY ]
then
    echo >&2 "${JSON_TOP_LEVEL_DIRECTORY} is not a valid JSON files top level directory."
    usage
    exit 1
fi

if [ ! -e $MARKDOWN_TOP_LEVEL_DIRECTORY ]
then
    mkdir -p $MARKDOWN_TOP_LEVEL_DIRECTORY
    if [ $? -ne 0 ]
    then
        echo >&2 "Error creating $MARKDOWN_TOP_LEVEL_DIRECTORY."
        exit 1
    fi
fi

for d in $( find $JSON_TOP_LEVEL_DIRECTORY -maxdepth 1 -mindepth 1 -type d )
do
    repository=${d#"$JSON_TOP_LEVEL_DIRECTORY/"}
    mkdir -p $MARKDOWN_TOP_LEVEL_DIRECTORY/$repository

    for f in $( find $d -name *.json )
    do
        ead_id=$( basename $f .json )
        markdown_file="$ead_id.md"
        cat << EOF > $MARKDOWN_TOP_LEVEL_DIRECTORY/$repository/$markdown_file
{
    "repoidentifier": "$repository",
    "identifier": "$ead_id"
}
EOF
    done
done
