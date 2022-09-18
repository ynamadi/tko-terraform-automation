pipeline {
    agent any
    stages {
        stage('Creating Service Principle & Updating Variables') {
            steps {
                sh './config.sh'
            }
        }
        stage('Initializing Terraform') {
            steps {
                sh 'docker run --rm -it -v $PWD:/data -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -w /data hashicorp/terraform:latest init -upgrade -var cluster_name=${env.CLUSTER_NAME} -var vmw_host=${env.HOST} -var vmw_api_token=${env.API_TOKEN}'
            }
        }
        stage('Evaluate Configuration') {
            steps {
                sh 'docker run --rm -it -v $PWD:/data -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -w /data hashicorp/terraform:latest plan -var cluster_name=${env.CLUSTER_NAME} -var vmw_host=${env.HOST} -var vmw_api_token=${env.API_TOKEN}'
            }
        }
        stage('Deploy an AKS Cluster & Attach to TMC') {
            steps {
                sh 'docker run --rm -it -v $PWD:/data -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -w /data hashicorp/terraform:latest apply --auto-approve -var cluster_name=${env.CLUSTER_NAME} -var vmw_host=${env.HOST} -var vmw_api_token=${env.API_TOKEN}'
            }
        }
        stage('Destroy AKS Cluster & Detach to TMC') {
            steps {
                sh 'docker run --rm -it -v $PWD:/data -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -w /data hashicorp/terraform:latest destroy --auto-approve -var cluster_name=${env.CLUSTER_NAME} -var vmw_host=${env.HOST} -var vmw_api_token=${env.API_TOKEN}'
            }
        }
    }
}
