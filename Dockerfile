FROM golang:1.10.1-alpine as builder
WORKDIR /go/src/github.com/lucasmdrs/exams

COPY main.go .

RUN apk add git --no-cache \
    && go get . \
    && GOOS=linux go build -o hello


FROM alpine:3.7

RUN addgroup -S pagarme && adduser -S -g pagarme pagarme
EXPOSE 8080
USER pagarme
COPY --from=builder /go/src/github.com/lucasmdrs/exams/hello /usr/bin/hello

CMD ["hello"]
