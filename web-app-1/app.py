from flask import Flask
from flask import request
import  http
import boto3
import json

app = Flask(__name__)


@app.route('/app1')
def hello_app1():
    return 'Hello, web {} - running version {}'.format(1, 2.0)


@app.route('/app1/send_queue')
def send_queue():
    try:
        user = request.args.get('user')
        print("sending {} details to queue".format(user))
        sqs = boto3.client('sqs', region_name='us-east-1')
        queue = sqs.get_queue_url(QueueName='sgx')
        message = {"user_name":user}
        sqs.send_message(QueueUrl=queue['QueueUrl'], MessageBody=json.dumps(message))

    except Exception as e:
        print("Error occured")
        return 500
    return "ok", http.HTTPStatus.CREATED.value

if __name__ == '__main__':
        app.run(debug=True, host='0.0.0.0')




