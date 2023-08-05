pipeline {
    agent any

    tools {
        gradle 'my-gradle'
    }

    environment {
        POSTGRESQL_ROOT_LOGIN = credentials('postgresql-root-login')
        DOCKER_IMAGE_TAG = "nguyenhoanganh/common-service:${env.BUILD_NUMBER}"
        POSTGRES_CONTAINER_NAME = "technology_core"
    }

    stages {
        stage ("Checkout SCM") {
             steps {
                checkout scm
             }
        }

        stage('Build') {
             steps {
                 // Build the Spring Boot project using Gradle
                 withGradle {
                     sh 'clean build'
                 }
             }
        }

        stage('Packaging/Pushing image') {
           steps {
                withDockerRegistry(credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/') {
                    sh 'docker build -t nguyenhoanganh/common-service'
                    sh 'docker push nguyenhoanganh/common-service'
                }
           }
        }

        stage('Start Deploy Database') {
            steps {
                // Pull the PostgreSQL Docker image
                sh 'docker pull postgres:latest'
                sh 'docker network create dev || echo "this network exists"'
                sh 'docker container stop nguyenhoanganh-postgres || echo "this container does not exists"'
                sh 'echo y | docker container prune '
                sh 'docker volume rm nguyenhoanganh-postgres-data || echo "no volume"'
                // Start the PostgreSQL container
                sh "docker run -d --rm network dev --name ${POSTGRES_CONTAINER_NAME} -v ${POSTGRES_CONTAINER_NAME}-data:/var/lib/postgres -e POSTGRES_ROOT_PASSWORD=${POSTGRES_ROOT_LOGIN_PSW} -p 5432:5432 postgres:latest"
                sh 'sleep 15'
            }
        }

        stage('Starting Deploy Application') {

            steps {
                echo 'Deploying and cleaning'
                sh 'docker pull nguyenhoanganh/common-service'
                sh 'docker container stop common-service || echo "this container does not exists"'
                sh 'docker network create dev || echo "this network exists"'
                sh 'echo y | docker container prune '
                // Start the Spring Boot application container and link it with the PostgreSQL container
                sh 'docker run -d --rm --name common-service --link ${POSTGRES_CONTAINER_NAME}:postgres -p 8081:8080 --network dev nguyenhoanganh/common-service'
            }
        }
    }

    // Optional post-build actions
    post {
        always {
            echo 'Run completed'
            deleteDir()
        }
    }
}
