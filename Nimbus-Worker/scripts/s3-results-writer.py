import boto
import boto.s3.connection
from boto.s3.connection import S3Connection
from boto.s3.connection import Location
from boto.s3.key import Key

access_key = 'AKIAINWVSI3MIXIB5N3Q'
secret_key = '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'

conn = S3Connection('AKIAINWVSI3MIXIB5N3Q', 'p5YZH9h2x6Ua+5D2qC+p4HFUHQZRVo94J9zrOE+c')
bucket=conn.get_bucket('nimbus-results1')
k = Key(bucket)
k.key = 'myfile'
k.set_contents_from_filename('./upgradeworker.sh')

#bucket = conn.create_bucket('nimbus-results1', location=Location.EU)


#conn = boto.connect_s3(
#        aws_access_key_id = access_key,
#        aws_secret_access_key = secret_key,
#        host = 'objects.dreamhost.com',
#        is_secure=False,               # uncommmnt if you are not using ssl
#        calling_format = boto.s3.connection.OrdinaryCallingFormat(),
#        )
#buckets = conn.get_all_buckets()
#for bucket in conn.get_all_buckets():
#x.        print "{name}\t{created}".format(
#                name = bucket.name,
#                created = bucket.creation_date,
#        )
