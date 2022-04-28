# phoenix-channel-samples

PhoenixChannel のサンプルコード

## 負荷試験

チャットサーバー起動

```bash
cd react_chat
mix phx.server
```

別ターミナルで Locust 起動

```bash
export LOCUST_ENDPOINT="localhost:4000"
locust -f locustfile.py
```

### コンテナで負荷試験

- Locust

  ```bin
  export LOCUST_ENDPOINT="<ホスト名:ポート番号>"
  docker build -f Dockerfile_locust -t locust .
  docker run -it --rm -p 8089:8089 -e LOCUST_ENDPOINT locust
  ```

- Gatling

  ```bin
  export WS_HOST="<ホスト名:ポート番号>"
  docker build -f Dockerfile_gatling -t gatling .
  docker run -it --rm -e WS_HOST gatling
  ```

## AWS Copilot

### 必要なツール

[AWS Copilot CLI][copilot]

### 必要な IAM パーミッション

以下のような IAM パーミッション（推定）を持つユーザーで実行する

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Fulls",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
                "cloudtrail:LookupEvents",
                "codebuild:ListProjects",
                "codestar-connections:CreateConnection",
                "codestar-connections:ListConnections",
                "codestar-connections:PassConnection",
                "codestar-connections:TagResource",
                "codestar-connections:UntagResource"
                "iam:*",
                "ec2:*",
                "ecr:*",
                "ecs:CreateCluster",
                "s3:*",
                "secretsmanager:DescribeSecret",
                "servicediscovery:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECRCreateRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.ecr.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "CodeStarConnections",
            "Effect": "Allow",
            "Action": [
                "codestar-connections:DeleteConnection",
                "codestar-connections:GetConnection"
            ],
            "Resource": [
                "arn:aws:codestar-connections:*:<アカウントID>:connection/*"
            ]
        },
        {
            "Sid": "CodeBuild",
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateProject",
                "codebuild:DeleteProject",
                "codebuild:UpdateProject"
            ],
            "Resource": [
                "arn:aws:codebuild:*:<アカウントID>:project/*"
            ]
        },
        {
            "Sid": "ECS",
            "Effect": "Allow",
            "Action": [
                "ecs:DeleteCluster",
                "ecs:DescribeClusters"
            ],
            "Resource": "arn:aws:ecs:*:<アカウントID>:cluster/*"
        },
        {
            "Sid": "SSM",
            "Effect": "Allow",
            "Action": [
                "ssm:DeleteParameter",
                "ssm:DeleteParameters",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath",
                "ssm:PutParameter"
            ],
            "Resource": "arn:aws:ssm:*:<アカウントID>:parameter/*"
        },
        {
            "Sid": "STS",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::<アカウントID>:role/*"
        }
    ]
}
```

### Copilot による AWS 環境構築

アプリケーションの初期化

```bash
copilot app init
```

いくつかの質問に答える

App Runner は Web Sockets に対応していないため、
Web Socket が必要な場合は Load Balancer を使用する必要がある

AWS App Runner でサービスを構築する場合、
App Runner 内のサービス名が
`<Copilot のアプリケーション名>-<Copilot の環境名>-<Copilot のサービス名>`
になる

App Runner 内のサービス名は 40 文字が上限なので、
Copilot 上のサービス名は `main-svc` などの短い名前にする

環境は別途作成するため、ここでは作成しない

環境作成時は `--container-insights` を指定し、 Container Insights を有効にする

```bash
copilot env init --container-insights
```

以下のコマンドでデプロイする

```bash
copilot svc deploy --env <環境名>
```

以下のコマンドでログを取得する

`--follows` でログを監視する

```bash
copilot svc logs --follow
```

負荷試験を実行する場合、デプロイ完了時に表示されるホスト名を指定する

```bash
export LOCUST_ENDPOINT="<Copilot でデプロイした環境のホスト名>"
locust -f locustfile.py
```

以下のコマンドでアプリケーションを削除する

```bash
copilot app delete
```

#### リソースの調節

copilot/sample-service/manifest.yml の `cpu` と `memory` を変更することで、
コンテナに割り当てるリソースを調整することができる

[ただし、設定できる値の組み合わせには制限がある][resource]

```yml
cpu: 512       # Number of CPU units for the task.
memory: 1024    # Amount of memory in MiB used by the task.
```

[copilot]: https://aws.github.io/copilot-cli/ja/
[resource]: [https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task-cpu-memory-error.html]
