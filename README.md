# NodeJs App + MongoDB

This repo contains a simple NodeJs app with MongoDB and includes :
- Dockerfile -> Dockerfile
- Docker Compose -> docker-compose.yml
- Jenkins pipeline -> Jenkinsfile
- Kubernates -> k8s
- HelmChart -> nodetestapp-helm
- Simple Terraform IaaC template to provision an EC2 with attached EBS - > terraform

## Docker & Docker Compose Usage
The NodeJs app requires some parameters like a secret to be used in sessions so, these params were added to .env.example and before you run the docker compose you have to change the file name to **.env**
```python

# Change env file name
mv .env.example

# Run Docker-Compose
docker-compose up --build --build-arg containerName="nodetestapp" -d

```

## Jenkins pipeline Usage
This pipeline has the following stages :
- Clone code from the current repo.
- Build docker image.
- Test Application by running docker-compose then execute **npm run test**
- Deploying to AWS ECR :
   - I deployed to public ECR to make it easy to access the repo to test it by anybody but it's not the best practice as you have to deploy it to private ECR.
   - I didn't use AWS Key/Secret but I created and [attached IAM Role to the Jenkins instance](https://aws.amazon.com/premiumsupport/knowledge-center/assign-iam-role-ec2-instance/).
   - **Note :** To push to public ECR the only supported region to authenticate and get AWS token is *us-east-1* 
![Alt text](https://i.ibb.co/qWrBzLs/EKS-TEST-Jenkins.png "Jenkins")

When you open Jenkinsfile you have to edit the env section with following 
```python
  environment {
    IMAGE_NAME = "nodetestapp"  //Your Image name
    AWS_REGION  = 'eu-west-2' // Change it to region of private ECR
    AWS_ACCOUNT_ID = '075147275408' //Your AWS account ID needed if you will use a private ECR
    ECR_REPO_NAME = 'nodetestapp' //ECR Repo name
    REPO_URI = 'public.ecr.aws/l1i3r8d0/nodetestapp' //ECR URI
  } 

```
Also, if there are two lines if you are using public or private ECR in the deploy to ECR stage

```python
#For Private ECR Repo
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                  
#For Public ECR Repo Note: GetAuthorizationToken command is only supported in us-east-1.
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/l1i3r8d0
```
![Alt text](https://i.ibb.co/BcqSW44/Quick-start-Publishing-to-Amazon-ECR-Public-using-the-AWS-CLI-Amazon-ECR-Public-1.png "AWS warning")

## Kubernetes Usage
```python
#You can easily deploy the stack in Kubernetes by the following :
$ kubectl apply -f k8s/

#To get the running pods
$ kubectl get pods --watch -n nodetestapp

NAME               READY   STATUS    RESTARTS   AGE
mongodb            1/1     Running   0          48m
nodetestapp        1/1     Running   0          48m
```

## Helm Usage
[How to Install Helm](https://helm.sh/docs/intro/install/)
```python
#You can easily deploy Helm Chart the following :
$ helm install demochart nodetestapp-helm

```
## Terraform Usage
[How to Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
```python
#You can easily deploy EC2 with EBS by the following :
$ cd terraform 

$ terraform init
$ terraform plan
$ terraform apply

#To Delete the Stack
$ terraform destroy

```
**NOTE** : I didn't use AWS Key/Secret as the machine used to run terraform has an attached IAM role to provide the resources, but in case you are running from a machine outside AWS you can have Key/Secret in provider.tf, and also consider using Vault. 