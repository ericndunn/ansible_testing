#!/bin/bash

#nohup /usr/bin/java -jar swarm-client-3.9.jar -username orchid -password 0rc#1d0rc#1d -fsroot /jenkins -master https://orchid.ipconfigure.com:8443 -name SteelfinTarget -description "Steelfin Client Target" -deleteExistingClients -disableSslVerification -executors 2 -mode normal -labels STEELFIN_CLIENT >> /jenkins/nohup.out 2>&1 &
currentscript="$0"

# Function that is called when the script exits:
function finish {
    echo "Securely shredding ${currentscript}"; shred -u ${currentscript};
}

# Do your bashing here...
#echo "Connecting with Jenkins Swarm plugin"
sudo -H -u orchid bash -c '
wget -O /jenkins/swarm-client-3.9.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.9/swarm-client-3.9.jar
chmod a+x /jenkins/swarm-client-3.9.jar
'
sudo -H -u orchid bash -c "
java -jar /jenkins/swarm-client-3.9.jar \
-username orchid \
-password 0rc#1d0rc#1d \
-fsroot /jenkins \
-master https://orchid.ipconfigure.com:8443 \
-name SteelfinTarget \
-description "Steelfin Client Target" \
-deleteExistingClients \
-disableSslVerification \
-executors 2 \
-mode normal \
-labels STEELFIN_CLIENT &
"

# When your script is finished, exit with a call to the function, "finish":
#trap finish EXIT