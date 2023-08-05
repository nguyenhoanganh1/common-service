pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Check out the GitHub repository
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/nguyenhoanganh1/common-service.git'
                    ]]
                ])
            }
        }

        stage('Build') {
            steps {
                // Build the Spring Boot project using Gradle
                script {
                    def gradleHome = tool name: 'Gradle', type: 'gradle'
                    withEnv(["PATH+GRADLE=${gradleHome}/bin"]) {
                        sh './gradlew clean build'
                    }
                }
            }
        }

         stage('Packaging/Pushing image') {

           steps {
                withDockerRegistry(credentialsId: 'dockerHub', url: 'https://index.docker.io/v1/') {
                    sh 'docker build -t nguyenhoanganh/common-service'
                    sh 'docker push nguyenhoanganh/common-service'
                }
           }
        }

        stage('Deploy Database') {
            environment {
                DOCKER_IMAGE_TAG = "nguyenhoanganh/common-service:${env.BUILD_NUMBER}"
                POSTGRES_CONTAINER_NAME = "technology_core"
            }

            steps {
                // Pull the PostgreSQL Docker image
                sh 'docker pull postgres:latest'
                sh 'docker network create dev || echo "this network exists"'
                sh 'docker container stop nguyenhoanganh-postgres || echo "this container does not exists"'
                sh 'echo y | docker container prune '
                sh 'docker volume rm nguyenhoanganh-postgres-data || echo "no volume"'
                // Start the PostgreSQL container
                sh 'docker run -d --rm network dev --name ${POSTGRES_CONTAINER_NAME} -e POSTGRES_PASSWORD=123456 -p 5432:5432 postgres:latest'

            }
        }

        stage('Deploy Application') {
            environment {
                DOCKER_IMAGE_TAG = "nguyenhoanganh/common-service:${env.BUILD_NUMBER}"
                POSTGRES_CONTAINER_NAME = "common-service-postgres"
            }

            steps {
                 echo 'Deploying and cleaning'
                sh 'docker pull nguyenhoanganh/common-service'
                sh 'docker container stop common-service || echo "this container does not exists"'
                sh 'docker network create dev || echo "this network exists"'
                sh 'echo y | docker container prune '
                // Start the Spring Boot application container and link it with the PostgreSQL container
                sh "docker run -d --rm --name common-service --link ${POSTGRES_CONTAINER_NAME}:postgres -p 8080:8080 --network dev ${DOCKER_IMAGE_TAG}"
            }
        }
    }

    // Optional post-build actions
    post {
        always {
            // Clean up after the build, e.g., remove temporary files and stop the PostgreSQL container
            deleteDir()
        }
    }
}
