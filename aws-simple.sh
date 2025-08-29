#!/bin/bash
# AWS SSO Manager - Versão Ultra Simplificada
# Só o que realmente importa!

cd "$(dirname "$0")"

# Função auxiliar para persistência
_get_current_profile() {
    if [ -f ~/.aws/current_profile ]; then
        cat ~/.aws/current_profile 2>/dev/null
    else
        echo "default"
    fi
}

# Salva perfil atual
_save_profile() {
    mkdir -p ~/.aws
    echo "$1" > ~/.aws/current_profile
    export AWS_PROFILE="$1"
}

# Lista perfis
_list_profiles() {
    echo "📋 Perfis AWS:"
    echo "─────────────────────────────────"
    local current=$(_get_current_profile)
    aws configure list-profiles 2>/dev/null | while read profile; do
        if [ "$profile" = "$current" ]; then
            echo "➤ $profile (atual)"
        else
            echo "  $profile"
        fi
    done
    echo "─────────────────────────────────"
}

# Menu principal
_main_menu() {
    while true; do
        clear
        echo "🚀 AWS SSO Manager"
        echo ""
        echo "Perfil atual: $(_get_current_profile)"
        echo ""
        echo "1) Listar perfis"
        echo "2) Trocar perfil"
        echo "3) Login SSO"
        echo "4) Ver status"
        echo "5) Sair"
        echo ""
        read -p "Opção [1-5]: " choice
        
        case $choice in
            1)
                _list_profiles
                read -p "Pressione Enter..."
                ;;
            2)
                echo ""
                _list_profiles
                echo ""
                read -p "Nome do perfil: " profile
                if [ -n "$profile" ]; then
                    if aws configure list-profiles 2>/dev/null | grep -q "^${profile}$"; then
                        _save_profile "$profile"
                        echo "✅ Perfil alterado para: $profile"
                        if aws sts get-caller-identity >/dev/null 2>&1; then
                            echo "🔑 Credenciais válidas"
                        else
                            echo "⚠️  Execute: aws sso login --profile $profile"
                        fi
                    else
                        echo "❌ Perfil não encontrado"
                    fi
                fi
                read -p "Pressione Enter..."
                ;;
            3)
                echo ""
                read -p "Perfil para login: " profile
                if [ -n "$profile" ]; then
                    aws sso login --profile "$profile"
                    if [ $? -eq 0 ]; then
                        _save_profile "$profile"
                        echo "✅ Login realizado!"
                    fi
                fi
                read -p "Pressione Enter..."
                ;;
            4)
                echo ""
                echo "📋 Perfil: $(_get_current_profile)"
                aws sts get-caller-identity --output table 2>/dev/null || echo "❌ Sem credenciais"
                read -p "Pressione Enter..."
                ;;
            5)
                echo "👋 Até logo!"
                exit 0
                ;;
            *)
                echo "Opção inválida"
                sleep 1
                ;;
        esac
    done
}

# Comandos diretos
case "$1" in
    "list")
        _list_profiles
        ;;
    "switch")
        if [ -z "$2" ]; then
            echo "Uso: $0 switch <perfil>"
            _list_profiles
        else
            _save_profile "$2"
            echo "✅ Perfil alterado para: $2"
        fi
        ;;
    "menu"|"")
        _main_menu
        ;;
    *)
        echo "🚀 AWS SSO Manager - Ultra Simples"
        echo ""
        echo "Uso:"
        echo "  $0          - Menu interativo"
        echo "  $0 menu     - Menu interativo"  
        echo "  $0 list     - Lista perfis"
        echo "  $0 switch <perfil> - Troca perfil"
        echo ""
        echo "Exemplo: $0 switch wiipo-prod"
        ;;
esac