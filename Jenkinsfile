pipeline {

  environment {
    IMAGE_NAME = "eks-test"
    AWS_REGION  = 'eu-west-2'
    AWS_ACCOUNT_ID = '720913955512'
    ECR_REPO_NAME = 'eks-test'
    REPO_URI = '720913955512.dkr.ecr.us-west-2.amazonaws.com/eks-test'
  } 

    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages {
         stage('Clone repository') { 
            steps { 
                script{
                checkout scm
                }
            }
        }

        stage('Build Image') { 
            steps { 
                script{
                 app = docker.build "${ECR_REPO_NAME}:latest"
                }
            }
        }
        stage('Test'){
            steps {
                 //Prepare env for docker compose
                 sh "mv .env.example .env"
                 sh "containerName=nodeapp-${env.BUILD_NUMBER} docker-compose up --build -d"
                 sh "docker exec nodeapp-${env.BUILD_NUMBER} npm test"
                 sh "docker-compose down"
            }
        }
         stage('Deploy to ECR') {
             steps {

               script {
                  sh """
                  aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                  docker tag ${ECR_REPO_NAME}:latest ${REPO_URI}:latest
                  docker push ${REPO_URI}:latest
                  docker push ${REPO_URI}:${BUILD_NUMBER}
                  """
                 }
                 
             }
         }
        
    stage('Clean Unused image - Master') {

      steps{
        //Delete Images on machine
        sh "docker rmi $IMAGE_NAME:$BUILD_NUMBER"
        sh "docker rmi $IMAGE_NAME:latest"
        //Delete unused Volumes
        sh "docker volume prune -f"
      }
    }
        
    } // Stages End
}