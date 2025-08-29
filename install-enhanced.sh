#!/bin/bash

# AWS SSO Manager Enhanced - Script de Instalação
# Inclui: Criptografia de tokens + Interface TUI com Fuzzy Finder
# Autor: AWS SSO Manager Enhanced

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║           🚀 AWS SSO Manager Enhanced Setup             ║"
echo "║                                                          ║"
echo "║  ✨ Novos recursos:                                     ║"
echo "║    🔐 Criptografia automática de tokens SSO            ║"
echo "║    🎯 Interface TUI com fuzzy finder                    ║"
echo "║    ⚡ Navegação interativa entre perfis                ║"
echo "║    🔍 Preview de status em tempo real                  ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Detecta sistema operacional
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt >/dev/null 2>&1; then
            echo "ubuntu"
        elif command -v yum >/dev/null 2>&1; then
            echo "rhel"
        elif command -v pacman >/dev/null 2>&1; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Instala dependências
install_dependencies() {
    local os
    os=$(detect_os)
    
    echo "🔧 Verificando dependências..."
    
    # Verifica se fzf está instalado
    if ! command -v fzf >/dev/null 2>&1; then
        echo "📦 Instalando fzf (fuzzy finder)..."
        
        case $os in
            "ubuntu")
                sudo apt update && sudo apt install -y fzf
                ;;
            "rhel")
                sudo yum install -y fzf
                ;;
            "arch")
                sudo pacman -S fzf --noconfirm
                ;;
            "macos")
                if command -v brew >/dev/null 2>&1; then
                    brew install fzf
                else
                    echo "❌ Homebrew não encontrado. Instale manualmente: https://github.com/junegunn/fzf"
                    exit 1
                fi
                ;;
            *)
                echo "⚠️  Sistema não reconhecido. Instale fzf manualmente:"
                echo "   https://github.com/junegunn/fzf#installation"
                read -p "Pressione Enter se já tiver fzf instalado..."
                ;;
        esac
        
        if command -v fzf >/dev/null 2>&1; then
            echo "✅ fzf instalado com sucesso"
        else
            echo "❌ Falha na instalação do fzf"
            exit 1
        fi
    else
        echo "✅ fzf já está instalado"
    fi
    
    # Verifica se openssl está instalado (para criptografia)
    if ! command -v openssl >/dev/null 2>&1; then
        echo "📦 Instalando OpenSSL (para criptografia)..."
        
        case $os in
            "ubuntu")
                sudo apt install -y openssl
                ;;
            "rhel")
                sudo yum install -y openssl
                ;;
            "arch")
                sudo pacman -S openssl --noconfirm
                ;;
            "macos")
                echo "✅ OpenSSL já disponível no macOS"
                ;;
            *)
                echo "⚠️  Verifique se OpenSSL está instalado"
                ;;
        esac
    else
        echo "✅ OpenSSL disponível"
    fi
    
    # Verifica AWS CLI
    if ! command -v aws >/dev/null 2>&1; then
        echo "❌ AWS CLI não encontrado!"
        echo "📋 Instale o AWS CLI v2:"
        echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    else
        local aws_version
        aws_version=$(aws --version 2>&1 | head -n1)
        echo "✅ AWS CLI encontrado: $aws_version"
    fi
}

# Backup do .bashrc atual
backup_bashrc() {
    if [ -f ~/.bashrc ]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp ~/.bashrc "$backup_file"
        echo "💾 Backup criado: $backup_file"
    fi
}

# Instala funções no .bashrc
install_functions() {
    echo "🔧 Instalando funções no ~/.bashrc..."
    
    # Remove instalação anterior se existir
    if grep -q "AWS SSO Manager" ~/.bashrc 2>/dev/null; then
        echo "🔄 Removendo instalação anterior..."
        # Remove desde a linha do AWS SSO Manager até o final da seção
        sed -i '/# AWS SSO Manager/,/^$/d' ~/.bashrc 2>/dev/null || true
    fi
    
    # Adiciona fonte das funções
    local install_dir
    install_dir=$(pwd)
    
    cat >> ~/.bashrc << EOF

# AWS SSO Manager Enhanced
# Carregado automaticamente
if [ -f "$install_dir/functions.sh" ]; then
    source "$install_dir/functions.sh"
fi

EOF
    
    echo "✅ Funções instaladas no ~/.bashrc"
}

# Cria links simbólicos para scripts (opcional)
create_symlinks() {
    echo "🔗 Deseja criar links simbólicos para acesso global? (y/N)"
    read -r create_links
    
    if [[ "$create_links" =~ ^[Yy]$ ]]; then
        local bin_dir="$HOME/.local/bin"
        
        # Cria diretório se não existir
        mkdir -p "$bin_dir"
        
        # Adiciona ao PATH se necessário
        if ! echo "$PATH" | grep -q "$bin_dir"; then
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
            export PATH="$HOME/.local/bin:$PATH"
        fi
        
        # Cria links para scripts principais
        ln -sf "$(pwd)/add-profile.sh" "$bin_dir/aws-add-profile"
        ln -sf "$(pwd)/switch-profile.sh" "$bin_dir/aws-switch-profile"
        
        chmod +x "$bin_dir/aws-add-profile" "$bin_dir/aws-switch-profile"
        
        echo "✅ Links criados em $bin_dir"
    fi
}

# Teste rápido da instalação
test_installation() {
    echo "🧪 Testando instalação..."
    
    # Carrega funções para teste
    source "$(pwd)/functions.sh"
    
    # Testa função básica
    if command -v aws-help >/dev/null 2>&1; then
        echo "✅ Funções carregadas com sucesso"
    else
        echo "❌ Erro ao carregar funções"
        exit 1
    fi
    
    # Testa fzf
    if command -v fzf >/dev/null 2>&1; then
        echo "✅ Fuzzy finder disponível"
    else
        echo "⚠️  Fuzzy finder não disponível"
    fi
    
    # Testa criptografia
    if command -v openssl >/dev/null 2>&1; then
        echo "✅ Criptografia disponível"
    else
        echo "⚠️  Criptografia não disponível"
    fi
}

# Instruções finais
show_final_instructions() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                   🎉 Instalação Concluída!              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "🚀 Para ativar os novos recursos:"
    echo "   source ~/.bashrc"
    echo "   # OU reinicie o terminal"
    echo ""
    echo "🎯 Primeiros passos:"
    echo "   1. aws-help              - Ver todos os comandos"
    echo "   2. aws-discover-org      - Descobrir contas da organização"
    echo "   3. aws-menu              - Interface interativa principal"
    echo "   4. aws-choose            - Seletor de perfil com preview"
    echo ""
    echo "🔐 Segurança:"
    echo "   • Tokens são criptografados automaticamente"
    echo "   • Use aws-secure-tokens para proteger tokens existentes"
    echo "   • Chave mestre gerada em ~/.aws-sso-secure/"
    echo ""
    echo "📚 Documentação:"
    echo "   • GitHub: https://github.com/luan1408/aws-sso-manager"
    echo "   • Issues: https://github.com/luan1408/aws-sso-manager/issues"
    echo ""
    echo "⭐ Gostou? Dê uma estrela no repositório!"
}

# Função principal
main() {
    echo "🔍 Iniciando instalação do AWS SSO Manager Enhanced..."
    echo ""
    
    # Verifica se está no diretório correto
    if [ ! -f "functions.sh" ] || [ ! -f "crypto-functions.sh" ] || [ ! -f "tui-functions.sh" ]; then
        echo "❌ Arquivos necessários não encontrados!"
        echo "Certifique-se de estar no diretório do AWS SSO Manager"
        exit 1
    fi
    
    # Passo a passo da instalação
    install_dependencies
    echo ""
    
    backup_bashrc
    echo ""
    
    install_functions
    echo ""
    
    create_symlinks
    echo ""
    
    test_installation
    echo ""
    
    show_final_instructions
}

# Executa instalação
main "$@"