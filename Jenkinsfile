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
        stage('Build') {
            steps {
                sh './mvnw clean install'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        stage('Docker Security Scan') {
            steps {
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
