FROM debian:buster
LABEL maintainer=dmolchanov@gmail.com

RUN apt-get update && apt-get -y install openssh-server vim locales && \
  echo 'ru_RU.UTF-8 UTF-8' > /etc/locale.gen && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

ADD sshd_config /etc/ssh/sshd_config
ADD init.sh /init.sh

EXPOSE 22

CMD /init.sh
