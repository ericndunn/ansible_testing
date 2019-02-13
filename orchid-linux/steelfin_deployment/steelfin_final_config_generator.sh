#!/bin/bash

usage() {
    echo "Usage; $0 CSV_FILE TEMPLATE_SCRIPT"
    echo
    echo "Generate SteelFin automatic deployment scripts in the current directory."
    echo "Inputs will be read from CSV_FILE:"
    echo
    echo "- Column 1 maps to @SERIAL@ in TEMPLATE_SCRIPT."
    echo "- Column 2 maps to @ACTIVATION_CODE@ in TEMPLATE_SCRIPT."
    echo "- Column 3 maps to @CUSTOMER_ID@ in TEMPLATE_SCRIPT."
    echo
    echo "NOTE: Column 3 is optional; if it exists TEMPLATE_SCRIPT should apply a VPN"
    echo "      configuration script."
    echo
}

verify_file_exists() {
    file="$1"
    description="$2"

    if [[ ! -f $file ]]; then
        echo "ERROR: Could not find $description \"$file\"."
        echo
        exit 2
    fi
}

csv_file="$1"
template_script="$2"

if [[ $# != 2 ]]; then
    usage
    exit 2
fi

verify_file_exists "$csv_file" "CSV file"
verify_file_exists "$template_script" "template script"

export IFS="
"
for line in $(cat $csv_file); do
    serial=$( cut -d ',' -f 1 <<< "$line")
    activation_code=$( cut -d ',' -f 2 <<< "$line" )
    customer_id=$( cut -d ',' -f 3 <<< "$line" )

    output_dir=""
    if [[ ! -z "$customer_id" ]]; then
        mkdir -p "${customer_id}"/"${serial}"
        output_dir="${customer_id}/${serial}"
    fi

    output_script="${output_dir}/script.sh"
    cp $template_script "$output_script"
    sed -i "s/@SERIAL@/$serial/g" "$output_script"
    sed -i "s/@ACTIVATION_CODE@/$activation_code/g" "$output_script"
    sed -i "s/@CUSTOMER_ID@/$customer_id/g" "$output_script"
done
