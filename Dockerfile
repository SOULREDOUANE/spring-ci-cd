# i  used maven of jdk17 docker image as the java 8 is not scaned. assuming it my contains more vurnabelities 
# the other reason the application is coded in java 8 which so java 8 or heigher is fine
FROM maven:3-jdk-8-alpine AS build

# Set the working directory in the container
WORKDIR /app


# this will copy  the spring code to the container /app folder
COPY pom.xml .
COPY src ./src


# this will install all dependency to compile our spring  code later on 
RUN mvn dependency:go-offline -B && mvn clean package -DskipTests

# i used light weight image that will only containe the jar file
FROM openjdk:8-jre-slim   

# it is recomended to use non-root user as a security reasons 
RUN useradd -m spring && chown -R spring:spring /app

# Set the working directory to /app
WORKDIR /app

# this will copy the code from the image labeled `build` into this image 
# and this is in fact the advantages of multistage. all the maven dependencies installed previously 
# are not figuring out in this last image
COPY --from=build /app/target/*.jar app.jar

# give ing ownership of the /app folder to the `spring` user we created

USER spring

# by default spring expose 8080 port, so there is no need to use the port 5000, as well you asked 
#  to export k8s service in 8080. therefore no need to play with ports 
EXPOSE 8080


CMD [ "sh", "-c", "mvn -Dserver.port=${PORT} spring-boot:run" ]
