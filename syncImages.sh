#!/bin/bash

OCMIRROR=/usr/local/bin/oc-mirror
TMPDIR=/registry/tmp
DATE=$(date +%Y%m%d-%H%M%S)
CONFIG=/root/imageset-config-4.11.yaml
REGISTRY=registry.clustername.example.com
NAMESPACE=namespace/repository

cd $TMPDIR

$OCMIRROR \
  --config $CONFIG \
  --dest-skip-tls \
  --continue-on-error \
  --skip-missing \
  --verbose 9 \
  docker://$REGISTRY/$NAMESPACE 2>&1 | tee $TMPDIR/mirror-$DATE.log
