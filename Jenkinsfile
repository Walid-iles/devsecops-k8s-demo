pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "ge54rthq465e1ye8465/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://devsecops-demo.eastus.cloudapp.azure.com/" 
    applicationURI = "/increment/99"
}


  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }           

      stage('Unit Tests - JUnit and Jacoco') {
            steps {
              sh "mvn test" 
            }
            
        }

      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            
          }
     

      stage('Vulnerability Scan - Docker ') {
            steps {
              parallel(
                "Dependency Scan": {
                  sh "mvn dependency-check:check"
                },
                //"Trivy Scan": {
                //  sh "bash trivy-docker-image-scan.sh"
                //},
                "OPA Conftest": {
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
                }
              )
            }
            
          }


      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]){
              sh 'printenv'
              sh 'docker build -t ge54rthq465e1ye8465/numeric-app:""$GIT_COMMIT"" .' 
              sh 'docker push ge54rthq465e1ye8465/numeric-app:""$GIT_COMMIT""'
            }
           } 
        }


      stage('Vulnerability Scan - Kubernetes') {
        steps {
          parallel(
            "OPA Scan": {
              sh '/usr/local/bin/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            },
            "Kubesec Scan": {
              sh "bash kubesec-scan.sh"
            },
            "Trivy Scan": {
              sh "bash trivy-k8s-scan.sh"
            }
          )
        }
    }
     

      stage('K8S Deployment - DEV') {
        steps {
          parallel(
            "Deployment": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment.sh"
              }
            },
            "Rollout Status": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment-rollout-status.sh"
            }
          }
        )
      }
    }

    
        
    }

    post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
              }
            }
}