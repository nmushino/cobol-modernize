#!/bin/bash
set -e

# ----------------------------
# 設定
# ----------------------------
APP_NAME=topic-viewer
PROJECT=demo
BASE_DIR=$(pwd)
DOCKER_CONTEXT_DIR=${BASE_DIR}/build
DOCKERFILE_SRC=${BASE_DIR}/src/main/docker/Dockerfile
QUARKUS_TARGET=${BASE_DIR}/target/quarkus-app

# ----------------------------
# OpenShift 確認
# ----------------------------
echo "===== OpenShift Login Check ====="
oc whoami

echo "===== Use Project ====="
oc new-project ${PROJECT} || oc project ${PROJECT}

# ----------------------------
# 古いBuild削除
# ----------------------------
echo "===== Delete old BuildConfig/ImageStream ====="
oc delete bc ${APP_NAME} || true
oc delete is ${APP_NAME} || true

# ----------------------------
# Quarkus Build
# ----------------------------
echo "===== Build Quarkus ====="
mvn clean package -DskipTests

# ----------------------------
# Build Context
# ----------------------------
echo "===== Prepare Build Context ====="
rm -rf ${DOCKER_CONTEXT_DIR}
mkdir -p ${DOCKER_CONTEXT_DIR}

cp ${DOCKERFILE_SRC} ${DOCKER_CONTEXT_DIR}/Dockerfile

mkdir -p ${DOCKER_CONTEXT_DIR}/quarkus-app
cp -r ${QUARKUS_TARGET}/* ${DOCKER_CONTEXT_DIR}/quarkus-app/

# ----------------------------
# BuildConfig
# ----------------------------
echo "===== Create BuildConfig ====="
oc new-build --name=${APP_NAME} --binary --strategy=docker

# ----------------------------
# Binary Build
# ----------------------------
echo "===== Start Build ====="
oc start-build ${APP_NAME} --from-dir=${DOCKER_CONTEXT_DIR} --follow

# ----------------------------
# Deploy
# ----------------------------
echo "===== Deploy Application ====="
if oc get deployment ${APP_NAME} >/dev/null 2>&1; then
    echo "Deployment exists"
else
    oc new-app ${APP_NAME}
fi

# ----------------------------
# Service / Route
# ----------------------------
echo "===== Expose Service ====="
oc expose deployment ${APP_NAME} --port=8080 --target-port=8080 || true
oc expose svc ${APP_NAME} || true

# ----------------------------
# Pod確認
# ----------------------------
echo "===== Pods ====="
oc get pods

POD=$(oc get pods -l app=${APP_NAME} -o name | head -n1)

if [ -n "$POD" ]; then
    echo "===== Logs ====="
    oc logs ${POD}
fi

# ----------------------------
# Cleanup
# ----------------------------
rm -rf ${DOCKER_CONTEXT_DIR}
rm -rf ${BASE_DIR}/Dockerfile

echo "===== DONE ====="
