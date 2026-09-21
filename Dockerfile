FROM alpine:latest

WORKDIR /app

COPY app/app.sh /usr/local/bin/app

RUN chmod +x /usr/local/bin/app

ENTRYPOINT ["/usr/local/bin/app"]
