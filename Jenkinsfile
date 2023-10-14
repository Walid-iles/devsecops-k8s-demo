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
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }

      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
          }
      stage('SonarQube - SAST') {
            steps {
              withSonarQubeEnv('My SonarQube Server') {
                sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://devsecops-demon.eastus.cloudapp.azure.com:9000 -Dsonar.token=sqp_7fab56f5ac3121f7bcc5aa9c652a76c6b0b18ba0"
              }
              timeout(time: 1, unit: 'MINUTES') {
                  script{
                    waitForQualityGate abortPipeline: true
                  }
                 }
                }
             }
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
}