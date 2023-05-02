#!/bin/bash

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
OCS_NODES=$(oc get nodes -l cluster.ocs.openshift.io/openshift-storage= -o jsonpath='{.items[*].metadata.name}{"\n"}')
INFRA_NODES=$(oc get nodes -l node-role.kubernetes.io/infra,cluster.ocs.openshift.io/openshift-storage!= -o jsonpath='{.items[*].metadata.name}{"\n"}')
WORKER_NODES=$(oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[*].metadata.name}{"\n"}')

# Reboot master nodes
for node in ${MASTER_NODES}; do
  echo "Attempting to drain ${node}..."
  oc adm drain ${node} --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
  if [[ $? -eq 0 ]]; then
                ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot" > /dev/null 2>&1
                #Need to update this script to drain nodes before rebooting nodes
                #oc debug node/${node} -- chroot /host reboot
                sleep 180
                oc adm uncordon ${node} > /dev/null 2>&1
                echo
                until ping -c 1 -t 1 ${node} > /dev/null 2>&1; do
                        sleep 120
                done
        else
                echo "${node} failed to drain."
                exit
        fi
done

# Reboot ocs nodes
if [[ -n ${OCS_NODES} ]]; then
  for node in ${OCS_NODES}; do
                echo "Attempting to drain ${node}..."
    oc adm drain ${node} --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
    if [[ $? -eq 0 ]]; then
                        ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot" > /dev/null 2>&1
                        #oc debug node/${node} -- chroot /host reboot
                        sleep 180
                        oc adm uncordon ${node} > /dev/null 2>&1
                        echo
                        until ping -c 1 -t 1 ${node} > /dev/null 2>&1; do
                                sleep 120
                        done
                else
                        echo "${node} failed to drain."
                        exit
                fi
  done
else
  echo "No OCS/ODF nodes were detected.  Moving on."
fi

# Reboot infra nodes
if [[ -n ${INFRA_NODES} ]]; then
  for node in ${INFRA_NODES}; do
                echo "Attempting to drain ${node}..."
    oc adm drain ${node} --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
    if [[ $? -eq 0 ]]; then
                        ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot" > /dev/null 2>&1
                        #oc debug node/${node} -- chroot /host reboot
                        sleep 120
                        oc adm uncordon ${node} > /dev/null 2>&1
                        echo
                        until ping -c 1 -t 1 ${node} > /dev/null 2>&1; do
                                sleep 60
                        done
                else
                        echo "${node} failed to drain."
                        exit
                fi
  done
else
  echo "No infra nodes were detected.  Moving on."
fi

# Reboot worker nodes
if [[ -n ${WORKER_NODES} ]]; then
  for node in ${WORKER_NODES}; do
                echo "Attempting to drain ${node}..."
    oc adm drain ${node} --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
    if [[ $? -eq 0 ]]; then
                        ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot" > /dev/null 2>&1
                        #oc debug node/${node} -- chroot /host reboot
                        sleep 60
                        oc adm uncordon ${node} > /dev/null 2>&1
                        echo
                        until ping -c 1 -t 1 ${node} > /dev/null 2>&1; do
                                sleep 60
                        done
                else
                        echo "${node} failed to drain."
                        exit
                fi
  done
else
  echo "No worker nodes were detected.  Moving on."
fi

echo "Cluster reboot completed.  Please perform health checks."
echo
