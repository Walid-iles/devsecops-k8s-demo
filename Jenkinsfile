pipeline {
  agent any

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
                "Trivy Scan": {
                  sh "bash trivy-docker-image-scan.sh"
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
      stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#ge54rthq465e1ye8465/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh "kubectl apply -f k8s_deployment_service.yaml"
             }
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