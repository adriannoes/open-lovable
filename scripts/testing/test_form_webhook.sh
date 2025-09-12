#!/bin/bash

# Script para testar o formulário webhook
# Primeiro faz GET para ver a estrutura, depois POST com dados

FORM_URL="https://admpm3.app.n8n.cloud/form/f8a9c279-596c-4723-bd9c-3b70a248b956"

echo "🚀 Testando formulário webhook..."
echo "📍 URL: $FORM_URL"
echo ""

# Primeiro, fazer GET para ver a estrutura do formulário
echo "📤 Fazendo requisição GET para ver o formulário..."
get_response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\n" "$FORM_URL")

http_status=$(echo "$get_response" | grep "HTTP_STATUS:" | cut -d: -f2)
form_html=$(echo "$get_response" | sed '/HTTP_STATUS:/d')

echo "✅ GET concluído:"
echo "   📊 Status HTTP: $http_status"
echo "   📄 Conteúdo do formulário (primeiras linhas):"
echo "$form_html" | head -20
echo ""

# Agora fazer POST com dados do formulário
# Baseado no HTML visto, parece ter um campo obrigatório
echo "📤 Enviando dados via POST..."

# Payload baseado na estrutura do formulário
PAYLOAD='{
  "field_1": "Teste Automatizado",
  "field_2": "Dados de teste",
  "field_3": "Mais dados de teste",
  "timestamp": "'$(date -Iseconds)'",
  "test_id": "form_test_$(date +%s)"
}'

post_response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Referer: $FORM_URL" \
    -d "$PAYLOAD" \
    "$FORM_URL")

# Extrai informações da resposta POST
post_http_status=$(echo "$post_response" | grep "HTTP_STATUS:" | cut -d: -f2)
post_time=$(echo "$post_response" | grep "TIME:" | cut -d: -f2)
post_body=$(echo "$post_response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

echo "✅ POST concluído:"
echo "   📊 Status HTTP: $post_http_status"
echo "   ⏱️  Tempo: $post_time"
echo "   📄 Resposta: $post_body"
echo ""

if [ "$post_http_status" = "200" ]; then
    echo "🎉 Formulário enviado com sucesso!"
else
    echo "❌ Falha ao enviar formulário - Status: $post_http_status"
fi

