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
    image: gcr.io/kaniko-project/executor:v1.23.2
    args:
      - "--dockerfile=Dockerfile"
      - "--context=git://github.com/conradgg/test-app.git"
      - "--destination=fra.vultrcr.com/conradgg/test-app:latest"
      env:
      - name: GOOGLE_APPLICATION_CREDENTIALS
        value: /secret/config.json
    volumeMounts:
      - name: docker-config
        mountPath: /secret
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
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh 'kubectl apply -f kubernetes/'
                }
            }
        }
    }
}

