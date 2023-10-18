FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN addgroup -S devops-security && adduser -S devsecops -G devops-security
COPY ${JAR_FILE} /home/devsecops/app.jar
USER devsecops
ENTRYPOINT ["java","-jar","/home/devsecops/app.jar"]