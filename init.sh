#!/bin/bash
declare -a USERADD_OPTS
add_user (){
    USERADD_OPTS=()
    USERADD_OPTS+=("-s /bin/bash -m")
    [[ -z $1 ]] && return 1
    IFS=: read user pass uid gid ssh_key < <(echo $1)
    echo u:$user p:$pass id:$uid gid:$gid
    [[ -z ${user} || -z ${pass} ]] && return 1
    HOMEDIR="/home/${user}"
    USERADD_OPTS+=("-d" "${HOMEDIR}")
    [[ -n ${uid} ]] && USERADD_OPTS+=("-u" ${uid})
    [[ -n ${gid} && $(egrep -q "^.+:.+:${gid}:" /etc/group) ]] && USERADD_OPTS+=("-g" ${gid}) 
    useradd ${USERADD_OPTS[@]} $user || return $?
    #echo echo "${user}:${pass}" \| chpasswd
    echo "${user}:${pass}" | chpasswd
    eval $(echo ssh_key=\$SSH_KEY_${user})
    [[ -n $ssh_key ]] && {
      SSHDIR=${HOMEDIR}/.ssh
      echo "adding ${ssh_key} for ${user}"
      mkdir -p ${SSHDIR}
      echo ${ssh_key} >> ${SSHDIR}/authorized_keys
      chmod 600 ${SSHDIR}/authorized_keys 
      chmod 700 ${SSHDIR}
      chown $(id -u ${user}):$(id -g ${user}) ${SSHDIR} -R
    }
    return 0
}

add_group(){
    GROUPADD_OPTS=()
    [[ -z $1 ]] && return
    IFS=: read group gid < <(echo $1)
    echo adding ${group} with gid:${gid}
    [[ -z ${group} ]] && return
    [[ -n ${gid} ]] && GROUPADD_OPTS+=("-g" ${gid})
    groupadd ${GROUPADD_OPTS[@]} ${group} || return $?
    return 0
}

[[ -n ${SSH_GROUPS} ]] && {
  for ssh_group in ${SSH_GROUPS}; do
    add_group ${ssh_group}
    echo $?
  done
}
[[ -n $SSH_USERS ]] && {
  for ssh_user in ${SSH_USERS}; do 
    add_user ${ssh_user}
    echo $?
  done
}
[[ -f /etc/ssh/ssh_host_rsa_key ]] || dpkg-reconfigure openssh-server
[[ -d /var/run/sshd ]] ||  mkdir -p /var/run/sshd

/usr/sbin/sshd -D -E /proc/1/fd/1 -e
