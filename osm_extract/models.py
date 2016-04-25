from django.db import models
from django.conf import settings
from tasks.make import make 
from django.db.models import signals

class Event(models.Model):

    name = models.CharField(unique=True, max_length=30)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    bbox = models.TextField(blank=True)
    country_name = models.TextField(max_length=30, blank=True, null=True)
    pbf_url = models.URLField(null=True, blank=True)


def event_post_save(instance, *args, **kwargs):
    print "here"
    make.delay(instance)


signals.post_save.connect(event_post_save, sender=Event) 
