#!/bin/bash

for i in $(seq 1 30); do
  curl -s http://alb-proyecto03-1517493111.us-east-1.elb.amazonaws.com/ > /dev/null
  curl -s -X POST http://alb-proyecto03-1517493111.us-east-1.elb.amazonaws.com/blacklists \
    -H "Authorization: Bearer token-secreto-blacklist-2026" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"stress${i}@test.com\",\"app_uuid\":\"550e8400-e29b-41d4-a716-446655440000\"}" > /dev/null
done
echo "Tráfico enviado"
