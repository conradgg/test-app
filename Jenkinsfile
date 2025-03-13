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
                withKubeConfig([namespace: "test-app"]) {
                    sh '''
                      if ! command -v kubectl >/dev/null 2>&1; then
                        echo "kubectl not found. Downloading..."
                        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                      fi
                      ./kubectl apply -f kubernetes/
                    '''
                }
            }
        }
    }
}
