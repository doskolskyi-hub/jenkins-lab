pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-central-1'
        AWS_ACCOUNT_ID = '666398469283'
        ECR_REPOSITORY = 'jenkins-lab'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t ${ECR_REPOSITORY}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password \
                      --region ${AWS_REGION} \
                    | docker login \
                      --username AWS \
                      --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh '''
                    docker tag \
                      ${ECR_REPOSITORY}:${BUILD_NUMBER} \
                      ${IMAGE_URI}:${BUILD_NUMBER}

                    docker tag \
                      ${ECR_REPOSITORY}:${BUILD_NUMBER} \
                      ${IMAGE_URI}:latest
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    docker push ${IMAGE_URI}:${BUILD_NUMBER}
                    docker push ${IMAGE_URI}:latest
                '''
            }
        }
    }

    post {
        success {
            echo 'Docker image successfully pushed to ECR!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}
