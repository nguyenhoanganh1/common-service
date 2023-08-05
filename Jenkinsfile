pipeline {
    agent any

    tools {
        maven 'my-maven'
    }

    environment {
        POSTGRES_SQL_ROOT_LOGIN = credentials('postgres-sql-login')
    }

    stages {

        stage('Build with maven') {
            steps {
                sh 'mvn --version'
                sh 'java --version'
                sh 'mvn clean package -Dmaven.test.failure.ignore=true'
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

        stage('Deploy Postgres Sql to Dev') {
            steps {
                echo 'Deploying and cleaning'
                sh 'docker image pull postgres:14.3'
                sh 'docker network create dev || echo "this network exists"'
                sh 'docker container stop nguyenhoanganh-postgres || echo "this container does not exists"'
                sh 'echo y | docker container prune '
                sh 'docker volume rm nguyenhoanganh-postgres-data || echo "no volume"'

                sh "docker run --name nguyenhoanganh-postgres --rm network dev -v nguyenhoanganh-postgres-data:/var/lib/postgres -e POSTGRES_ROOT_PASSWORD=${POSTGRES_ROOT_LOGIN_PSW} "
                sh 'sleep 15'
                sh "docker exec -i nguyenhoanganh-postgres postgres --user=postgres --password=${POSTGRES_ROOT_LOGIN_PSW} < script"
            }
        }

        stage('Deploy spring boot to Dev') {
            steps {
                echo 'Deploying and cleaning'
                sh 'docker iamge pull nguyenhoanganh/common-service'
                sh 'docker container stop common-service || echo "this container does not exists"'
                sh 'docker network create dev || echo "this network exists"'
                sh 'echo y | docker container prune '

                sh 'docker container run -d --rm --name common-service -i 8081:8080 --network dev nguyenhoanganh/common-service'
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}