pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "helloworld:latest"
        DOCKER_REGISTRY = "hsavasli/helloworld"
        KUBECONFIG = "/var/jenkins_home/.kube/config"
        HELM_RELEASE_NAME = "helloworld"
        HELM_CHART_REPO = "https://github.com/huseyinsavasli/helloworld.git"  // GitHub repository linki
        HELM_CHART_PATH = "helm/helloworld"  // Chart dizininizin yolu
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/huseyinsavasli/helloworld.git'
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
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }
        //stage('Docker Security Scan') {
        //    steps {
        //        sh 'trivy image --skip-db-update --timeout 20m --scanners vuln ${DOCKER_IMAGE}'
        //    }
        //}
        stage('Docker Tag') {
            steps {
                sh 'docker tag ${DOCKER_IMAGE} ${DOCKER_REGISTRY}:latest'
            }
        }
        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("${DOCKER_REGISTRY}:latest").push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes with Helm') {
            steps {
                script {
                    // GitHub pull helm chart
                    sh 'git clone ${HELM_CHART_REPO} helm-chart'

                    // with Helm Kubernetes Deployments
                    sh "helm upgrade --install ${HELM_RELEASE_NAME} helm-chart/${HELM_CHART_PATH} --kubeconfig ${KUBECONFIG} --set image.repository=${DOCKER_REGISTRY},image.tag=latest"
                }
            }
        }
    }
}
