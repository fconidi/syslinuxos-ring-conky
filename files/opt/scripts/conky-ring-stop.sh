#!/bin/bash

PID=$(ps aux | grep "conky -c conkyrc" | grep -v 'grep' | awk '{print $2}' | head -n1 | tr -d '[:space:]')
echo "PID trovato: '$PID'"
if [ -n "$PID" ]; then
    kill "$PID"
    echo "Terminato processo con PID $PID"
else
    echo "PID non trovato."
fi

