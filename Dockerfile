FROM ubuntu:18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget git
# Install go
ENV GOPATH /root/go
ENV GO_VERSION 1.13
ENV GO_ARCH amd64
RUN wget https://storage.googleapis.com/golang/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz; \
   tar -C /usr/local/ -xf /go${GO_VERSION}.linux-${GO_ARCH}.tar.gz ; \
   rm /go${GO_VERSION}.linux-${GO_ARCH}.tar.gz

ENV PATH /usr/local/go/bin:$PATH

ENV PROJECT_DIR $GOPATH/src/github.com/influxdata/influxdb-relay
RUN mkdir -p $PROJECT_DIR && mkdir $GOPATH/bin
WORKDIR $PROJECT_DIR
COPY ./ $PROJECT_DIR/

ENV PATH $GOPATH/bin:$PATH
RUN go get -u gopkg.in/DataDog/dd-trace-go.v1/contrib/net/http
RUN go get -u
RUN go get -u github.com/influxdata/influxdb1-client/models && go get -u github.com/naoina/toml && \
go build -o $GOPATH/bin/influxdb-relay ./main.go

VOLUME /var/lib/influxdb

ENV INFLUXDB_1 '127.0.0.1:8086'
ENV INFLUXDB_2 '127.0.0.1:8086'
ENV BUFFER_SIZE '100'
ENV MAX_BATCH '50'
ENV MAX_DELAY '120s'

ENTRYPOINT ["./start_up.sh"]
EXPOSE 9096