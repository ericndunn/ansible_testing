#!/bin/bash

usage() {
	echo "Usage: $0 BACKUP|RESTORE"
	echo
	echo "Fudge the current Orchid Core VMS's server's admin password."
	echo
	echo "    BACKUP - Backup the current admin credentials to .orchidpw_backup and"
	echo "             and change the password to 0rc#1d."
	echo
	echo "   RESTORE - Restore the admin credentials from .orchidpw_backup"
	echo
}

on_error() {
	echo "Something went wrong!"
	echo
	exit 1
}

if [[ $# -ne 1 ]]; then
	usage
	exit 1
fi

mode="$1"

if [[ $mode == "BACKUP" ]]; then
	if [[ -f .orchidpw_backup ]]; then
		echo "Error: backup file .orchidpw_backup already exists."
		echo
		exit 1
	fi

	trap on_error ERR
	password=$( sudo /opt/orchid/bin/sqlite3 /var/lib/orchid_server/orchid.sqlite 'SELECT password FROM user WHERE name="admin"' )
	salt=$( sudo /opt/orchid/bin/sqlite3 /var/lib/orchid_server/orchid.sqlite 'SELECT salt FROM user WHERE name="admin"' )

	if [[ -z "$password" ]] || [[ -z "$salt" ]]; then
		on_error
	fi

	echo "password=\"$password\"" > .orchidpw_backup
	echo "salt=\"$salt\"" >> .orchidpw_backup

	trap ERR

	sudo service monit stop &> /dev/null
	sudo service orchid stop &> /dev/null
	sudo killall -9 orchid_server &> /dev/null
	sudo bash -c 'echo "orchid.admin.password = 0rc#1d" >> /etc/opt/orchid_server.properties'
	sudo service orchid start &> /dev/null
	sudo service monit start &> /dev/null

	echo "The Orchid Core VMS admin password should now be 0rc#1d"
elif [[ $mode == "RESTORE" ]]; then
	source .orchidpw_backup

	if [[ -z "$password" ]] || [[ -z "$salt" ]]; then
		echo "Nothing to restore!"
		echo
		exit 1
	fi

	sudo service monit stop &> /dev/null
	sudo service orchid stop &> /dev/null
	sudo killall -9 orchid_server &> /dev/null

	sudo /opt/orchid/bin/sqlite3 /var/lib/orchid_server/orchid.sqlite "UPDATE user SET password=\"$password\" WHERE name=\"admin\""
	sudo /opt/orchid/bin/sqlite3 /var/lib/orchid_server/orchid.sqlite "UPDATE user SET salt=\"$salt\" WHERE name=\"admin\""

	sudo service orchid start &> /dev/null
	sudo service monit start &> /dev/null
else
	usage
	exit 1
fi
