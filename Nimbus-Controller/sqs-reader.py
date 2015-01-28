import boto.sqs
import argparse
from boto.sqs.message import Message
from subprocess import call

parser = argparse.ArgumentParser()
parser.add_argument("echo")
args = parser.parse_args()

conn = boto.sqs.connect_to_region("us-east-1",aws_access_key_id='AKIAINWVSI3MIXIB5N3Q',aws_secret_access_key='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')
my_queue = conn.get_queue(args.echo)

m = Message()


while True:
    m = my_queue.read(60)
    counter = my_queue.count()
    # print "Messages after read", counter , "This Messages = ", m.get_body()

    #This will run a command and check the return value
    return_code = call(['./do_work', str(m.get_body())])
    if return_code > 0:
	    print "message not deleted return code is = ", return_code
    else:
	    my_queue.delete_message(m)
	    print "message deleted from the queue "

