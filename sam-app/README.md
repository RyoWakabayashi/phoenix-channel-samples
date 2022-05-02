# Gatling による負荷試験

SAM のビルド

```bash
sam build
```

SAM のデプロイ

```bash
sam deploy \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides WSHost=<ホスト名> S3Bucket=<バケット名>
```

負荷試験の実行

```bash
aws lambda invoke \
  --function-name gatling-function \
  --invocation-type Event \
  lambda_result.json
```
