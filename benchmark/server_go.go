package main

import (
	"encoding/json"
	"net/http"
	"github.com/gorilla/mux"
)

type Message struct {
	Message string `json:"message"`
}

type User struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(Message{Message: "Hello, World!"})
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["id"]
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(User{ID: userID, Name: "User " + userID})
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/hello", helloHandler).Methods("GET")
	r.HandleFunc("/user/{id}", userHandler).Methods("GET")
	
	http.ListenAndServe(":3004", r)
}
