pipeline {
  agent any

  options {
    gitLabConnection('gitlab-name')
  }

  environment {
    REPOSITORY = "nexus01:8083"
    IMAGE = "spark"
    VERSION = readFile("version.txt").trim()
  }

  stages {
    stage('Init') {
      steps {
        gitlabCommitStatus(name: 'init') {
          script {
            echo "Jenkins pipeline running on node: ${env.NODE_NAME}"
          }
        }
      }
    }
    
    stage('Build spark docker image') {
      steps {
        gitlabCommitStatus(name: 'Build spark') {
          script {
            sh "make VERSION=${VERSION} REPOSITORY=${REPOSITORY} IMAGE=${IMAGE} build"
          }
        }
      }
    }

    stage('Publish spark images on Nexus') {
      when {
          branch 'master'
      }
      steps {
        gitlabCommitStatus(name: 'Publish spark docker image on Nexus') {
          script {
            sh "make VERSION=${VERSION} REPOSITORY=${REPOSITORY} IMAGE=${IMAGE} push"
          }
        }
      }
    }
  }

  post {
    always {
      deleteDir()
    }
  }
}
