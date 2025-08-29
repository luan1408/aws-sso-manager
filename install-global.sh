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

# Cria comando global (link simbólico ou cópia conforme o sistema)
echo "🔗 Criando comando global 'aws-manager'..."

# Detecta se é Windows (MINGW/Git Bash) ou Linux/macOS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$MSYSTEM" ]]; then
    # Windows: cria um script wrapper ao invés de link simbólico
    cat > "$HOME/bin/aws-manager" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AWS_SSO_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")" 2>/dev/null || echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"

# Tenta encontrar o script principal
if [ -f "$AWS_SSO_DIR/aws-simple.sh" ]; then
    exec "$AWS_SSO_DIR/aws-simple.sh" "$@"
elif [ -f "$(dirname "$0")/aws-simple.sh" ]; then
    exec "$(dirname "$0")/aws-simple.sh" "$@"
else
    # Fallback: busca no diretório onde foi instalado
    INSTALL_DIR="$(pwd)/aws-simple.sh"
    if [ -f "$INSTALL_DIR" ]; then
        exec "$INSTALL_DIR" "$@"
    else
        echo "❌ Erro: aws-simple.sh não encontrado"
        echo "   Reinstale o aws-sso-manager globalmente"
        exit 1
    fi
fi
EOF
    
    # Salva o diretório atual no script
    sed -i "s|INSTALL_DIR=\"\$(pwd)/aws-simple.sh\"|INSTALL_DIR=\"$(pwd)/aws-simple.sh\"|" "$HOME/bin/aws-manager"
    
    chmod +x "$HOME/bin/aws-manager"
    INSTALL_SUCCESS=$?
else
    # Linux/macOS: usa link simbólico
    ln -sf "$(pwd)/aws-simple.sh" "$HOME/bin/aws-manager"
    INSTALL_SUCCESS=$?
fi

# Verifica se foi criado com sucesso
if [ $INSTALL_SUCCESS -eq 0 ] && [ -f "$HOME/bin/aws-manager" ]; then
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
    echo "❌ Erro na instalação do comando global"
    exit 1
fi