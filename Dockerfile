FROM alpine:3.20.3

LABEL maintainer="Alex Kirhenshtein <alk@netxms.org>"

ENV \
   APP_USER=app \
   APP_UID=1001

RUN \
   apk add --update --no-cache openssh rsync && \
   adduser -s /bin/sh -D -u ${APP_UID} ${APP_USER}

COPY app.sh /app.sh

USER ${APP_USER}:${APP_USER}

ENTRYPOINT [ "/app.sh" ]
