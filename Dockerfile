FROM maven:3-jdk-8-alpine AS build

WORKDIR /app


# this will copy  the spring code to the container /app folder
COPY pom.xml .
COPY src ./src


# this will install all dependency to compile our spring  code later on 
RUN mvn dependency:go-offline -B && mvn clean package -DskipTests

# i used light weight image that will only contain the jar file
FROM openjdk:8-jre-slim   

# Set the working directory to /app
WORKDIR /app

# it is recomended to use non-root user as a security reasons 
RUN useradd -m spring && chown -R spring:spring /app

# this will copy the code from the image labeled `build` into this image 
# and this is in fact the advantages of multistage. all the maven dependencies installed previously 
# are not figuring out in this last image

COPY --from=build /app/target/*.jar app.jar

# changing user of the container to spring

USER spring

# by default spring expose 8080 port, so there is no need to use the port 5000, as well you asked 
#  to export k8s service in 8080. therefore no need to play with ports 

EXPOSE 8080


CMD ["java", "-jar", "app.jar"]
