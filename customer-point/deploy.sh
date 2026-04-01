#!/bin/bash
set -e

# ----------------------------
# 設定
# ----------------------------
APP_NAME=customer-point-api
PROJECT=demo
BASE_DIR=$(pwd)                        # スクリプト実行ディレクトリ
DOCKER_CONTEXT_DIR=${BASE_DIR}/build   # ビルド用一時ディレクトリ
DOCKERFILE_SRC=${BASE_DIR}/src/main/docker/Dockerfile
COBOL_SRC=${BASE_DIR}/cobol-resources/customer-point.cbl
QUARKUS_TARGET=${BASE_DIR}/target/quarkus-app

# ----------------------------
# OpenShift プロジェクト確認
# ----------------------------
echo "===== OpenShift Login Check ====="
oc whoami

echo "===== Use Project ====="
oc new-project ${PROJECT} || oc project ${PROJECT}

# ----------------------------
# 古い BuildConfig / ImageStream 削除
# ----------------------------
echo "===== Delete old BuildConfig and ImageStream (if any) ====="
oc delete bc ${APP_NAME} || true
oc delete is ${APP_NAME} || true

# ----------------------------
# ビルド用ディレクトリ作成 & ファイルコピー
# ----------------------------
echo "===== Build Quarkus App ====="
mvn clean package -DskipTests

echo "===== Prepare build context ====="
rm -rf ${DOCKER_CONTEXT_DIR}
mkdir -p ${DOCKER_CONTEXT_DIR}

# Dockerfile と COBOL ソースをコピー
cp ${DOCKERFILE_SRC} ${DOCKER_CONTEXT_DIR}/Dockerfile
cp ${COBOL_SRC} ${DOCKER_CONTEXT_DIR}/customer-point.cbl
cp entrypoint.sh ${DOCKER_CONTEXT_DIR}/entrypoint.sh

# Quarkus の成果物をコピー（必要なら）
if [ -d "${QUARKUS_TARGET}" ]; then
    mkdir -p ${DOCKER_CONTEXT_DIR}/quarkus-app
    cp -r ${QUARKUS_TARGET}/* ${DOCKER_CONTEXT_DIR}/quarkus-app/
fi

# Quarkus アプリをコンテキストにコピー
if [ -d "target/quarkus-app" ]; then
    mkdir -p ${DOCKER_CONTEXT_DIR}/target
    cp -r target/quarkus-app ${DOCKER_CONTEXT_DIR}/target/
fi

# .dockerignore を一時退避
if [ -f "${DOCKER_CONTEXT_DIR}/.dockerignore" ]; then
    mv ${DOCKER_CONTEXT_DIR}/.dockerignore ${DOCKER_CONTEXT_DIR}/.dockerignore.bak
fi

# ----------------------------
# BuildConfig 作成
# ----------------------------
echo "===== Create BuildConfig (binary build using Dockerfile) ====="
oc new-build --name=${APP_NAME} --binary --strategy=docker

# ----------------------------
# Binary Build 実行
# ----------------------------
echo "===== Start Binary Build ====="
oc start-build ${APP_NAME} --from-dir=${DOCKER_CONTEXT_DIR} --follow

# ----------------------------
# Deployment
# ----------------------------
echo "===== Deploy Application ====="

# Build 完了後のイメージ名を取得
IMAGE_NAME=$(oc get istag ${APP_NAME}:latest -o jsonpath='{.image.dockerImageReference}')

# 既存 Deployment がある場合は削除（selector 修正のため）
if oc get deployment ${APP_NAME} >/dev/null 2>&1; then
    echo "Deployment already exists, deleting to update labels"
    oc delete deployment ${APP_NAME}
fi

# Deployment YAML を一時作成して適用
DEPLOY_YAML=$(mktemp)

cat <<EOF > ${DEPLOY_YAML}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
      deployment: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
        deployment: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: ${IMAGE_NAME}
        ports:
        - containerPort: 8080
EOF

oc apply -f ${DEPLOY_YAML}
rm -f ${DEPLOY_YAML}

# ----------------------------
# Pod 状態確認 & ログ取得
# ----------------------------
echo "===== List Pods ====="
oc get pods

POD=$(oc get pods -l app=${APP_NAME} -o name | head -n1)

if [ -n "$POD" ]; then
    echo "===== Show Logs ====="
    oc logs ${POD} || true
else
    echo "No pod found for app ${APP_NAME}"
fi

# ----------------------------
# サービスとRouteの作成
# ----------------------------
# Service selector と Pod ラベルを合わせる
if oc get svc ${APP_NAME} >/dev/null 2>&1; then
    echo "Service already exists, updating selector"
    oc patch svc ${APP_NAME} -p '{"spec":{"selector":{"app":"'"${APP_NAME}"'","deployment":"'"${APP_NAME}"'"}}}'
else
    oc expose deployment ${APP_NAME} --port=8080 --target-port=8080 -n ${PROJECT}
fi

oc expose svc/${APP_NAME} -n ${PROJECT}

# ----------------------------
# 後片付け
# ----------------------------
echo "===== Clean up temporary files ====="
rm -rf ${DOCKER_CONTEXT_DIR}
rm -rf ${BASE_DIR}/Dockerfile
rm -rf ${BASE_DIR}/customer-point.cbl

echo "===== DONE ====="