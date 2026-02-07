FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl git openjdk-21-jre

RUN mkdir app
WORKDIR /app

RUN curl -o paper.jar https://fill-data.papermc.io/v1/objects/187989fbf71905b1fead292e5ff822fa6db90d0041092d3b85738648cad04ac5/paper-1.21.11-110.jar

RUN mkdir /app/data

COPY start.sh .
COPY src/ /app/data/

WORKDIR /app-data
ENTRYPOINT ["/bin/bash", "-c", "/app/start.sh"]
CMD ["/bin/bash"]
