package main

import (
	"flag"
	"github.com/influxdata/influxdb-relay/relay"
	"gopkg.in/DataDog/dd-trace-go.v1/ddtrace/tracer"
	"log"
	"os"
	"os/signal"
	"strings"
)

var (
	configFile       = flag.String("config", "", "Configuration file to use")
	configThroughEnv = flag.Bool("config-from-env", false, "Configure using environment")
)

func main() {
	dataDogService, exists := os.LookupEnv("DATADOG_SERVICE")

	if exists {
		tracer.Start(
			tracer.WithServiceName(os.Getenv(dataDogService)),
			tracer.WithEnv(os.Getenv("DATADOG_ENV")),
			tracer.WithAgentAddr("dd-agent"))
		tracer.WithDebugMode(false)
		defer tracer.Stop()
	}
	flag.Parse()

	if *configFile == "" && !*configThroughEnv {
		log.Fatal("Missing configuration file")
		flag.PrintDefaults()
		os.Exit(1)
	}
	var cfg relay.Config
	var err error

	if !*configThroughEnv {
		cfg, err = relay.LoadConfigFile(*configFile)
		if err != nil {
			log.Fatalf("Problem loading config file: %s", err)
		}
	} else {
		if relayHosts, ok := os.LookupEnv("INFLUX_RELAY_HOSTS"); ok {
			cfg, err = relay.NewConfigFromEnv(strings.Split(relayHosts, " "))
			if err != nil {
				log.Fatalf("Problem while loading config from environment: %s", err)
			}
		} else {
			log.Fatal("Environment Variable INFLUX_RELAY_HOST should be defined.")
		}

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

	r.Run()
}
