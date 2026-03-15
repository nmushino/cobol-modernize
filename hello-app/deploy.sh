#!/bin/bash

set -e

APP_NAME=cobol-app
PROJECT=cobol-demo

echo "===== OpenShift Login Check ====="
oc whoami

echo "===== Use Project ====="
oc project ${PROJECT}

echo "===== Check BuildConfig ====="

if oc get bc ${APP_NAME} >/dev/null 2>&1
then
  echo "BuildConfig already exists"
else
  echo "Creating BuildConfig..."
  oc new-build --name=${APP_NAME} --binary --strategy=docker
fi

echo "===== Start Binary Build ====="
oc start-build ${APP_NAME} --from-dir=. --follow

echo "===== Deploy Application ====="

if oc get deployment ${APP_NAME} >/dev/null 2>&1
then
  echo "Deployment already exists"
else
  oc new-app ${APP_NAME}
fi

echo "===== Pods ====="
oc get pods

echo "===== Logs ====="
POD=$(oc get pods -o name | grep ${APP_NAME} | head -n1)
oc logs ${POD} || true

echo "===== DONE ====="