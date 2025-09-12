#!/bin/bash

# Script para testar execuções concorrentes no formulário
# Faz 40 chamadas simultâneas para o formulário especificado

FORM_URL="https://admpm3.app.n8n.cloud/form/f8a9c279-596c-4723-bd9c-3b70a248b956"

echo "🚀 Iniciando teste de execuções concorrentes (FORM)..."
echo "📍 Form URL: $FORM_URL"
echo "🔢 Número de chamadas: 40"
echo "📡 Método: POST"
echo ""

# Função para fazer uma chamada POST ao formulário
make_form_request() {
    local request_num=$1
    local timestamp=$(date -Iseconds)

    echo "📤 Enviando formulário #$request_num..."

    # Payload específico para o formulário
    local payload='{
      "field_1": "Teste Concorrente '$request_num'",
      "field_2": "Dados automatizados - Request '$request_num'",
      "field_3": "Timestamp: '$timestamp'",
      "test_id": "concurrent_form_test_$(date +%s)_'$request_num'",
      "request_number": '$request_num',
      "message": "Teste de formulário concorrente"
    }'

    # Faz a chamada curl POST e captura o status
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Referer: $FORM_URL" \
        -d "$payload" \
        "$FORM_URL")

    # Extrai informações da resposta
    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

    echo "✅ Formulário #$request_num concluído:"
    echo "   📊 Status HTTP: $http_status"
    echo "   ⏱️  Tempo: $time_taken"
    echo "   📄 Resposta: $body"
    echo ""
}

# Exporta a função para que possa ser usada em background
export -f make_form_request
export FORM_URL

# Executa 40 chamadas de formulário em paralelo usando background jobs
echo "🎯 Executando 40 envios de formulário simultâneos..."
for i in {1..40}; do
    make_form_request "$i" &
done

# Aguarda todas as chamadas terminarem
wait

echo ""
echo "🎉 Todas as 40 chamadas de formulário foram concluídas!"
echo "📊 Teste de concorrência do formulário finalizado."

