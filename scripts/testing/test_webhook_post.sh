#!/bin/bash

# Script para testar execuções concorrentes no webhook com método POST
# Faz 40 chamadas simultâneas usando POST para o webhook especificado

WEBHOOK_URL="https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"

echo "🚀 Iniciando teste de execuções concorrentes (POST)..."
echo "📍 Webhook: $WEBHOOK_URL"
echo "🔢 Número de chamadas: 40"
echo "📡 Método: POST"
echo ""

# Função para fazer uma chamada POST
make_post_request() {
    local request_num=$1
    local timestamp=$(date -Iseconds)

    echo "📤 Enviando requisição POST #$request_num..."

    # Payload para POST
    local payload='{
      "test_id": "concurrent_post_test_$(date +%s)",
      "timestamp": "'$timestamp'",
      "request_number": '$request_num',
      "method": "POST",
      "message": "Teste de execução concorrente POST"
    }'

    # Faz a chamada curl POST e captura o status
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$WEBHOOK_URL")

    # Extrai informações da resposta
    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

    echo "✅ Requisição POST #$request_num concluída:"
    echo "   📊 Status HTTP: $http_status"
    echo "   ⏱️  Tempo: $time_taken"
    echo "   📄 Resposta: $body"
    echo ""
}

# Exporta a função para que possa ser usada em background
export -f make_post_request
export WEBHOOK_URL

# Executa 40 chamadas POST em paralelo usando background jobs
echo "🎯 Executando 40 chamadas POST simultâneas..."
for i in {1..40}; do
    make_post_request "$i" &
done

# Aguarda todas as chamadas terminarem
wait

echo ""
echo "🎉 Todas as 40 chamadas POST foram concluídas!"
echo "📊 Teste de concorrência POST finalizado."

