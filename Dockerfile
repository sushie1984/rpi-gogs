FROM sushie/rpi-golang:1.4.2
MAINTAINER Sascha Burku <sascha_burku@yahoo.de>

RUN apt-get update && \
    apt-get install openssh-server rsync git-core net-tools
RUN addgroup git && \
adduser git --shell /bin/bash --ingroup git

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's@UsePrivilegeSeparation yes@UsePrivilegeSeparation no@' -i /etc/ssh/sshd_config

RUN sed 's@#RSAAuthentication yes@RSAAuthentication yes@' -i /etc/ssh/sshd_config
RUN sed 's@#PubkeyAuthentication yes@PubkeyAuthentication yes@' -i /etc/ssh/sshd_config

RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

ENV GOGS_CUSTOM /data/gogs
RUN echo "export GOGS_CUSTOM=/data/gogs" >> /etc/profile

RUN mkdir -p $GOPATH/src/github.com/gogits/gogs && \
    cd $GOPATH/src/github.com/gogits/gogs && \
    git clone --branch v0.9.60 https://github.com/gogits/gogs.git . --single-branch && \
    go get && \
    go build

WORKDIR $GOPATH/src/github.com/gogits/gogs
ADD start.sh $GOPATH/src/github.com/gogits/gogs
RUN chmod a+x start.sh

EXPOSE 22
EXPOSE 3000
ENTRYPOINT []
CMD ["./start.sh"]
