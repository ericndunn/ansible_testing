Jenkins
=========

This role will install a list of plugins to Jenkins-LTS

Requirements
------------

NOTE: owner = ansible_user_id (your OS UserID), group = staff (run command to verify owner:group 'ls -la ~/.jenkins')
Assumptions: homebrew, ansible, jenkins-lts (basic configuration), *jdk-1.8 installed

- Install homebrew
	- https://docs.brew.sh/Installation
- Install ansible
	- brew install ansible
- Install jenkins-lts
	- brew install jenkins-lts
- Install plugins into Jenkins-lts
	- cd to where install_jenkins_plugins.yml 
	- ansible-playbook install_jenkins_plugins.yml -e "my_jenkins_user=[YOUR JENKINS USER] my_jenkins_pass=[YOUR JENKINS PASSWORD]"


Role Variables
--------------

- ansible_connection: local <-- run on local
- my_jenkins_user: "{{ my_jenkins_user }}" <-- Jenkins admin user
- my_jenkins_pass: "{{ my_jenkins_pass }}" <-- Jenkins admin password
- owner_name: "{{ ansible_user_id }}" <-- whoami
- group_name: staff <-- group name

Dependencies
------------

- Assumption: JDK 1.8 installed as dependency for Jenkins-lts)
- https://java.com/en/download/help/mac_install.xml

Example Playbook
----------------
- cd to dir where install_jenkins_plugins.yml /jenkins/...
- ansible-playbook install_jenkins_plugins.yml -e "my_jenkins_user=[YOUR JENKINS USER] my_jenkins_pass=[YOUR JENKINS PASSWORD]"

License
-------

FOSS

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
