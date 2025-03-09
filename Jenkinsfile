pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-agent
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.2-debug
    command: ["/bin/sh"]
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/config.json
        subPath: .dockerconfigjson
  - name: kubectl
    image: bitnami/kubectl:1.32.2
    command:
      - cat
    tty: true
  volumes:
  - name: docker-config
    secret:
      secretName: docker-config
"""
        }
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/conradgg/test-app.git'
            }
        }
        stage('Build and Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                      /kaniko/executor \
                        --dockerfile=Dockerfile \
                        --context=$(pwd) \
                        --destination=fra.vultrcr.com/conradgg/test-app:latest
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh 'kubectl apply -f kubernetes/'
                }
            }
        }
    }
}
