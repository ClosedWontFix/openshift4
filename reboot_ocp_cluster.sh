#!/bin/bash

#============================================================================#
#
# File: reboot_ocp_cluster.sh
#
# Author: ClosedWontFix
# Email: closedwontfix@protonmail.com
#
# This script is offered as reference only.
# No warranty is expressed or implied.  
# Use at your own risk.
# 
# Description: Somewhat graceful rolling reboot of OCP 4 cluster.
#
# Created: 07-19-2022
#
#============================================================================#

#Are you logged into a OCP cluster?
oc whoami > /dev/null 2>&1
if [[ $? != '0' ]]; then
  echo
  echo "You are not authenticated to an OpenShift cluster."
  echo "Goodbye."
  echo
  exit
fi

MASTER_NODES=$(oc get nodes -l node-role.kubernetes.io/master -o jsonpath='{.items[*].metadata.name}{"\n"}')
MASTER_SLEEP=300
OCS_NODES=$(oc get nodes -l cluster.ocs.openshift.io/openshift-storage= -o jsonpath='{.items[*].metadata.name}{"\n"}')
OCS_SLEEP=180
INFRA_NODES=$(oc get nodes -l node-role.kubernetes.io/infra,cluster.ocs.openshift.io/openshift-storage!= -o jsonpath='{.items[*].metadata.name}{"\n"}')
INFRA_SLEEP=45
WORKER_NODES=$(oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[*].metadata.name}{"\n"}')
WORKER_SLEEP=45

# Reboot master nodes
for node in ${MASTER_NODES}; do
  echo "Rebooting ${node}..."
  ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot"
  #Need to update this script to drain nodes before rebooting nodes
  #oc adm drain ${node} --ignore-daemonsets --delete-emptydir-data
  #oc debug node/${node} -- chroot /host reboot
  #oc adm uncordon ${node}
  echo
  echo "Sleeping for ${MASTER_SLEEP} seconds."
  echo "Current system time is $(date +'%T %Z')"
  echo
  echo "---"
  echo
  sleep ${MASTER_SLEEP}
done

# Reboot ocs nodes
if [[ -n ${OCS_NODES} ]]; then
  for node in ${OCS_NODES}; do
    echo "Rebooting ${node}..."
    ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot"
    #oc debug node/${node} -- chroot /host reboot
    echo
    echo "Sleeping for ${OCS_SLEEP} seconds."
    echo "Current system time is $(date +'%T %Z')"
    echo
    echo "---"
    echo
    sleep ${OCS_SLEEP}
  done
else
  echo "No OCS/ODF nodes were detected.  Moving on."
fi

# Reboot infra nodes
if [[ -n ${INFRA_NODES} ]]; then
  for node in ${INFRA_NODES}; do
    echo "Rebooting ${node}..."
    ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot"
    #oc debug node/${node} -- chroot /host reboot
    echo
    echo "Sleeping for ${INFRA_SLEEP} seconds."
    echo "Current system time is $(date +'%T %Z')"
    echo
    echo "---"
    echo
    sleep ${INFRA_SLEEP}
  done
else
  echo "No infra nodes were detected.  Moving on."
fi

# Reboot worker nodes
if [[ -n ${WORKER_NODES} ]]; then
  for node in ${WORKER_NODES}; do
    echo "Rebooting ${node}..."
    ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot"
    #oc debug node/${node} -- chroot /host reboot
    echo
    echo "Sleeping for ${WORKER_SLEEP} seconds."
    echo "Current system time is $(date +'%T %Z')"
    echo
    echo "---"
    echo
    sleep ${WORKER_SLEEP}
  done
else
  echo "No worker nodes were detected.  Moving on."
fi

echo "Cluster reboot completed.  Please perform health checks."
echo
