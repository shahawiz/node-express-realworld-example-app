pipeline {

  environment {
    IMAGE_NAME = "nodetestapp"
    AWS_REGION  = 'eu-west-2'
    AWS_ACCOUNT_ID = '075147247008'
    ECR_REPO_NAME = 'nodetestapp'
    REPO_URI = 'public.ecr.aws/l1i3r8d0/nodetestapp'
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
                  #For Private ECR Repo
                  #aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                  
                  #For Public ECR Repo Note: GetAuthorizationToken command is only supported in us-east-1.
                  aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/l1i3r8d0
                  
                  docker tag ${ECR_REPO_NAME}:latest ${REPO_URI}:latest
                  docker tag ${ECR_REPO_NAME}:latest ${REPO_URI}:${BUILD_NUMBER}
                  docker push ${REPO_URI}:latest
                  docker push ${REPO_URI}:${BUILD_NUMBER}
                  """
                 }
                 
             }
         }
        
    stage('Clean Images & Volumes') {

      steps{
        //Delete Images on machine
        sh "docker rmi ${REPO_URI}:$BUILD_NUMBER"
        sh "docker rmi ${REPO_URI}:latest"
        //Delete unused Volumes
        sh "docker volume prune -f"
      }
    }
        
    } // Stages End
}