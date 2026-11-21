
pipeline {
    agent any

    environment {
        APP_NAME = 'devops-static-app'
        K8S_NAMESPACE = 'demo'
        DEPLOYMENT_NAME = 'static-site'
        CONTAINER_NAME = 'web'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub'
                checkout scm
            }
        }

        stage('Validate Tools') {
            steps {
                sh '''
                    docker --version
                    kubectl version --client
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

                    kubectl get svc -n ${K8S_NAMESPACE}
                '''
            }
        }
    }

    post {
        success {
            echo 'Application deployed successfully!'
            echo 'Access: http://localhost:30080'
        }

        failure {
            echo 'Pipeline failed. Check Jenkins console output.'
        }
    }
}
