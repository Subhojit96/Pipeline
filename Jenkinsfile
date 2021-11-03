pipeline{
    agent{
        label 'master'
    }
    tools{
        terraform "terraform"
    }
    options{
        timestamps()
        skipDefaultCheckout()
        timeout(time:5, unit:'MINUTES')
    }
    environment{
        ACCESS_KEY=credentials('AWS_ACCESS_KEY_ID')
        SECRET_KEY=credentials('AWS_SECRET_KEY_ID')
    }
    //stages
    stages{
        stage('checkout'){
            steps{
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Subhojit96/Pipeline.git']]])
            }
        }
        stage('Initialize')
        {
            steps{
                sh 'terraform init'
            }
        }
        stage('dry-run'){
            steps(){
                sh "terraform plan -out terraform.tfplan -var \"access_key=${env.ACCESS_KEY}\" -var \"secret_key=${SECRET_KEY}\" "
            }
        }
        stage('apply'){
            steps{
                sh 'terraform apply -auto-approve "terraform.tfplan"'
            }
        }
        stage('destroy'){
            steps{
                sh "terraform destroy -auto-approve -var \"access_key=${env.ACCESS_KEY}\" -var \"secret_key=${SECRET_KEY}\""
            }
        }
    }
}