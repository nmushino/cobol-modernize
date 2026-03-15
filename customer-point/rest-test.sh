#!/bin/bash
NAMESPACE=demo
APP_NAME=customer-point-api

# Route のホスト名を取得
ROUTE_HOST=$(oc get route $APP_NAME -n $NAMESPACE -o jsonpath='{.spec.host}')

# Route URL を作成
ROUTE_URL="http://$ROUTE_HOST/customerpoint"

echo "Route URL: $ROUTE_URL"

# curl でアクセス
curl -X POST "$ROUTE_URL" -H "Content-Type: text/plain" -d "1000"