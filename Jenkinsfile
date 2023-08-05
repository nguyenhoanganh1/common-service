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
                sh 'gradle clean build -x test'
             }
        }

        stage('Packaging/Pushing image') {
           steps {
                echo 'Packaging image'
                withDockerRegistry(credentialsId: 'dockerHub', url: 'https://index.docker.io/v1/') {
                    sh 'docker build -t nguyenhoanganh/common-service'
                    sh 'docker push nguyenhoanganh/common-service'
                }
           }
        }

        stage('Run Database') {

            steps {
                sh 'docker pull postgres:latest'
                sh 'docker network create dev || echo "this network exists"'
                sh 'docker container stop nguyenhoanganh-postgres || echo "this container does not exists"'
                sh 'echo y | docker container prune '
                sh 'docker volume rm nguyenhoanganh-postgres-data || echo "no volume"'
                sh "docker run -d --rm network dev --name ${POSTGRES_CONTAINER_NAME} -v ${POSTGRES_CONTAINER_NAME}-data:/var/lib/postgres -e POSTGRES_ROOT_PASSWORD=${POSTGRES_ROOT_LOGIN_PSW} -p 5432:5432 postgres:latest"
                sh 'sleep 15'
            }
        }

        stage('Run Application') {

            steps {
                echo 'Deploying and cleaning'
                sh 'docker pull nguyenhoanganh/common-service'
                sh 'docker container stop common-service || echo "this container does not exists"'
                sh 'docker network create dev || echo "this network exists"'
                sh 'echo y | docker container prune '
                sh 'docker run -d --rm --name common-service --link ${POSTGRES_CONTAINER_NAME}:postgres -p 8081:8080 --network dev nguyenhoanganh/common-service'
            }

        }

    }

    post {
        always {
            echo 'Run completed'
            deleteDir()
        }
    }
}
