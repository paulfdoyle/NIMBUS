import boto.sqs
import argparse
import urllib
import os
import sys
import signal
import time
import datetime
import socket
import fcntl
import struct
from boto.sqs.message import Message
from subprocess import call
import boto.s3.connection
from boto.s3.connection import S3Connection
from boto.s3.connection import Location
from boto.s3.key import Key


conn = S3Connection('AKIAINWVSI3MIXIB5N3Q', 'p5YZH9h2x6Ua+5D2qC+p4HFUHQZRVo94J9zrOE+c')
bucket=conn.get_bucket('nimbus-results1')

bucketListResultSet = bucket.list()
result = bucket.delete_keys([key.name for key in bucketListResultSet])
