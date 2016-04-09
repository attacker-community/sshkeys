#!/bin/bash

SCRIPT=$0
while readlink ${SCRIPT} ; do
  SCRIPT=`readlink ${SCRIPT}`
done

cd `dirname ${SCRIPT}`

git fetch origin || exit 1

if [ `git rev-parse master` == `git rev-parse origin/master` ] ; then
  return 0
fi
git merge origin/master

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
done

for key in users/* ; do
  U=`basename ${key}`
  if ! getent passwd ${U} ; then
    adduser --disabled-password --gecos "created by manage.sh" ${U}
  fi
  H=`getent passwd ${U} | cut -d : -f 6`
  mkdir -p ${H}/.ssh
  chown ${U} ${H}/.ssh
  chmod 700 ${H}/.ssh
  cp ${key} ${H}/.ssh/authorized_keys
done
