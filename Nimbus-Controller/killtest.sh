#!/bin/bash

kill $(ps aux | grep '[p]ython sqs-fastlogreader.py' | awk '{print $2}')
