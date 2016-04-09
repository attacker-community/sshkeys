#!/bin/bash

set -o errexit nounset

SCRIPT=$0
while readlink ${SCRIPT} ; do
  SCRIPT=`readlink ${SCRIPT}`
done

cd `dirname ${SCRIPT}`

if [ $1 == "install" ] ; then
  ln -s ${SCRIPT} /etc/cron.hourly/update-users
else
  git fetch origin >/dev/null 2>&1 || exit 1

  if [ `git rev-parse master` == `git rev-parse origin/master` ] ; then
    exit 0
  fi
  git merge origin/master >/dev/null 2>&1
fi

getent passwd | while read uline ; do
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
  if ! getent passwd ${U} >/dev/null 2>&1 ; then
    adduser --disabled-password --gecos "created by manage.sh" ${U}
    getent group sshusers >/dev/null 2>&1 && adduser ${U} sshusers
  fi
  H=`getent passwd ${U} | cut -d : -f 6`
  mkdir -p ${H}/.ssh
  chown ${U} ${H}/.ssh
  chmod 700 ${H}/.ssh
  cp ${key} ${H}/.ssh/authorized_keys
  chown ${U} ${H}/.ssh/authorized_keys
  chmod 600 ${H}/.ssh/authorized_keys
done
