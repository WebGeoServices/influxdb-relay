FROM golang:latest AS builder
WORKDIR /usr/src/app
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build go build -o influxdb-relay .

FROM debian:buster-slim
WORKDIR /root/
EXPOSE 8080
COPY --from=builder /usr/src/app/influxdb-relay .
COPY startup.sh startup.sh
CMD ["/root/startup.sh"]