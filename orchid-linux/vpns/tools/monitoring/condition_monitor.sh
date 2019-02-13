#!/bin/bash

email_recipients=( "cort.tompkins@ipconfigure.com" )
email_subject="Subject"
email_body="Dear friend,

Something went wrong on this server."

mailgun_key="key-72933ea4e4fbe17abc8c57dce8e3a457"

# If this evaluates TRUE, an email will be sent!
test_condition()
{
    true
}

usage()
{
    echo "$0 [TEST_INTERVAL DELAY_INTERVAL]"
    echo 
    echo "Send an email if a specified test condition fails (edit this script to set "
    echo "the test condition."
    echo 
    echo "    TEST_INTERVAL   If specified, check the condition on this interval.  This"
    echo "                    is a parameter for sleep (e.g., \"60s\")."
    echo "    DELAY_INTERVAL  After an email has been sent, delay this interval before"
    echo "                    checking the condition again.  This is a parameter for "
    echo "                    sleep (e.g., \"1h\")."
    echo 
    echo "    If no parameters are specified, the test runs once and quits.  This mode"
    echo "    of operation is designed for use in a cronjob."
    echo
}

if [[ $# -eq 1 || $# -gt 2 ]]; then
    usage
    exit
fi

test_interval="$1"
delay_interval="$2"

send_email()
{
    body_file=$( mktemp )
    echo $email_body > $body_file

    recipient_list=""
    for recipient in "${email_recipients[@]}"; do
        recipient_list+=" -F to=\"${recipient}\" "
    done


    # Note on syntax for the -F (form field) cURL option: if you set a field
    # to "@filename" cURL will attach the file as a MIME attachment; if you
    # set a field to "<filename", cURL will attach the contents of the file as
    # a plain string.  The latter option is important here, but not well documented.
    curl_cmd="curl --connect-timeout 10 --user \"api:${mailgun_key}\" \
        https://api.mailgun.net/v3/mg.ipconfigure.com/messages \
        -F from=\"IPConfigure Condition Monitor <noreply@mg.ipconfigure.com>\" \
        ${recipient_list} \
        -F subject=\"IPConfigure Condition Monitor: ${email_subject}\" \
        -F text=\"<${body_file}\""
    
    eval $curl_cmd
    rm -f "$body_file"

}

while $( true ); do
    if test_condition; then
        send_email
        if [[ -z $delay_interval ]]; then
            exit
        else
            sleep "$delay_interval"
        fi
    fi

    if [[ -z $test_interval ]]; then
        exit
    else
        sleep "$test_interval"
    fi
done
