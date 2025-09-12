#!/bin/bash

# Versão simplificada: 40 chamadas GET simultâneas em uma linha
# Comando curl executado 40 vezes em paralelo

echo "🚀 Executando 40 chamadas GET simultâneas (versão simples)..."
echo "📍 Webhook: https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"
echo ""

# Executa 40 chamadas curl simultâneas
for i in {1..40}; do
    curl -s "https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f?request=$i&timestamp=$(date +%s)" &
done

# Aguarda todas terminarem
wait

echo ""
echo "✅ Todas as 40 chamadas foram executadas!"
echo "💡 Para ver as respostas detalhadas, use o script test_webhook_get.sh"
