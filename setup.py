import os
from distutils.core import setup

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
    packages=['osm_extract',],
    include_package_data=True,
    zip_safe=False,
)
