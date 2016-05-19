import os
from celery import shared_task
import subprocess
from django.conf import settings
import shlex
import osm_extract

@shared_task
def make(name, url):
    cwd = os.path.join(os.path.dirname(osm_extract.__file__), '../')
    cmd = "/usr/bin/make clean all NAME=%s URL=%s" % (name, url)
    args = shlex.split(cmd)
    print args
    make_process = subprocess.Popen(args, stderr=subprocess.STDOUT, cwd=cwd)
    if make_process.wait() != 0:
        print "nope"
