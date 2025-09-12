#!/bin/bash

# Script para testar uma requisição POST ao webhook

WEBHOOK_URL="https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"

echo "🚀 Testando requisição POST..."
echo "📍 Webhook: $WEBHOOK_URL"
echo ""

# Payload para enviar via POST
PAYLOAD='{
  "test_id": "post_test_$(date +%s)",
  "timestamp": "'$(date -Iseconds)'",
  "method": "POST",
  "message": "Teste de requisição POST"
}'

echo "📤 Enviando payload:"
echo "$PAYLOAD"
echo ""

# Faz a chamada curl POST
response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    "$WEBHOOK_URL")

# Extrai informações da resposta
http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

echo "✅ Resultado da requisição POST:"
echo "   📊 Status HTTP: $http_status"
echo "   ⏱️  Tempo: $time_taken"
echo "   📄 Resposta: $body"
echo ""

if [ "$http_status" = "200" ]; then
    echo "🎉 POST bem-sucedido!"
else
    echo "❌ POST falhou com status $http_status"
fi

