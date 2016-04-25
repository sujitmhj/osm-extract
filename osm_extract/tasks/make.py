from celery import shared_task
import subprocess
from django.conf import settings
import shlex

print settings.BASE_DIR

@shared_task(bind=True)
def make(self, event):
    cmd = "/usr/bin/make clean all COUNTRY=%s" % event.country_name
    args = shlex.split(cmd)
    print args
    make_process = subprocess.Popen(args, stderr=subprocess.STDOUT, cwd=settings.BASE_DIR)
    if make_process.wait() != 0:
        print "nope"
