# docker ssh service based on debian:buster
Includes support for ru_RU.UTF8 and vim
# control

## environments
  * SSH_USERS="username1:pass1\[:uid1\[:gid1\]\] usernameN:passN\[:uidN\[:gidN\]\]
  * SSH_GROUP="group1\[:gid1\] groupN\[:gidN\]"
  * SSH_KEY_${usernameN}="ssh-rsa key comment"
