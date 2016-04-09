#!/bin/bash

SCRIPT=$0
while readlink ${SCRIPT} ; do
  SCRIPT=`readlink ${SCRIPT}`
done

cd `dirname ${SCRIPT}`

git fetch origin || exit 1


for uline in `getent passwd` ; do
  U=`echo ${uline} | cut -d : -f 1`
  H=`echo ${uline} | cut -d : -f 6`
  if [ "${U}" == "root" ] ; then
    continue
  fi
  KEYS="${H}/.ssh/authorized_keys"
  if [ ! -f ${KEYS} ] ; then
    continue
  fi
  if [ ! -f users/${U} ] ; then
    mv ${KEYS} ${KEYS}.disabled
  fi
  cp users/${U} ${KEYS}
done
