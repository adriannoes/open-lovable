#!/bin/bash

# Script para testar múltiplos webhooks simultaneamente
# Testa vários endpoints ao mesmo tempo para carga máxima

WEBHOOKS=(
    "https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"
    "https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"
    "https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"
)

echo "🚀 Iniciando teste de múltiplos webhooks..."
echo "📍 Webhooks configurados: ${#WEBHOOKS[@]}"
echo "🔢 Execuções por webhook: 20"
echo "📊 Total de chamadas: $((${#WEBHOOKS[@]} * 20))"
echo ""

# Função para testar um webhook específico
test_webhook() {
    local webhook_url=$1
    local webhook_num=$2
    local request_num=$3

    echo "🌐 [Webhook $webhook_num] Enviando requisição #$request_num..."

    # Payload específico para cada webhook
    local payload='{
      "webhook_id": "'$webhook_num'",
      "request_number": '$request_num',
      "timestamp": "'$(date -Iseconds)'",
      "test_type": "multiple_webhooks_test",
      "message": "Teste concorrente múltiplo - Webhook '$webhook_num' - Request '$request_num'"
    }'

    # Faz a chamada curl POST
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$webhook_url")

    # Extrai informações da resposta
    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

    echo "✅ [Webhook $webhook_num] Request #$request_num concluído:"
    echo "   📊 Status HTTP: $http_status"
    echo "   ⏱️  Tempo: $time_taken"
    echo "   📄 Resposta: $body"
    echo ""
}

# Exporta a função para uso em background
export -f test_webhook

# Lista todos os webhooks
echo "📋 Webhooks a serem testados:"
for i in "${!WEBHOOKS[@]}"; do
    echo "  🌐 Webhook $((i+1)): ${WEBHOOKS[$i]}"
done
echo ""

# Executa 20 chamadas para cada webhook simultaneamente
echo "🎯 Iniciando execuções simultâneas..."

# Loop através de cada webhook
for webhook_index in "${!WEBHOOKS[@]}"; do
    webhook_url="${WEBHOOKS[$webhook_index]}"
    webhook_num=$((webhook_index + 1))

    echo "🚀 Iniciando 20 chamadas simultâneas para Webhook $webhook_num..."

    # Executa 20 chamadas simultâneas para este webhook
    for request_num in {1..20}; do
        test_webhook "$webhook_url" "$webhook_num" "$request_num" &
    done
done

# Aguarda todas as chamadas terminarem
wait

echo ""
echo "🎉 Todos os testes de múltiplos webhooks foram concluídos!"
echo "📊 Teste finalizado - $((${#WEBHOOKS[@]} * 20)) chamadas totais executadas."

