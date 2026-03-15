# cobol-modernize
GunCobolのコンテナ化とKafka対応のデモ

## hello-app
Cobolコンテナサンプル
GnuCobolのコンテナを作成してOpenShift上にデプロイするデモ

### 実行
./deploy.sh コンテナのビルドとOpenShiftへのデプロイ

## customer-point
Cobolコンテナをモダナイズしたデモ

* GnuCobolのコンテナはそのまま活かし、QuarkusによるREST APIでラップする。
* GnuCobolのコンテナはそのまま活かし、QuarkusによるKafkaIFでラップする。

### 実行
./kafka.sh Cobolコンテナ用のKafkaオペレータとTopicの作成
./deploy.sh CobolコンテナアプリをビルドしOpenShiftにデプロイする
./rest-test.sh CobolアプリのRestテストクライアント
./topic.sh Cobolアプリを動作させるためのKafkaクライアント

### 実行（オプション）
./connectivity-link.sh  CobolコンテナのREST APIをAPIGateway化する
./restgw-test.sh CobolアプリのAPIGateway経由でのRestテストクライアント

## customer-point
Topicを表示するJavaアプリ

### 実行
./viewer-deploy.sh Topic表示のJavaアプリをOpenShiftにデプロイする
