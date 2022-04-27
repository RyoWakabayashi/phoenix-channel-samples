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
            "Sid": "IAMAll",
            "Effect": "Allow",
            "Action": [
                "iam:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3All",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECRAll",
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "cloudtrail:LookupEvents"
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
            "Sid": "CloudFormation",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "EC2All",
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*"
        },
        {
            "Sid": "ECSTarget",
            "Effect": "Allow",
            "Action": [
                "ecs:DeleteCluster",
                "ecs:DescribeClusters"
            ],
            "Resource": "arn:aws:ecs:*:<アカウントID>:cluster/*"
        },
        {
            "Sid": "ECSCreate",
            "Effect": "Allow",
            "Action": "ecs:CreateCluster",
            "Resource": "*"
        },
        {
            "Sid": "CloudMap",
            "Effect": "Allow",
            "Action": [
                "servicediscovery:TagResource",
                "servicediscovery:ListServices",
                "servicediscovery:ListOperations",
                "servicediscovery:GetOperation",
                "servicediscovery:DiscoverInstances",
                "servicediscovery:ListNamespaces",
                "servicediscovery:CreatePrivateDnsNamespace",
                "servicediscovery:CreateHttpNamespace",
                "servicediscovery:CreatePublicDnsNamespace",
                "servicediscovery:UntagResource",
                "servicediscovery:ListTagsForResource",
                "servicediscovery:GetInstancesHealthStatus",
                "servicediscovery:GetInstance",
                "servicediscovery:UpdateInstanceCustomHealthStatus",
                "servicediscovery:ListInstances"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CloudMapAll",
            "Effect": "Allow",
            "Action": "servicediscovery:*",
            "Resource": [
                "arn:aws:servicediscovery:*:<アカウントID>:service/*",
                "arn:aws:servicediscovery:*:<アカウントID>:namespace/*"
            ]
        },
        {
            "Sid": "SSM",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssm:PutParameter",
                "ssm:DeleteParameter",
                "ssm:DeleteParameters"
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
