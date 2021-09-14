FROM alpine:latest

WORKDIR /app

COPY * ./

ENTRYPOINT ["./shlib"]
