#!/bin/bash

start_detached_nodejs() {
    echo "Starting Detached Node Server"
    node "$HOME/c/www/bloodweb.net/captures/test-server.js" &
    echo "Node Server is active"
}

kill_detached_nodejs() {
    pids=$(pgrep -af 'node' | grep -v 'pts/')

    if [ -n "$pids" ]; then
        echo "Terminating Detached node Server"
        echo "$pids" | xargs kill -15
    else
        echo "No detached Node Server to Terminate" 
    fi
}