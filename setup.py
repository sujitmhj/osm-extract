import os
from distutils.core import setup
from setuptools import setup, find_packages

def read(*rnames):
    return open(os.path.join(os.path.dirname(__file__), *rnames)).read()

setup(
    name="osm-extract",
    version="0.1",
    author="",
    author_email="",
    description="osm-extract",
    long_description=(read('README.md')),
    # Full list of classifiers can be found at:
    # http://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        'Development Status :: 1 - Planning',
    ],
    license="BSD",
    keywords="openstreetmap osm",
    url='https://github.com/terranodo/osm-extract',
    packages=find_packages(),
    install_requires=[
        'django==1.8.12',
        'celery==3.1.19',
        'django-celery',
    ],
    include_package_data=True,
    zip_safe=False,
)
