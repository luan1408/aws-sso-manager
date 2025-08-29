#!/bin/bash

# Instalação Global do AWS SSO Manager
# Instala o comando globalmente para usar de qualquer diretório

echo "🚀 Instalando AWS SSO Manager globalmente..."
echo ""

# Verifica se o script principal existe
if [ ! -f "aws-simple.sh" ]; then
    echo "❌ Erro: aws-simple.sh não encontrado no diretório atual"
    echo "   Execute este script no diretório do projeto aws-sso-manager"
    exit 1
fi

# Verifica se ~/bin existe e está no PATH
if [ ! -d "$HOME/bin" ]; then
    echo "📁 Criando diretório ~/bin..."
    mkdir -p "$HOME/bin"
fi

# Verifica se ~/bin está no PATH
if ! echo "$PATH" | grep -q "$HOME/bin"; then
    echo "⚠️  Adicionando ~/bin ao PATH..."
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo "💡 Execute: source ~/.bashrc ou reinicie o terminal"
fi

# Cria link simbólico para comando global
echo "🔗 Criando comando global 'aws-manager'..."
ln -sf "$(pwd)/aws-simple.sh" "$HOME/bin/aws-manager"

# Verifica se foi criado com sucesso
if [ -L "$HOME/bin/aws-manager" ]; then
    echo "✅ Instalação concluída com sucesso!"
    echo ""
    echo "🎯 Agora você pode usar de qualquer diretório:"
    echo ""
    echo "   aws-manager           # Menu interativo bonito"
    echo "   aws-manager list      # Lista perfis"
    echo "   aws-manager switch <perfil>  # Troca perfil"
    echo ""
    echo "📍 Exemplos:"
    echo "   aws-manager"
    echo "   aws-manager list"
    echo "   aws-manager switch wiipo-prod"
    echo ""
    echo "🎉 Teste agora mesmo executando: aws-manager"
else
    echo "❌ Erro na instalação do link simbólico"
    exit 1
fi