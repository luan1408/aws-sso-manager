#!/bin/bash

# Interface TUI com Fuzzy Finder para AWS SSO Manager
# Autor: AWS SSO Manager Enhanced

# Verifica se fzf está disponível
_check_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "⚠️  fzf não encontrado. Instalando..."
        
        # Tenta instalar fzf baseado no sistema
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y fzf
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y fzf
        elif command -v brew >/dev/null 2>&1; then
            brew install fzf
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S fzf
        else
            echo "❌ Não foi possível instalar fzf automaticamente"
            echo "💡 Instale manualmente: https://github.com/junegunn/fzf#installation"
            return 1
        fi
        
        if ! command -v fzf >/dev/null 2>&1; then
            echo "❌ Falha na instalação do fzf"
            return 1
        fi
        
        echo "✅ fzf instalado com sucesso"
    fi
    return 0
}

# Verifica status das credenciais de um perfil
_check_profile_status() {
    local profile="$1"
    
    # Temporarily set profile and check credentials
    local original_profile="$AWS_PROFILE"
    export AWS_PROFILE="$profile"
    
    local status_icon="❓"
    local status_text="unknown"
    
    # Check if credentials are valid
    if aws sts get-caller-identity --output text --query 'Account' >/dev/null 2>&1; then
        local account
        account=$(aws sts get-caller-identity --output text --query 'Account' 2>/dev/null)
        status_icon="✅"
        status_text="valid (Account: $account)"
    else
        status_icon="❌"
        status_text="expired/invalid"
    fi
    
    # Restore original profile
    if [ -n "$original_profile" ]; then
        export AWS_PROFILE="$original_profile"
    else
        unset AWS_PROFILE
    fi
    
    echo "$status_icon $status_text"
}

# Gera lista de perfis com preview de status
_generate_profile_list() {
    echo "🔍 Carregando perfis..."
    
    local current_profile
    current_profile=$(_get_current_profile)
    local profiles
    
    # Get all profiles
    profiles=$(aws configure list-profiles 2>/dev/null)
    
    if [ -z "$profiles" ]; then
        echo "❌ Nenhum perfil AWS encontrado"
        return 1
    fi
    
    # Create temporary file for profile list with status
    local temp_file
    temp_file=$(mktemp)
    
    echo "$profiles" | while read -r profile; do
        local marker=""
        local status
        
        # Mark current profile
        if [ "$profile" = "$current_profile" ]; then
            marker="→ "
        else
            marker="  "
        fi
        
        # Check status in background for speed
        status=$(_check_profile_status "$profile")
        
        printf "%s%-20s %s\n" "$marker" "$profile" "$status" >> "$temp_file"
    done
    
    echo "$temp_file"
}

# Interface principal com fuzzy finder
aws-choose() {
    echo "🎯 AWS SSO Profile Selector"
    echo "════════════════════════════"
    
    if ! _check_fzf; then
        return 1
    fi
    
    # Generate profile list
    local profile_list_file
    profile_list_file=$(_generate_profile_list)
    
    if [ ! -f "$profile_list_file" ]; then
        echo "❌ Erro ao carregar perfis"
        return 1
    fi
    
    # FZF options for better UX
    local fzf_opts=(
        "--height=50%"
        "--border"
        "--reverse" 
        "--prompt=AWS Profile › "
        "--header=↑↓ navegar | Enter selecionar | Ctrl+C cancelar | Tab preview"
        "--preview='echo {}; echo; echo \"Detalhes do perfil:\"; aws configure list --profile {2} 2>/dev/null || echo \"Perfil não configurado\"'"
        "--preview-window=right:50%"
        "--bind=tab:toggle-preview"
        "--color=hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,marker:#f38ba8,prompt:#89b4fa,spinner:#f38ba8,pointer:#f38ba8,header:#89dceb,border:#6c7086,label:#89dceb,query:#cdd6f4"
    )
    
    # Show profile selector
    local selected
    selected=$(cat "$profile_list_file" | fzf "${fzf_opts[@]}")
    
    # Clean up temp file
    rm -f "$profile_list_file"
    
    if [ -z "$selected" ]; then
        echo "❌ Operação cancelada"
        return 1
    fi
    
    # Extract profile name (second column)
    local profile_name
    profile_name=$(echo "$selected" | awk '{print $2}')
    
    echo ""
    echo "🎯 Perfil selecionado: $profile_name"
    
    # Ask for action
    echo ""
    echo "Escolha uma ação:"
    echo "1) Trocar para este perfil (switch)"
    echo "2) Fazer login SSO neste perfil"
    echo "3) Mostrar detalhes do perfil"
    echo "4) Cancelar"
    
    read -p "Digite sua escolha [1-4]: " action
    
    case $action in
        1)
            echo "🔄 Trocando para perfil: $profile_name"
            aws-switch "$profile_name"
            ;;
        2)
            echo "🔐 Fazendo login SSO no perfil: $profile_name"
            aws-login "$profile_name"
            ;;
        3)
            echo "📋 Detalhes do perfil: $profile_name"
            echo "────────────────────────────────"
            aws configure list --profile "$profile_name"
            ;;
        4|*)
            echo "❌ Operação cancelada"
            return 1
            ;;
    esac
}

# Interface rápida para troca direta
aws-quick() {
    echo "⚡ Troca Rápida de Perfil"
    
    if ! _check_fzf; then
        # Fallback para seleção simples sem fzf
        aws-list
        echo ""
        read -p "Digite o nome do perfil: " profile_name
        if [ -n "$profile_name" ]; then
            aws-switch "$profile_name"
        fi
        return $?
    fi
    
    # Get profile names only
    local profiles
    profiles=$(aws configure list-profiles 2>/dev/null)
    
    if [ -z "$profiles" ]; then
        echo "❌ Nenhum perfil encontrado"
        return 1
    fi
    
    # Quick selection with minimal fzf
    local selected
    selected=$(echo "$profiles" | fzf \
        --height=40% \
        --border \
        --prompt="Selecione › " \
        --header="Troca rápida de perfil" \
        --reverse)
    
    if [ -n "$selected" ]; then
        aws-switch "$selected"
    else
        echo "❌ Operação cancelada"
        return 1
    fi
}

# Navegação em árvore de perfis (organizados por padrão)
aws-tree() {
    echo "🌳 Navegação em Árvore de Perfis"
    
    local profiles
    profiles=$(aws configure list-profiles 2>/dev/null)
    
    if [ -z "$profiles" ]; then
        echo "❌ Nenhum perfil encontrado"
        return 1
    fi
    
    # Group profiles by common prefixes
    echo "$profiles" | awk '
    {
        # Split by common separators
        if (match($0, /^([^-_]+)[-_](.+)$/, arr)) {
            groups[arr[1]] = groups[arr[1]] arr[2] "\n"
        } else {
            groups["other"] = groups["other"] $0 "\n"
        }
    }
    END {
        for (group in groups) {
            print "📁 " group ":"
            print groups[group]
            print ""
        }
    }'
}

# Menu principal TUI
aws-menu() {
    while true; do
        clear
        echo "╔══════════════════════════════════════╗"
        echo "║        AWS SSO Manager - TUI         ║"
        echo "╠══════════════════════════════════════╣"
        echo "║                                      ║"
        echo "║  1) 🎯 Escolher Perfil (Interativo) ║"
        echo "║  2) ⚡ Troca Rápida                  ║"
        echo "║  3) 🌳 Navegação em Árvore          ║"
        echo "║  4) 📋 Listar Perfis                ║"
        echo "║  5) 👤 Ver Perfil Atual             ║"
        echo "║  6) 🔐 Gerenciar Tokens Seguros     ║"
        echo "║  7) 🔍 Descobrir Contas da Org      ║"
        echo "║  8) 🚪 Sair                         ║"
        echo "║                                      ║"
        echo "╚══════════════════════════════════════╝"
        echo ""
        local current_profile
        current_profile=$(_get_current_profile)
        echo "Perfil atual: $current_profile"
        echo ""
        
        read -p "Escolha uma opção [1-8]: " choice
        
        case $choice in
            1)
                aws-choose
                echo ""
                read -p "Pressione Enter para continuar..."
                ;;
            2)
                aws-quick
                echo ""
                read -p "Pressione Enter para continuar..."
                ;;
            3)
                aws-tree
                echo ""
                read -p "Pressione Enter para continuar..."
                ;;
            4)
                aws-list
                echo ""
                read -p "Pressione Enter para continuar..."
                ;;
            5)
                aws-who
                echo ""
                read -p "Pressione Enter para continuar..."
                ;;
            6)
                aws-list-secure-tokens
                echo ""
                echo "Comandos disponíveis:"
                echo "  aws-secure-tokens - Proteger tokens existentes"
                echo "  aws-restore-token <nome> - Restaurar token específico"
                echo ""
                read -p "Pressione Enter para continuar..."
                ;;
            7)
                aws-discover-org
                echo ""
                read -p "Pressione Enter para continuar..."
                ;;
            8)
                echo "👋 Até logo!"
                break
                ;;
            *)
                echo "❌ Opção inválida"
                sleep 1
                ;;
        esac
    done
}

echo "🎯 Interface TUI AWS SSO carregada"
echo "📋 Comandos disponíveis:"
echo "   aws-choose    - Seletor interativo de perfis"
echo "   aws-quick     - Troca rápida com fuzzy finder"
echo "   aws-tree      - Navegação em árvore"
echo "   aws-menu      - Menu principal TUI"