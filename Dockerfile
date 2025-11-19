FROM golang:1-alpine

RUN apk add jq

WORKDIR /app
COPY . .

RUN go install .

CMD ["/app/init.sh"]
