import boto3

sqs = boto3.resource("sqs","us-east-1")

sqs_queue= sqs.get_queue_by_name(QueueName="sgx")

def process_message(message_body):
    print(f"processing message: {message_body}")
    # do what you want with the message here
    pass

if __name__ == "__main__":
    while True:
        messages = sqs_queue.receive_messages()
        for message in messages:
            process_message(message.body)
            print(message)
            message.delete()