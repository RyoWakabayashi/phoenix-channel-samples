# -*- coding:utf-8 -*-
from __future__ import absolute_import
from __future__ import unicode_literals
from __future__ import print_function

import os

import json
import uuid
import time
import gevent

from websocket import create_connection
import six

from locust import HttpUser, TaskSet, task
from locust import events

ENDPOINT = os.environ['LOCUST_ENDPOINT']


class ChatTaskSet(TaskSet):
    def on_start(self):
        self.user_id = six.text_type(uuid.uuid4())
        self.connect()
        self.join()

    def on_stop(self):
        self.leave()

    def connect(self):
        ws = create_connection(
            f"ws://{ENDPOINT}/socket/websocket?token=undefined&vsn=2.0.0")
        self.ws = ws

    def join(self):
        body = json.dumps(
            ["3", "3", "room:lobby", "phx_join", {"user_name": self.user_id}])
        self.ws.send(body)

    def leave(self):
        self.ws.close()

    @task
    def sent(self):
        start_at = time.time()
        body = json.dumps(
            ["3", "4", "room:lobby", "new_msg", {"msg": "hello"}])
        self.ws.send(body)
        events.request_success.fire(
            request_type='WebSocket Sent',
            name='test/ws/chat',
            response_time=int((time.time() - start_at) * 1000000),
            response_length=len(body),
        )
        time.sleep(1)


class ChatLocust(HttpUser):
    tasks = [ChatTaskSet]
    min_wait = 500
    max_wait = 1000
