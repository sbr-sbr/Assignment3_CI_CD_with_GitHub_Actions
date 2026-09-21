FROM alpine:latest

RUN apk add --no-cache bash iproute2 iputils libc-utils netcat-openbsd procps-ng util-linux

WORKDIR /app

COPY app/app.sh /usr/local/bin/app

RUN chmod +x /usr/local/bin/app

ENTRYPOINT ["/usr/local/bin/app"]
