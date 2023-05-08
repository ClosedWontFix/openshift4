#!/bin/bash

OCMIRROR=/usr/local/bin/oc-mirror
# Set temp directory - Need ~5GB free space
TMPDIR=/registry/tmp
DATE=$(date +%Y%m%d-%H%M%S)
CONFIG=/root/imageset-config.yaml
REGISTRY=registry.example.com:5000
NAMESPACE=registry
# Set verbosity (0-9)
VERBOSE=0

[[ -d ${TMPDIR} ]] || mkdir ${TMPDIR}
cd ${TMPDIR}

time \
${OCMIRROR} \
  --config ${CONFIG} \
  --dest-skip-tls \
  --source-skip-tls \
  --skip-missing \
  --continue-on-error \
  --verbose ${VERBOSE} \
  docker://${REGISTRY}/${NAMESPACE} 2>&1 | tee ${TMPDIR}/mirror-${DATE}.log
