curl -X POST -H "Authorization: Bearer ya29.ElqKBGN2Ri_Uz...HnS_uNreA" -H "Content-Type: application/json" -d '{
"message":{
   "notification":{
     "title":"FCM Message",
     "body":"This is an FCM Message"
   },
   "token":"bk3RNwTe3H0:CI2k_HHwgIpoDKCIZvvDMExUdFQ3P1..."
}}' https://fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send
