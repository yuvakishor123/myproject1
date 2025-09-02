pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
         git branch: 'main' , url: 'https://github.com/yuvakishor123/myproject1.git'
      }
    }

    stage('Build WAR') {
      steps {
        sh 'mvn -B -DskipTests clean package'
        sh 'ls -lh target/*.war || true'
      }
    }

    stage('Build Image') {
      steps {
        sh 'docker build -t myapp:1.0 .'
      }
    }

    stage('Local Registry (start if needed)') {
      steps {
        sh '''
          if ! docker ps --format '{{.Names}}' | grep -q '^registry$'; then
            if docker ps -a --format '{{.Names}}' | grep -q '^registry$'; then
              docker rm -f registry || true
            fi
            docker run -d -p 5000:5000 --restart=always --name registry registry:2
          fi
        '''
      }
    }

    stage('Tag & Push to Local Registry') {
      steps {
        sh 'docker tag myapp:1.0 localhost:5000/myapp:1.0'
        sh 'docker push localhost:5000/myapp:1.0'
      }
    }

    stage('Init Swarm (idempotent)') {
      steps {
        sh '''
          if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -qi active; then
            docker swarm init || true
          fi
        '''
      }
    }

    stage('Deploy 5‑Replica Stack') {
      steps {
        sh 'docker stack deploy -c docker-stack.yml myapp'
      }
    }

    stage('Verify & Show Output') {
      steps {
        sh '''
          echo "Waiting for tasks to be running..."
          for i in $(seq 1 30); do
            RUNNING=$(docker service ps myapp_web --format '{{.CurrentState}}' | grep -c Running || true)
            [ "$RUNNING" -ge 5 ] && break
            sleep 2
          done
          echo "\nServices:" && docker service ls
          echo "\nTasks:" && docker service ps myapp_web
          echo "\nSample responses (5 hits):"
          for i in $(seq 1 5); do
            if command -v curl >/dev/null 2>&1; then
              curl -fsS http://localhost:8080/ | head -n 5
            else
              wget -qO- http://localhost:8080/ | head -n 5
            fi
            echo "\n---"
            sleep 1
          done
        '''
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'target/*.war', fingerprint: true
    }
  }
}
