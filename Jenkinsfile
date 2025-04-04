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
          script {
              // Run the Docker container in detached mode (background)
              def dockerRunCommand = 'docker run -d --rm -v /tmp/model-store:/home/model-server/model-store -p 7070:7070 -p 7071:7071 my-torchserve-app:latest'
              
              // Start the Docker container in the background
              def containerId = sh(script: dockerRunCommand, returnStdout: true).trim()
              echo "Docker container started with ID: ${containerId}"
              
              // Set a timeout of 10 minutes for the docker run process
              timeout(time: 1, unit: 'MINUTES') {
                  // Wait for the container to run (or the timeout to expire)
                  echo "Waiting for the Docker container to complete its task."
              }
              
              // Stop the Docker container after the timeout
              echo "Stopping Docker container with ID: ${containerId}"
              sh "docker stop ${containerId}"
          }
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
