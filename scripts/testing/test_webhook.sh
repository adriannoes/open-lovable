#!/bin/bash

# Script para testar execuções concorrentes no webhook
# Faz 20 chamadas simultâneas para o webhook especificado

WEBHOOK_URL="https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"

echo "🚀 Iniciando teste de execuções concorrentes..."
echo "📍 Webhook: $WEBHOOK_URL"
echo "🔢 Número de chamadas: 20"
echo ""

# Payload de exemplo para enviar
PAYLOAD='{
  "test_id": "concurrent_test_$(date +%s)",
  "timestamp": "'$(date -Iseconds)'",
  "request_number": null,
  "message": "Teste de execução concorrente"
}'

# Função para fazer uma chamada
make_request() {
    local request_num=$1
    local payload=$(echo "$PAYLOAD" | sed "s/null/$request_num/")

    echo "📤 Enviando requisição #$request_num..."

    # Faz a chamada curl e captura o status
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$WEBHOOK_URL")

    # Extrai informações da resposta
    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

    echo "✅ Requisição #$request_num concluída:"
    echo "   📊 Status HTTP: $http_status"
    echo "   ⏱️  Tempo: $time_taken"
    echo "   📄 Resposta: $body"
    echo ""
}

# Exporta a função para que possa ser usada em background
export -f make_request
export WEBHOOK_URL
export PAYLOAD

# Executa 20 chamadas em paralelo usando background jobs
echo "🎯 Executando 20 chamadas simultâneas..."
for i in {1..20}; do
    make_request "$i" &
done

# Aguarda todas as chamadas terminarem
wait

echo ""
echo "🎉 Todas as 20 chamadas foram concluídas!"
echo "📊 Teste de concorrência finalizado."

