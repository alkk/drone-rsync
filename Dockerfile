FROM alpine:3.17.1

RUN apk add --update --no-cache openssh rsync

COPY app.sh /app.sh

ENTRYPOINT [ "/app.sh" ]
