package models

// Message represents a TLRPC message from the Android client
type Message struct {
	Type        string      `json:"TYPE"`
	Token       int         `json:"TOKEN"`
	ClientID    string      `json:"CLIENTID"`
	Time        string      `json:"TIME"`
	ClassName   string      `json:"CLASS_NAME"`
	Constructor string      `json:"constructor"`
	Data        interface{} `json:"data,omitempty"`
}
