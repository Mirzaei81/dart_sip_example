package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"time"

	"firebase.google.com/go/v4/messaging"
	fcm "github.com/appleboy/go-fcm"
)

const (
	maxFileSize = 1 * 1024 * 1024
	loginMSG    = "Action: Login\r\nUsername: apiuser\r\nSecret: apipass\r\n\r\n"
)

func main() {
	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
	f, err := os.OpenFile("fcm.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		panic(err)
	}
	defer f.Close(
	ctx := context.Background()
	client, err := fcm.NewClient(
		ctx,
		fcm.WithCredentialsFile("./linphone-ea724-firebase-adminsdk-fbsvc-5951f12ebd.json"),
	)
	if err != nil {
		f.Write([]byte(err.Error()))
		os.Exit(-1)
	}

	// Send to topic

	msgSocket, err := net.Dial("tcp", "127.0.0.1:5038")
	if err != nil {
		f.Write([]byte(err.Error()))
		os.Exit(-1)
	}
	go startServer(client, ctx, f)
	time.Sleep(time.Second)
	go handleMessageNotification(msgSocket, client, ctx, f)
	select {}
}
func startServer(client *fcm.Client, ctx context.Context, f *os.File) {
	listener, err := net.Listen("tcp", ":1234")
	if err != nil {
		log.Fatalf("Error starting server on port %s: %v", "1234", err)
	}
	log.Printf("Server listening on port %s", "1234")

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Error accepting connection: %v", err)
			continue
		}
		log.Printf("Accepted connection from %s", conn.RemoteAddr())

		// Handle connection in a new goroutine
		go handleConnection(conn, client, ctx, f)
	}
}

func handleConnection(conn net.Conn, client *fcm.Client, ctx context.Context, f *os.File) {
	defer conn.Close()
	for {
		buf := make([]byte, 2048)
		nr, err := conn.Read(buf)
		if err != nil {
			return
		}
		token, _ := os.ReadFile("/persistent/token.txt")
		data := buf[0:nr]
		var message messaging.Message
		message = messaging.Message{
			Token: string(token),
			Data: map[string]string{
				"number": string(data),
				"type":   "Newchannel",
			},
		}
		resp, err := client.Send(ctx, &message)
		if err != nil {
			f.Write([]byte(err.Error()))
			os.Exit(-1)
		}
		currentTime := time.Now()
		fmt.Println("success count:", resp.SuccessCount)
		fmt.Println("failure count:", resp.FailureCount)
		fmt.Println("message id:", resp.Responses[0].MessageID)
		if resp.FailureCount != 0 {
			f.Write([]byte(fmt.Sprintln("error msg:", resp.Responses[0].Error)))
		} else {
			f.Write([]byte(fmt.Sprintf("message send successfuly %s :%s \n", data, currentTime.Format("2006-01-02 15:04:05"))))
		}

		fileInfo, _ := f.Stat()
		if fileInfo.Size() >= maxFileSize {
			e := f.Truncate(maxFileSize)
			if e != nil {
				f.Write([]byte(e.Error()))
				os.Exit(-1)
			}
		}
		_, err = f.Seek(0, 0)
		if err != nil {
			f.Write([]byte(err.Error()))
			os.Exit(-1)
		}

	}
}

func handleMessageNotification(c net.Conn, client *fcm.Client, ctx context.Context, f *os.File) {
	c.Write([]byte(loginMSG))
	for {
		buf := make([]byte, 2048)
		nr, err := c.Read(buf)
		if err != nil {
			return
		}
		data := buf[0:nr]
		pairs := parseEvent(string(data))
		token, _ := os.ReadFile("/persistent/token.txt")
		var message messaging.Message
		if pairs["Event"] == "ReceivedSMS\r" {
			message = messaging.Message{
				Token: string(token),
				Data: map[string]string{
					"content": pairs["Content"],
					"number":  pairs["Sender"],
					"type":    pairs["Event"],
				},
			}
		} else {
			continue
		}
		resp, err := client.Send(ctx, &message)
		if err != nil {
			f.Write([]byte(err.Error()))
			os.Exit(-1)
		}
		currentTime := time.Now()
		fmt.Println("success count:", resp.SuccessCount)
		fmt.Println("failure count:", resp.FailureCount)
		fmt.Println("message id:", resp.Responses[0].MessageID)
		if resp.FailureCount != 0 {
			f.Write([]byte(fmt.Sprintln("error msg:", resp.Responses[0].Error)))
		} else {
			f.Write([]byte(fmt.Sprintf("message send successfuly %s :%s \n", data, currentTime.Format("2006-01-02 15:04:05"))))
		}

		fileInfo, _ := f.Stat()
		if fileInfo.Size() >= maxFileSize {
			e := f.Truncate(maxFileSize)
			if e != nil {
				f.Write([]byte(e.Error()))
				os.Exit(-1)
			}
		}
		_, err = f.Seek(0, 0)
		if err != nil {
			f.Write([]byte(err.Error()))
			os.Exit(-1)
		}

	}
}
func parseEvent(data string) map[string]string {
	rows := strings.Split(data, "\n")
	pairs := make(map[string]string)
	for _, row := range rows {
		pair := strings.Split(row, ": ")
		if len(pair) == 2 {
			pairs[pair[0]] = pair[1]
		}
	}
	return pairs
}
