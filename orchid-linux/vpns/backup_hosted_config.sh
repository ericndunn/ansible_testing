#!/bin/bash

customer_id=$(cut -d "-" -f 2 <<< $(hostname) )
backup_id=$(date +%s)
backup_dir="/home/fusion/backups/${backup_id}"

# Create the current archive
mkdir -p ${backup_dir}
cd $backup_dir

# Backup client config files
mkdir clients
sudo cp -a /home/fusion/client_configs/* clients/

# Backup OpenVPN and Easy RSA
mkdir -p etc/openvpn
sudo cp -a /etc/openvpn/* etc/openvpn/

# Backup server SSH keys
mkdir ssh
sudo cp ~/.ssh/* ssh/

# Backup Fusion config
mkdir -p etc/opt
sudo cp -a /etc/opt/* etc/opt/

# Backup Fusion database
mkdir -p var/lib/fusion
sudo cp -a /var/lib/fusion/* var/lib/fusion/

# Archive it up
cd ..
sudo tar cfJ ${backup_id}.tar.xz ${backup_id}

# Remove any straggling directories
sudo rm -rf */

# Remove files older than...
day_limit=60
second_limit=$(( $day_limit * 24 * 60 * 60 ))

for file in $(/bin/ls *.tar.*); do
    file_time=$( cut -d '.' -f 1 <<< "$file" )
    if [[ $(( $(date +%s) - $file_time )) -gt $second_limit ]]; then
        rm $file
    fi
done

# Sync to license.ipconfigure.com (EC2 instance)
key_file=$(mktemp)
cat > $key_file << EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAtKpepnvAFuRxfiA0TrUN72bCtrzvQYRaY1mQTTrD8WfKBPBj
u57fNDr5XtnOSrrNrLMkpgh1cSA8FprfSxTFkXBwqy7CVey7hUItSTzRMAJUky8U
c2X9UgL1gMPgpZHXoEBmtj/+wI+MhaBmowDpQV/RQ66awxg7JZk2QMPvtnXM2Wey
AUxOr6yCs5IAsOrDE/ijkzoerwdz64NK2ONYTKshf8TfKdNkxHb+U0tRdTO2rCq3
dIbItOjiIVrkrD5tMTMopAK6KfBD8ATg8dl/LGWjnGZJ2qc/b0M3BeQVhQLXUjl/
ZL8xb5ajaPAsIWRDH5TAmqIjZIhgT5PvjIkxBQIDAQABAoIBAQCn42LNx1Y8b9Hf
6UFymuH2RUJQ2sZj1gDBLmvguOl5nn+nk1S69+pn+R3fvPvtiiazhE5cVKP+mnv8
bbNvbEAk5Z5uFafWfYXNUjAPTQsAWEoL9MZGbtK3sbQ/EsfiVONSMkbAujuc6kkl
rGd0ttYMQGSRRuLexdfBGt3F1c8feE1OdXdKyJcKDeiz6mif60tMDIuLQRLECeE+
dtSXi1IVSxkjFG0Pb1tUMUVKzdRRpEjhRU15G9e96myeLW4NMcV3IsaGuYRGJDJT
Tz3jkQyQSYfFa6TJNpGmwE02NynH+hjncbnGpLYDKjVUQqfa9MFgnT2Gu5fp40Zh
nK0GqznBAoGBANdvnQo8Am97EfKrHUpifb5x74GMKqQBAlLda+IwbrW/oLEMi5Yk
KMUdcUXYmN429gNAgMNcre71MADXuUn55KRb7JJJkE4JzOMf5MmHX1TW9M0tXXNb
DtnxELOvt2n4R9ZicwnevtqshEdY4P7UaoWXHEsT3QultvFYXvyVquGtAoGBANau
wkzF1ePvlk43PGRHQ3LzolntHTDcsVToXFmKb0xReyHx/E8eJVHhs0jEdpz6OeyH
5MYWrm8XScv5Nc82Vy8ZjlNCcefEmfKkWilg0E1rMpNVeLEEQnlLT2y4Qbzp57u7
iCRCpI64G65MK0XCFO95F3WI83RRBLKpv8mDLee5AoGAK68lL9MVR1e0Pvm1mcS4
7Kobv7AVYWYW+4iMfLQHbvEpe10o3Mv+PGII+vm9namVXvlwYqzjVAYBstoLZ1W1
qCI/qTYjfb98/T0VXkwF56UixIwDXAXF0CmSkmz6CxHeNzmFTCYPmzXKKNF75hBa
fTYz9YFUnC0BGJUrxZnvqY0CgYAzY9IPHqx8y7VnM8G5H3X95mROsnvyXmH0uUqi
BIlv83FORubm6Yh1eVm5aY4bNar3+++/m15WKXT45scCuzdThwKS26z4lg9kDgOn
NA2o+qg4rJUfiq1+65AvrkvONQ/L2LBWPb22jEvUBVe2cycfzBTZhdcBWQOO4SOP
0V8DwQKBgQCSFPIonLxLJnien4LGowWV+w/qay7X+e50OWRs+2FtIVx3BbTB3j2E
sQHVTpqKX1HqkCxsrDA+fc/M5x0ZnzW06W0KH8HndhmgIfEe5lTXV7IIggM46WYL
xVY20cee6wjYbaED8IDVKzpH5uOD9HJJ6RDEa3v6OAUdVAZRpRdryw==
-----END RSA PRIVATE KEY-----
EOF
chmod 600 $key_file

ssh -o StrictHostKeyChecking=no -i ${key_file} backups@license.ipconfigure.com mkdir -p /home/backups/${customer_id}
rsync -avz -e "ssh -o StrictHostKeyChecking=no -i ${key_file}" /home/fusion/backups/ backups@license.ipconfigure.com:/home/backups/${customer_id}/

rm -f $key_file
