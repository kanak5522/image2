pipeline {
    agent {
        docker {
            // Use a Docker image that supports Docker-in-Docker (DinD)
            image 'docker:20.10-dind'
            // Mount the Docker socket to the container
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        DOCKER_IMAGE = 'kanakchandel/terraform-aws:latest'
        AWS_REGION = 'eu-west-1'
        AWS_INSTANCE_TYPE = 't2.micro'
        AWS_AMI_ID = 'ami-0fa8fe6f147dc938b'  // Replace with a valid AMI ID
    }
    stages {
        stage('Prepare Dockerfile and Terraform Code') {
            steps {
                script {
                    // Dockerfile content
                    def dockerfileContent = '''
                    FROM ubuntu:20.04

                    RUN apt-get update && apt-get install -y \\
                        curl \\
                        unzip \\
                        git \\
                        awscli \\
                        && rm -rf /var/lib/apt/lists/*

                    RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \\
                        && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" \\
                        && apt-get update \\
                        && apt-get install terraform

                    WORKDIR /workspace

                    COPY entrypoint.sh /entrypoint.sh
                    RUN chmod +x /entrypoint.sh

                    ENTRYPOINT ["/entrypoint.sh"]
                    '''

                    // Entry point script content
                    def entrypointScript = '''
                    #!/bin/bash
                    set -e

                    # Create Terraform configuration file
                    cat > /workspace/main.tf <<EOF
                    provider "aws" {
                      region = "${AWS_REGION}"
                    }

                    resource "aws_instance" "example" {
                      ami           = "${AWS_AMI_ID}"
                      instance_type = "${AWS_INSTANCE_TYPE}"

                      tags = {
                        Name = "example-instance"
                      }
                    }
                    EOF

                    # Initialize and apply Terraform configuration
                    terraform init
                    terraform apply -auto-approve
                    '''

                    // Write Dockerfile and entrypoint script to workspace
                    writeFile file: 'Dockerfile', text: dockerfileContent
                    writeFile file: 'entrypoint.sh', text: entrypointScript
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Ensure Docker daemon is available
                    sh "docker info"

                    // Build the Docker image
                    sh "docker build -t ${DOCKER_IMAGE} ."

                    // Log in and push the Docker image
                    withCredentials([usernamePassword(credentialsId: 'kanakdocker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        stage('Run Terraform') {
            steps {
                script {
                    // Run Terraform commands inside the Docker container
                    sh "docker run --rm ${DOCKER_IMAGE}"
                }
            }
        }
    }
    post {
        always {
            // Archive Terraform state files if needed
            archiveArtifacts artifacts: '**/*.tfstate', allowEmptyArchive: true
        }
    }
}
