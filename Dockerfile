FROM tomcat:9-jdk17-temurin
# Clean default webapps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy our WAR as ROOT.war so it serves at '/'
COPY target/myapp.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
