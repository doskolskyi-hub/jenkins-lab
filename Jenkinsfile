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

        stage('Deploy to EC2') {
            steps {
                sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@10.20.1.172 << 'EOF'

                    aws ecr get-login-password --region eu-central-1 | \
                    docker login --username AWS --password-stdin \
                    666398469283.dkr.ecr.eu-central-1.amazonaws.com

                    docker pull \
                    666398469283.dkr.ecr.eu-central-1.amazonaws.com/jenkins-lab:latest

                    docker rm -f jenkins-lab-app 2>/dev/null || true

                    docker run -d \
                      --name jenkins-lab-app \
                      --restart unless-stopped \
                      -p 80:80 \
                      -e WORDPRESS_DB_HOST="doskolskyi-wordpress-rds.c3kyeieu6kkc.eu-central-1.rds.amazonaws.com:3306" \
                      -e WORDPRESS_DB_NAME="wordpress" \
                      -e WORDPRESS_DB_USER="db_user" \
                      -e AWS_REGION="eu-central-1" \
                      -e SSM_DB_PASSWORD_PARAMETER="/wordpress/db/password" \
                      666398469283.dkr.ecr.eu-central-1.amazonaws.com/jenkins-lab:latest

                    EOF
                '''
            }
        }
    }

    post {
        success {
            echo 'Docker image successfully built, pushed to ECR and deployed to EC2!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}
