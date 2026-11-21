
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        APP_NAME       = 'devops-static-app'
        K8S_NAMESPACE  = 'demo'
        DEPLOYMENT_NAME = 'static-site'
        CONTAINER_NAME = 'web'
        KUBECONFIG     = '/var/jenkins_home/.kube/config'
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
                    echo "===== Docker Version ====="
                    docker --version

                    echo "===== Docker Server ====="
                    docker version

                    echo "===== Kubernetes Version ====="
                    kubectl version --client

                    echo "===== Kubernetes Context ====="
                    kubectl config current-context

                    echo "===== Kubernetes Nodes ====="
                    kubectl get nodes

                    echo "===== Kubernetes Namespace ====="
                    kubectl get namespace ${K8S_NAMESPACE}
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                }

                sh '''
                    echo "Building Docker image"

                    docker build \
                        -t ${APP_NAME}:${IMAGE_TAG} \
                        .

                    echo "Docker image build completed"
                '''
            }
        }

        stage('Verify Docker Image') {
            steps {
                sh '''
                    echo "Verifying Docker image"

                    docker image inspect ${APP_NAME}:${IMAGE_TAG}

                    docker images ${APP_NAME}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "Applying Kubernetes manifests"

                    kubectl apply -f k8s/ -n ${K8S_NAMESPACE}

                    echo "Updating Kubernetes deployment image"

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
                    echo "Checking Kubernetes rollout"

                    kubectl rollout status \
                        deployment/${DEPLOYMENT_NAME} \
                        -n ${K8S_NAMESPACE} \
                        --timeout=180s

                    echo "===== Application Pods ====="
                    kubectl get pods -n ${K8S_NAMESPACE} -o wide

                    echo "===== Kubernetes Services ====="
                    kubectl get services -n ${K8S_NAMESPACE}

                    echo "===== Deployment Details ====="
                    kubectl describe deployment \
                        ${DEPLOYMENT_NAME} \
                        -n ${K8S_NAMESPACE}
                '''
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: CI/CD pipeline completed!'
            echo 'Application deployed successfully.'
            echo 'Application URL: http://localhost:30080'
        }

        failure {
            echo 'FAILURE: CI/CD pipeline failed.'
            echo 'Please check the Jenkins Console Output.'
        }

        always {
            echo 'CI/CD Pipeline execution completed.'
        }
    }
}
:wq
