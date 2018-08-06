package main

import (
	"encoding/json"
	"log"
	"net/http"
	"net/smtp"
	"os"
)

// Monitor describes an service overview
type Monitor struct {
	Services map[string]string `json:"service"`
}

func main() {
	resp, err := http.Get(os.Getenv("MONITOR_ENDPOINT"))
	if err != nil {
		log.Printf("Failed to get services status: %s", err)
	}
	defer resp.Body.Close()
	var m Monitor
	decode := json.NewDecoder(resp.Body)
	if err := decode.Decode(&m); err != nil {
		log.Printf("Monitor server respond with unsuitable msg: %s", err)
	}

	var downServices string
	for k, v := range m.Services {
		if v == "down" {
			downServices += k + "\n"
		}
	}
	SendMail(downServices)
}

//SendMail sends an alert via email to unavailable services
func SendMail(msg string) {
	from := "service.monitor@nexxera.com"
	to := "devops@nexxera.com"
	email := "From: " + from + "\n" +
		"To: " + to + "\n" +
		"Subject: Services Down!\n\n" +
		"[WARNING] The following services are unavailable:\n" +
		msg

	err := smtp.SendMail("smtp.nexxera.com:587",
		smtp.PlainAuth("", from, os.Getenv("PASSWD_EMAIL"), "smtp.nexxera.com"),
		from, []string{to}, []byte(email))

	if err != nil {
		log.Printf("There was an error trying to send the email: %s", err)
		return
	}

	log.Print("Alert sent!")
}
