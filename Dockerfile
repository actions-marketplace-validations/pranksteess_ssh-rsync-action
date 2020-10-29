FROM alpine

LABEL "maintainer"="specer <specer@blockabc.com>"
LABEL "repository"="https://github.com/pranksteess/ssh-rsync-action"
LABEL "version"="1.0.0"

LABEL "com.github.actions.name"="RSyncer Action"
LABEL "com.github.actions.description"="This action syncs files (probably) generated by a previous step in the workflow with a remote server."
LABEL "com.github.actions.icon"="copy"
LABEL "com.github.actions.color"="blue"

RUN apk update && \
  apk add --no-cache --virtual .run-deps rsync=3.1.3-r1 openssh=8.1_p1-r0 && \
  apk add ca-certificates && \ 
  apk add --no-cache openssh-client && \
  apk add --no-cache openssl && \
  apk add --no-cache --upgrade bash && \
  rm -rf /var/cache/apk/*
  
ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
