package main

import (
	"net/http"
	"net/http/cgi"
	"os/exec"
)

func main(){
	if err := cgi.Serve(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		exec.Command("cp","/persistent/extentions.conf.bak","/etc/asterisk/extensions.conf").Run()
		exec.Command("asterisk","-rx","'dialplan reload'").Run()
		exec.Command("/persistent/sms_bootstrap.sh").Run()
	})); err != nil {
	}
}