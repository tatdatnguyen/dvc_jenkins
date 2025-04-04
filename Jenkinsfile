pipeline {
  agent any

  environment {
    IMAGE_NAME = 'my-torchserve-app'
    IMAGE_TAG = 'latest'
    DOCKER_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
  }

  stages {
    stage('Build') {
      steps {
        sh 'docker build -t $DOCKER_IMAGE .'
        sh 'docker tag $DOCKER_IMAGE $DOCKER_DVC_IMAGE'
      }
    }

    stage('Test') {
      steps {
        sh 'docker run --rm -v /tmp/model-store:/home/model-server/model-store -p 7070:7070 -p 7071:7071 my-torchserve-app:latest'
      }
    }

    stage('Deploy') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: "${DOCKER_REGISTRY_CREDS}",
          usernameVariable: 'DOCKER_USERNAME',
          passwordVariable: 'DOCKER_PASSWORD'
        )]) {
          sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin docker.io"
          sh 'docker push $DOCKER_DVC_IMAGE'
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
  }
}
