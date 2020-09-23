package main

import (
	"flag"
	"fmt"
	"github.com/influxdata/influxdb-relay/relay"
	"gopkg.in/DataDog/dd-trace-go.v1/ddtrace/tracer"
	"log"
	"os"
	"os/signal"
)

var (
	configFile = flag.String("config", "", "Configuration file to use")
)

func main() {
	tracer.Start(
		tracer.WithServiceName(os.Getenv("DATADOG_SERVICE")),
		tracer.WithEnv(os.Getenv("DATADOG_ENV")),
		tracer.WithAgentAddr("dd-agent"))
	tracer.WithDebugMode(false)
	defer tracer.Stop()

	flag.Parse()

	if *configFile == "" {
		fmt.Fprintln(os.Stderr, "Missing configuration file")
		flag.PrintDefaults()
		os.Exit(1)
	}

	cfg, err := relay.LoadConfigFile(*configFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Problem loading config file:", err)
	}

	r, err := relay.New(cfg)
	if err != nil {
		log.Fatal(err)
	}

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt)

	go func() {
		<-sigChan
		r.Stop()
	}()

	log.Println("starting relays...")
	r.Run()
}
