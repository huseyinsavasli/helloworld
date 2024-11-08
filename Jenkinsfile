pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "helloworld"
        DOCKER_REGISTRY = "hsavasli/helloworld"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url:'https://github.com/huseyinsavasli/helloworld.git'
            }
        }
        stage('Set Permissions') {
            steps {
                sh 'chmod +x ./mvnw'
            }
        }
        stage('Build') {
            steps {
                sh './mvnw clean install'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                 sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }
        stage('Docker Security Scan') {
            steps {
                sh 'docker pull ghcr.io/aquasecurity/trivy-db:latest'
                sh 'docker run --rm -v ~/.cache/trivy:/root/.cache aquasecurity/trivy-db:latest'
                sh 'trivy image ${DOCKER_IMAGE}'
            }
        }
        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl apply -f kubernetes/deployment.yaml'
                }
            }
        }
    }
}
