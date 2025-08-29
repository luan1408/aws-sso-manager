#!/bin/bash

# AWS SSO Manager - Script de Auto-Instalação/Atualização
# Resolve conflitos e instala versão atualizada automaticamente

echo "🚀 AWS SSO Manager - Auto Installer"
echo "═══════════════════════════════════════"

# Detecta o diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Função para carregar no terminal atual
load_functions() {
    echo "ℹ️  Carregando funções no terminal atual..."
    source "$SCRIPT_DIR/functions.sh" >/dev/null 2>&1
    if type aws-list >/dev/null 2>&1; then
        echo "✅ Funções carregadas com sucesso!"
        return 0
    else
        echo "❌ Erro ao carregar funções"
        return 1
    fi
}

# Função para instalar permanentemente
install_permanently() {
    echo "ℹ️  Configurando carregamento automático..."
    
    # Remove linhas antigas conflitantes
    grep -v "aws-sso-manager/functions.sh" ~/.bashrc > ~/.bashrc.tmp 2>/dev/null || cp ~/.bashrc ~/.bashrc.tmp
    
    # Adiciona nova configuração
    cat >> ~/.bashrc.tmp << 'INNER_EOF'

# AWS SSO Manager Enhanced - Auto-carregamento
if [ -f "/home/luanmessias/aws-sso-manager/functions.sh" ]; then
    source "/home/luanmessias/aws-sso-manager/functions.sh" 2>/dev/null
fi
INNER_EOF

    # Substitui bashrc
    mv ~/.bashrc.tmp ~/.bashrc
    echo "✅ Instalação permanente concluída"
}

# Execução principal
main() {
    echo "📦 Instalando/atualizando AWS SSO Manager..."
    
    # Verifica se arquivos existem
    if [ ! -f "$SCRIPT_DIR/functions.sh" ]; then
        echo "❌ Arquivo functions.sh não encontrado"
        echo "Execute este script dentro do diretório aws-sso-manager"
        exit 1
    fi
    
    # Carrega no terminal atual
    if load_functions; then
        echo ""
        echo "🎯 Teste rápido:"
        aws-list 2>/dev/null || echo "⚠️  Configure seus perfis AWS primeiro"
        
        echo ""
        read -p "Deseja instalar permanentemente para novos terminais? (Y/n): " install
        install=${install:-Y}
        
        if [[ "$install" =~ ^[Yy]$ ]]; then
            install_permanently
        fi
        
        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║                ✅ INSTALAÇÃO CONCLUÍDA                   ║"
        echo "╠══════════════════════════════════════════════════════════╣"
        echo "║                                                          ║"
        echo "║  🎯 PRONTO PARA USO:                                    ║"
        echo "║    aws-menu    - Interface interativa                    ║"
        echo "║    aws-list    - Lista perfis (com persistência!)       ║"
        echo "║    aws-switch  - Troca perfil permanentemente           ║"
        echo "║    aws-who     - Mostra perfil atual                    ║"
        echo "║                                                          ║"
        echo "║  🔄 PARA ATUALIZAR:                                     ║"
        echo "║    ./install.sh                                          ║"
        echo "║                                                          ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo ""
        echo "🎉 Problema de persistência do aws-menu RESOLVIDO!"
        
    else
        echo "❌ Falha na instalação"
        exit 1
    fi
}

main "$@"
