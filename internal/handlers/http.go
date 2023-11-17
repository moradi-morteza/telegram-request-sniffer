package handlers

import (
	"log"
	"net/http"
	"path/filepath"
)

// ServeIndex serves the main dashboard HTML file
func ServeIndex(publicDir string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		indexPath := filepath.Join(publicDir, "index.html")
		http.ServeFile(w, r, indexPath)
	}
}

// ServeClient serves the client HTML file
func ServeClient(publicDir string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		clientPath := filepath.Join(publicDir, "client.html")
		http.ServeFile(w, r, clientPath)
	}
}

// LoggingMiddleware logs HTTP requests
func LoggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s %s", r.Method, r.RequestURI, r.RemoteAddr)
		next.ServeHTTP(w, r)
	})
}
