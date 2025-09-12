#!/bin/bash

# Script para testar execuções concorrentes no webhook com método GET
# Faz 20 chamadas simultâneas usando GET para o webhook especificado

WEBHOOK_URL="https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"

echo "🚀 Iniciando teste de execuções concorrentes (GET)..."
echo "📍 Webhook: $WEBHOOK_URL"
echo "🔢 Número de chamadas: 40"
echo "📡 Método: GET"
echo ""

# Função para fazer uma chamada GET
make_get_request() {
    local request_num=$1
    local timestamp=$(date -Iseconds)

    echo "📤 Enviando requisição GET #$request_num..."

    # Faz a chamada curl GET e captura o status
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
        -X GET \
        "$WEBHOOK_URL?test_id=concurrent_test_$(date +%s)&request_number=$request_num&timestamp=$timestamp")

    # Extrai informações da resposta
    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

    echo "✅ Requisição GET #$request_num concluída:"
    echo "   📊 Status HTTP: $http_status"
    echo "   ⏱️  Tempo: $time_taken"
    echo "   📄 Resposta: $body"
    echo ""
}

# Exporta a função para que possa ser usada em background
export -f make_get_request
export WEBHOOK_URL

# Executa 40 chamadas GET em paralelo usando background jobs
echo "🎯 Executando 40 chamadas GET simultâneas..."
for i in {1..40}; do
    make_get_request "$i" &
done

# Aguarda todas as chamadas terminarem
wait

echo ""
echo "🎉 Todas as 40 chamadas GET foram concluídas!"
echo "📊 Teste de concorrência finalizado."
