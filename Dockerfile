FROM alpine:latest AS deps

RUN apk add --no-cache bash curl jq util-linux procps-ng libc-utils iproute2 iputils netcat-openbsd

WORKDIR /app

COPY app/app.sh /usr/local/bin/app

RUN chmod +x /usr/local/bin/app

ENTRYPOINT ["/usr/local/bin/app"]