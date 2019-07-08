
NOTE: owner = ansible_user_id (your OS UserID), group = staff (run command to verify owner:group 'ls -la ~/.jenkins')
Assumptions: homebrew, ansible, jenkins-lts (basic configuration), *jdk-1.8 installed

- Install homebrew
	https://docs.brew.sh/Installation
- Install ansible
	brew install ansible
- Install jenkins-lts
	brew install jenkins-lts
- *(assumption JDK 1.8 installed as dependency for Jenkins-lts)
	https://java.com/en/download/help/mac_install.xml
- Install plugins into Jenkins-lts
	cd to where install_jenkins_plugins.yml 
	ansible-playbook install_jenkins_plugins.yml -e "my_jenkins_user=[YOUR JENKINS USER] my_jenkins_pass=[YOUR JENKINS PASSWORD]"
