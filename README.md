Jenkins
=========

This role will install a list of plugins to Jenkins-LTS

Assumptions
------------
- JDK 1.8 installed as dependency for Jenkins-lts)
  https://java.com/en/download/help/mac_install.xml

NOTE: owner = ansible_user_id (your OS UserID), group = staff (run command to verify owner:group 'ls -la ~/.jenkins')
Assumptions: homebrew, ansible, jenkins-lts (basic configuration), *jdk-1.8 installed

Requirements
------------

- Install homebrew
	- https://docs.brew.sh/Installation
- Install ansible
	- brew install ansible
- Install jenkins-lts
	- brew install jenkins-lts
- Install plugins into Jenkins-lts (See Role Variables prior to installing plugins)
	- cd to where install_jenkins_plugins.yml 
	- ansible-playbook install_jenkins_plugins.yml
	- Restart Jenkins upon completion

Role Variables
--------------

- ansible_connection: local <-- run on local
- my_jenkins_user: "" <-- Jenkins admin user - NO USERID (See After initial login below)
- my_jenkins_pass: "" <-- Jenkins admin password - NO PASSWORD (See After initial login below)
- owner_name: "{{ ansible_user_id }}" <-- whoami
- group_name: staff <-- group name

  After initial login to Jenkins with provided password
  Navigate to http://localhost:8080/configureSecurity/ and uncheck 'Enable security'
  This will allow you to download plugins without USERID/PASSWORD

IMPORTANT: Prior to running the playbook, change the following
http://localhost:8080/pluginManager/advanced 'Update Site' from https to http protocol for the provided URL.  

Dependencies
------------

- JDK 1.8 installed as dependency for Jenkins-lts)
  https://java.com/en/download/help/mac_install.xml

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
