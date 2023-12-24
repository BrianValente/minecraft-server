FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl git openjdk-21-jre

RUN mkdir app
WORKDIR /app

RUN curl -o paper.jar https://api.papermc.io/v2/projects/paper/versions/1.20.2/builds/318/downloads/paper-1.20.2-318.jar

RUN mkdir /app/data

COPY start.sh .
COPY src/ /app/data/

WORKDIR /app-data
ENTRYPOINT ["/bin/bash", "-c", "/app/start.sh"]
CMD ["/bin/bash"]
