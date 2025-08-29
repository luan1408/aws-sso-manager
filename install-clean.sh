#!/bin/bash

# AWS SSO Manager - Instalação Limpa e Simples
# Remove TODAS as instalações antigas e instala versão nova

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASHRC_FILE="$HOME/.bashrc"

echo "🚀 AWS SSO Manager - Instalação Limpa"
echo "════════════════════════════════════════"
echo ""

# Backup
echo "ℹ️  Criando backup..."
cp "$BASHRC_FILE" "${BASHRC_FILE}.backup.$(date +%s)"
echo "✅ Backup criado"

# Remove TODAS as linhas relacionadas ao AWS SSO
echo "ℹ️  Removendo instalações antigas..."
sed -i '/aws-/d; /AWS SSO/d; /AWS_PROFILE/d; /# Lista todos/d; /# Função inteligente/d; /# Faz login SSO/d; /# Mostra inform/d; /# Logout de todos/d; /# Atalhos para/d; /# Descobre e configura/d' "$BASHRC_FILE"
echo "✅ Limpeza concluída"

# Instalação limpa
echo "ℹ️  Instalando versão atual..."
cat >> "$BASHRC_FILE" << 'EOF'

# ═══════════════════════════════════════════════════════════════════
# 🚀 AWS SSO Manager Enhanced - Instalação Limpa
# ═══════════════════════════════════════════════════════════════════
if [ -f "/home/luanmessias/aws-sso-manager/functions.sh" ]; then
    source "/home/luanmessias/aws-sso-manager/functions.sh"
fi
EOF

echo "✅ Instalação concluída"

# Teste
echo "ℹ️  Testando instalação..."
if bash -c "source '$BASHRC_FILE' >/dev/null 2>&1 && type aws-list >/dev/null 2>&1"; then
    echo "✅ Funções carregadas com sucesso"
else
    echo "⚠️  Execute: source ~/.bashrc"
fi

echo ""
echo "🎯 Para usar AGORA: source ~/.bashrc"
echo "🎯 Para testar: aws-list"
echo "🎯 Interface: aws-menu"
echo ""
echo "✅ Instalação limpa concluída!"