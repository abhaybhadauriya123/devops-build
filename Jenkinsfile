pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'abhaytheinfinity'
        DEV_IMAGE = 'abhaytheinfinity/devops-build-dev:dev'
        PROD_IMAGE = 'abhaytheinfinity/devops-build-prod:prod'
        APP_SERVER = 'ubuntu@3.110.194.66'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        sh './build.sh dev'
                    } else if (env.BRANCH_NAME == 'master') {
                        sh './build.sh prod'
                    } else {
                        error "Unsupported branch: ${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        sh """
                            docker tag devops-build-app:dev ${DEV_IMAGE}
                        """
                    } else if (env.BRANCH_NAME == 'master') {
                        sh """
                            docker tag devops-build-app:prod ${PROD_IMAGE}
                        """
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                    '''

                    script {
                        if (env.BRANCH_NAME == 'dev') {
                            sh "docker push ${DEV_IMAGE}"
                        } else if (env.BRANCH_NAME == 'master') {
                            sh "docker push ${PROD_IMAGE}"
                        }
                    }
                }
            }
        }

        stage('Deploy to Production Server') {
            steps {
                sshagent(credentials: ['production-server-ssh']) {
                    script {
                        def image = env.BRANCH_NAME == 'dev' ? env.DEV_IMAGE : env.PROD_IMAGE

                        sh """
                            ssh -o StrictHostKeyChecking=no ${APP_SERVER} '
                                docker pull ${image} &&
                                docker rm -f devops-build-container || true &&
                                docker run -d \
                                  --name devops-build-container \
                                  --restart unless-stopped \
                                  -p 80:80 \
                                  ${image} &&
                                curl -f http://localhost
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "CI/CD pipeline completed successfully for ${env.BRANCH_NAME}"
        }

        failure {
            echo "CI/CD pipeline failed for ${env.BRANCH_NAME}"
        }
    }
}
