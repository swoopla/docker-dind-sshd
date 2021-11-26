FROM docker:dind

LABEL maintainer "Swoopla <p.vibet+docker@gmail.com>"

ENTRYPOINT ["/entrypoint.sh"]

ENV DOCKER_HOST='tcp://127.0.0.1:2375'

EXPOSE 22

RUN apk add --update-cache openssh \
  && sed -i 's/#PermitRootLogin.*/PermitRootLogin\ yes/' /etc/ssh/sshd_config \
  && echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config \
  && passwd -u root \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
