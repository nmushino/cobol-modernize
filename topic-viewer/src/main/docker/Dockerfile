# ----------------------------
# Base: UBI9 + OpenJDK 21
# ----------------------------
FROM registry.access.redhat.com/ubi9/openjdk-21-runtime

WORKDIR /work/

COPY quarkus-app/lib/ /deployments/lib/
COPY quarkus-app/*.jar /deployments/
COPY quarkus-app/app/ /deployments/app/
COPY quarkus-app/quarkus/ /deployments/quarkus/

EXPOSE 8080

CMD ["java","-jar","/deployments/quarkus-run.jar"]