@Library('drilldevops-sharedlibrary@test') _
pipeline {
    agent any

    parameters {
        string(name: 'AWS_ACCESS_KEY_ID', defaultValue: '', description: 'AWS Access Key ID')
        string(name: 'AWS_SECRET_ACCESS_KEY', defaultValue: '', description: 'AWS Secret Access Key')
        booleanParam(name: 'APPROVAL', defaultValue: true, description: 'Require approval before provisioning')
    }

    environment {
        REPOSITORY = 'https://github.com/kalyanreddyc/drilldevops-terraform-cicd-project.git'
        CREDENTIALS_ID = '636c6341-3a7a-491c-a744-67bf8769c54d'
        AWS_ACCESS_KEY_ID = "${params.AWS_ACCESS_KEY_ID}"
        AWS_SECRET_ACCESS_KEY = "${params.AWS_SECRET_ACCESS_KEY}"
        TERRAFORM_PATH = "/opt/homebrew/bin"
        PATH = "${env.TERRAFORM_PATH}:${env.PATH}"
    }

    stages {
        stage('Prepare Workspace') {
            steps {
                script {
                    // Clean up the existing directory if it exists
                    if (fileExists("${env.WORKSPACE}/terraform-code")) {
                        sh "rm -rf ${env.WORKSPACE}/terraform-code"
                    }
                }
            }
        }
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the GitHub repository
                    sh "git clone ${REPOSITORY} ${env.WORKSPACE}/terraform-code"
                }
            }
        }
        stage('Approval') {
            when {
                expression { return params.APPROVAL }
            }
            steps {
                script {
                    input message: 'Approve to proceed with provisioning?'
                }
            }
        }
        
        stage('Destroy Existing Resources') {
            steps {
                dir("${env.WORKSPACE}/terraform-code") {
                    script {
                        // Initialize Terraform and destroy existing resources
                        sh '''
                            set -e
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            terraform init -input=false
                            terraform destroy -input=false -auto-approve
                        '''
                    }
                }
            }
        }
        stage('Provision Infrastructure') {
            steps {
                dir("${env.WORKSPACE}/terraform-code") {
                    script {
                        // Ensure environment variables are set
                        if (!env.AWS_ACCESS_KEY_ID || !env.AWS_SECRET_ACCESS_KEY) {
                            error "AWS credentials are not set. Please provide them as input parameters."
                        }

                        // Initialize Terraform and apply changes
                        sh '''
                            set -e
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            terraform init -input=false
                            terraform apply -input=false -auto-approve
                        '''
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                dir("${env.WORKSPACE}/terraform-code") {
                    // Ensure the retrieve script exists and is executable
                    if (!fileExists('retrieve_nexus_password.sh')) {
                        error "retrieve_nexus_password.sh script not found"
                    }
                    sh 'chmod +x retrieve_nexus_password.sh'
                    sh './retrieve_nexus_password.sh'
                }
            }
        }
        failure {
            script {
                echo "Provisioning failed. Please check the logs for more details."
            }
        }
    }
}
