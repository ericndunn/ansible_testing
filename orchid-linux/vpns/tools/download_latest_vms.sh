#!/bin/bash

script_dir=$( realpath $( dirname "$0" ) )
source ${STEELFIN_SCRIPT_ROOT}/steelfin_common.sh

usage() {
    echo "${0} <product> [<platform>]"
    echo
    echo "Download the latest Orchid Core VMS or Orchid Fusion VMS for Ubuntu 16.04 from"
    echo "download.ipconfigure.com."
    echo
    echo "   product: Specify either \"orchid\" or \"fusion\""
    echo "  platform: Specify \"ubuntu16\" (default), \"ubuntu14\", \"rpi\", \"armv7\","
    echo "            \"rhel7\" or \"windows\"."
    echo
    exit 1
}

die_responsibly() {
    rm -f ${curl_output}
    die_with_error "$@"
}

declare -A orchid_installer
orchid_installer['ubuntu16']="ipc-orchid-x86_64_\${version}-jessie.deb"
orchid_installer['ubuntu14']="ipc-orchid-x86_64_\${version}.deb"
orchid_installer['rpi']="ipc-orchid-armv6l_\${version}-jessie.deb"
orchid_installer['armv7']="ipc-orchid-armv7l_\${version}-jessie.deb"
orchid_installer['rhel7']="ipc-orchid-x86_64_\${version}.rpm"
orchid_installer['windows']="ipc-orchid_\${version}.exe"

declare -A fusion_installer
fusion_installer['ubuntu16']="fusion-x86_64_\${version}-jessie.deb"
fusion_installer['ubuntu14']="fusion-x86_64_\${version}.deb"
fusion_installer['rpi']="fusion-armv6l_\${version}-jessie.deb"
fusion_installer['armv7']="fusion-armv7l_\${version}-jessie.deb"
fusion_installer['rhel7']="fusion-x86_64_\${version}.rpm"
fusion_installer['windows']="fusion-x86_64_\${version}.exe"

# Housekeeping.
( [[ $# -eq 1 ]] || [[ $# -eq 2 ]] ) || usage
curl_output=$(mktemp)
product="$1"
platform="$2"
( [[ $product == "orchid" ]] || [[ $product == "fusion" ]] ) || usage
[[ ! -z $platform ]] || platform="ubuntu16"

# Get latest version number.
code=$( curl -s -o ${curl_output} -w "%{http_code}" http://download.ipconfigure.com/${product}/LATEST )
[[ $code == "200" ]] || die_responsibly "Failed to retrieve LATEST version number.  HTTP response code ${code}."
version=$(cat $curl_output)

# From version number, determine file name to download.
if [[ $product == "fusion" ]]; then
    [[ ${fusion_installer[$platform]+abc} ]] || die_responsibly "Unknown fusion platform \"$platform\"."
    installer="$( eval "echo ${fusion_installer[$platform]}" )"
elif [[ $product == "orchid" ]]; then
    [[ ${orchid_installer[$platform]+abc} ]] || die_responsibly "Unknown orchid platform \"$platform\"."
    installer="$( eval "echo ${orchid_installer[$platform]}" )"
else
    die_responsibly "Unknown product \"$product\"."
fi

# Download the installer file.
code=$( curl -o ${curl_output} -w "%{http_code}" http://download.ipconfigure.com/${product}/${installer} )
[[ $code == "200" ]] || die_responsibly "Failed to retrieve ${installer}.  HTTP response code ${code}."
mv ${curl_output} ${installer}

# Download the installer file checksum.
code=$( curl -s -o ${curl_output} -w "%{http_code}" http://download.ipconfigure.com/${product}/${installer}.md5 )
[[ $code == "200" ]] || die_responsibly "Failed to retrieve ${installer}.md5.  HTTP response code ${code}."
mv ${curl_output} ${installer}.md5

# Verify checksum matches.
if ! md5sum -c ${installer}.md5 ; then
    rm -f ${installer}
    rm -f ${installer}.md5
    die_responsibly "ERROR: Downloaded file did not match MD5 sum from download site."
fi

# Clean yourself up.
rm -f ${installer}.md5
rm -f ${curl_output}
