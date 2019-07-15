pipeline {
    agent { label 'MASTER' }
        parameters {
        choice(choices: ['inventory', 'null'], 
                          description: '', 
                          name: 'INV_FILE')
        choice(choices: ['all', 
                         'FS-AA-DEV-IHS', 
                         'FS-AA-DEV-WAS', 
                         'FS-AA-DEV-DB', 
                         'FS-AA-PERF-IHS', 
                         'FS-AA-PERF-WAS', 
                         'FS-AA-PERF-DB', 
                         'FS-AA-SEC-IHS', 
                         'FS-AA-SEC-WAS', 
                         'FS-AA-SEC-DB', 
                         'FS-AA-SIT-IHS', 
                         'FS-AA-SIT-WAS', 
                         'FS-AA-SIT-DB', 
                         'FS-AA-UAT-IHS', 
                         'FS-AA-UAT-WAS', 
                         'FS-AA-UAT-DB', 
                         'FS-AA-PROD-IHS', 
                         'FS-AA-PROD-WAS', 
                         'FS-AA-PROD-DB', 
                         'ET-AA-PERF-IHS', 
                         'ET-AA-PERF-WAS', 
                         'ET-AA-PERF-DB', 
                         'ET-AA-SEC-IHS', 
                         'ET-AA-SEC-WAS', 
                         'ET-AA-SEC-DB', 
                         'ET-AA-SIT-IHS', 
                         'ET-AA-SIT-WAS', 
                         'ET-AA-SIT-DB', 
                         'ET-AA-UAT-IHS', 
                         'ET-AA-UAT-WAS', 
                         'ET-AA-UAT-DB', 
                         'ET-AA-PROD-IHS', 
                         'ET-AA-PROD-WAS', 
                         'ET-AA-PROD-DB', 
                         'ET-PREPROD-IHS', 
                         'ET-PREPROD-WAS', 
                         'ET-PREPROD-DB', 
                         'MM-DEV-IHS', 
                         'MM-DEV-WAS', 
                         'MM-DEV-DB', 
                         'MM-PERF-IHS', 
                         'MM-PERF-WAS', 
                         'MM-PERF-DB', 
                         'MM-SEC-IHS', 
                         'MM-SEC-WAS', 
                         'MM-SEC-DB', 
                         'MM-SIT-IHS', 
                         'MM-SIT-WAS', 
                         'MM-SIT-DB', 
                         'MM-UAT-IHS', 
                         'MM-UAT-WAS', 
                         'MM-UAT-DB', 
                         'MM-PRODB-IHS', 
                         'MM-PRODB-WAS', 
                         'MM-PRODB-DB', 
                         'MM-PRODA-IHS', 
                         'MM-PRODA-WAS', 
                         'MM-PRODA-DB'], 
                         description: '', 
                         name: 'INV_GRP')
    }
    stages {
        stage('Run Ansible Access operation'){
        
            steps {

            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                    echo 'Validate Access'
                    //sh 'ansible-playbook -i dev-servers site.yml'
                    ansiblePlaybook credentialsId: '62c93b86-c4ba-483c-a696-8180694ce559',
                    installation: 'ansible', 
                    inventory: '/Users/ag19884/${INV_FILE}',
                    limit: '${INV_GRP}',
                    playbook: '${WORKSPACE}/ansible_testing/roletest/server_access_status.yml',
                    colorized: true
                }
            }
        }

        stage('Demo Performance'){
            steps {
                echo 'Clap if you liked the demo!'
            }
        }

    }
}
