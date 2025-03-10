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
    image: rancher/kubectl:v1.32.2
    command: ["/bin/sh"]
    tty: true
  volumes:
  - name: docker-config
    secret:
      secretName: docker-config
"""
        }
    }
    stages {
        stage('Build and Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                      /kaniko/executor \
                        --dockerfile=Dockerfile \
                        --context=git://github.com/conradgg/test-app.git \
                        --destination=fra.vultrcr.com/conradgg/test-app:latest
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        pwd && ls -la
                        kubectl apply -f kubernetes/
                    '''
                }
            }
        }
    }
}
