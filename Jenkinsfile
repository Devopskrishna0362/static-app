
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        APP_NAME = 'devops-static-app'
        K8S_NAMESPACE = 'demo'
        DEPLOYMENT_NAME = 'static-site'
        CONTAINER_NAME = 'web'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code'
                checkout scm
            }
        }

        stage('Validate Tools') {
            steps {
                sh '''
                    echo "Checking Docker"
                    docker --version

                    echo "Checking Kubernetes"
                    kubectl version --client

                    echo "Checking Kubernetes context"
                    kubectl config current-context
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                }

                sh '''
                    docker build \
                      -t ${APP_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Verify Docker Image') {
            steps {
                sh '''
                    docker images | grep ${APP_NAME}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f k8s/ -n ${K8S_NAMESPACE}

                    kubectl set image \
                      deployment/${DEPLOYMENT_NAME} \
                      ${CONTAINER_NAME}=${APP_NAME}:${IMAGE_TAG} \
                      -n ${K8S_NAMESPACE}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl rollout status \
                      deployment/${DEPLOYMENT_NAME} \
                      -n ${K8S_NAMESPACE} \
                      --timeout=180s

                    kubectl get pods -n ${K8S_NAMESPACE} -o wide

                    kubectl get services -n ${K8S_NAMESPACE}
                '''
            }
        }
    }

    post {
        success {
            echo 'Application deployed successfully!'
            echo 'Application URL: http://localhost:30080'
        }

        failure {
            echo 'Pipeline failed. Check Jenkins Console Output.'
        }

        always {
            echo 'CI/CD Pipeline execution completed.'
        }
    }
}
