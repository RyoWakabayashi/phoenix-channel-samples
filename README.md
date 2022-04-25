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
locust -f locustfile.py
```
