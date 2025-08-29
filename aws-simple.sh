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

# Lista perfis com interface bonita
_list_profiles() {
    clear
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                   📋 PERFIS AWS DISPONÍVEIS              ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    
    local current=$(_get_current_profile)
    local count=0
    
    aws configure list-profiles 2>/dev/null | while read profile; do
        if [ "$profile" = "$current" ]; then
            echo "║  ➤ $profile (perfil atual)"
        else
            echo "║    $profile"
        fi
        count=$((count + 1))
    done
    
    echo "╚══════════════════════════════════════════════════════════╝"
}

# Seletor visual de perfis  
_select_profile_visual() {
    while true; do
        clear
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║              🔄 SELEÇÃO VISUAL DE PERFIS                ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo ""
        
        local current_profile=$(_get_current_profile)
        local profiles=($(aws configure list-profiles 2>/dev/null))
        local count=1
        
        echo "📋 Selecione o perfil desejado:"
        echo ""
        
        # Lista perfis numerados
        for profile in "${profiles[@]}"; do
            if [ "$profile" = "$current_profile" ]; then
                echo "  $count) ➤ $profile (atual)"
            else
                echo "  $count)   $profile"
            fi
            count=$((count + 1))
        done
        
        echo ""
        echo "  0) ⬅️  Voltar ao menu principal"
        echo ""
        
        read -p "📌 Digite o número do perfil [0-$((count-1))]: " choice
        
        # Valida escolha
        if [ "$choice" = "0" ]; then
            break
        elif [ "$choice" -gt 0 ] && [ "$choice" -lt "$count" ] 2>/dev/null; then
            local selected_profile=${profiles[$((choice-1))]}
            
            clear
            echo "╔══════════════════════════════════════════════════════════╗"
            echo "║                    🔄 ALTERANDO PERFIL                  ║"
            echo "╚══════════════════════════════════════════════════════════╝"
            echo ""
            echo "🔄 Alterando para: $selected_profile"
            echo ""
            
            _save_profile "$selected_profile"
            echo "✅ Perfil alterado com sucesso!"
            
            # Verifica credenciais
            echo "🔍 Verificando credenciais..."
            if aws sts get-caller-identity --output table 2>/dev/null; then
                echo ""
                echo "🔑 Credenciais válidas!"
            else
                echo ""
                echo "⚠️  Credenciais expiradas ou inválidas"
                echo "💡 Execute: aws sso login --profile $selected_profile"
            fi
            
            echo ""
            read -p "Pressione Enter para voltar ao menu..."
            break
        else
            echo ""
            echo "❌ Opção inválida! Digite um número entre 0 e $((count-1))"
            sleep 2
        fi
    done
}

# Menu principal bonito
_main_menu() {
    while true; do
        clear
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║                    🚀 AWS SSO Manager                   ║"
        echo "╠══════════════════════════════════════════════════════════╣"
        echo "║                                                          ║"
        echo "║  📋 Perfil atual: $(_get_current_profile)"
        echo "║                                                          ║"
        echo "║  1) 📋 Listar todos os perfis                           ║"
        echo "║  2) 🔄 Selecionar perfil (Interface visual)             ║" 
        echo "║  3) 🔐 Fazer login SSO                                  ║"
        echo "║  4) 👤 Ver status e credenciais                         ║"
        echo "║  5) 🚪 Sair                                             ║"
        echo "║                                                          ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo ""
        read -p "📌 Escolha uma opção [1-5]: " choice
        
        case $choice in
            1)
                _list_profiles
                read -p "Pressione Enter..."
                ;;
            2)
                _select_profile_visual
                ;;
            3)
                clear
                echo "╔══════════════════════════════════════════════════════════╗"
                echo "║                      🔐 LOGIN SSO                       ║"
                echo "╚══════════════════════════════════════════════════════════╝"
                echo ""
                
                # Mostra perfis disponíveis
                echo "📋 Perfis disponíveis:"
                echo ""
                local profiles=($(aws configure list-profiles 2>/dev/null))
                local count=1
                for profile in "${profiles[@]}"; do
                    echo "  $count) $profile"
                    count=$((count + 1))
                done
                echo ""
                
                read -p "💻 Digite o número ou nome do perfil para login: " input
                if [ -n "$input" ]; then
                    # Verifica se é um número
                    if [[ "$input" =~ ^[0-9]+$ ]]; then
                        # Converte número para nome do perfil
                        if [ "$input" -gt 0 ] && [ "$input" -lt "$count" ]; then
                            profile=${profiles[$((input-1))]}
                            echo "📋 Perfil selecionado: $profile"
                        else
                            echo "❌ Número inválido! Digite entre 1 e $((count-1))"
                            profile=""
                        fi
                    else
                        # Usa o nome diretamente
                        profile="$input"
                    fi
                    
                    if [ -n "$profile" ] && aws configure list-profiles 2>/dev/null | grep -q "^${profile}$"; then
                        echo ""
                        echo "🔐 Fazendo login SSO no perfil: $profile"
                        echo ""
                        echo "💡 INSTRUÇÕES PARA WSL/Linux:"
                        echo "   1. O navegador pode não abrir automaticamente"
                        echo "   2. Copie a URL que aparecer abaixo"
                        echo "   3. Cole no seu navegador (Chrome/Firefox/Edge)"
                        echo "   4. Use o código de autorização mostrado"
                        echo "   5. WSL: Você pode usar 'cmd.exe /c start URL' para abrir no Windows"
                        echo ""
                        echo "🚀 Iniciando login SSO..."
                        echo ""
                        
                        # Captura erros do xdg-open mas continua o processo
                        aws sso login --profile "$profile" 2>/dev/null || aws sso login --profile "$profile"
                        
                        if [ $? -eq 0 ]; then
                            _save_profile "$profile"
                            echo ""
                            echo "✅ Login realizado com sucesso!"
                            echo "📋 Perfil alterado para: $profile"
                            echo "🔑 Credenciais SSO configuradas!"
                        else
                            echo ""
                            echo "❌ Falha no login SSO"
                            echo "💡 Dicas:"
                            echo "   - Verifique se copiou a URL corretamente"
                            echo "   - Confirme se usou o código correto"
                            echo "   - Tente novamente se necessário"
                        fi
                    else
                        echo ""
                        echo "❌ Perfil '$profile' não encontrado"
                        echo "💡 Use o número (ex: 2) ou nome completo (ex: wiipo-prod)"
                    fi
                else
                    echo ""
                    echo "❌ Nada foi digitado!"
                    echo "💡 Digite o número ou nome do perfil"
                fi
                echo ""
                read -p "Pressione Enter para voltar ao menu..."
                ;;
            4)
                clear
                echo "╔══════════════════════════════════════════════════════════╗"
                echo "║                 👤 STATUS E CREDENCIAIS                 ║"
                echo "╚══════════════════════════════════════════════════════════╝"
                echo ""
                echo "📋 Perfil atual: $(_get_current_profile)"
                echo ""
                echo "🔍 Verificando credenciais..."
                echo ""
                if aws sts get-caller-identity --output table 2>/dev/null; then
                    echo ""
                    echo "✅ Credenciais válidas e ativas!"
                else
                    echo "❌ Credenciais inválidas ou expiradas"
                    echo ""
                    echo "💡 Para fazer login:"
                    echo "   aws sso login --profile $(_get_current_profile)"
                fi
                echo ""
                read -p "Pressione Enter para voltar ao menu..."
                ;;
            5)
                clear
                echo "╔══════════════════════════════════════════════════════════╗"
                echo "║                        👋 SAINDO                        ║"
                echo "╚══════════════════════════════════════════════════════════╝"
                echo ""
                echo "✅ Perfil atual salvo: $(_get_current_profile)"
                echo ""
                echo "💡 Para usar novamente: ./aws-simple.sh"
                echo ""
                echo "👋 Obrigado por usar o AWS SSO Manager!"
                echo ""
                exit 0
                ;;
            *)
                clear
                echo "╔══════════════════════════════════════════════════════════╗"
                echo "║                      ❌ OPÇÃO INVÁLIDA                   ║"
                echo "╚══════════════════════════════════════════════════════════╝"
                echo ""
                echo "⚠️  Opção '$choice' não é válida"
                echo ""
                echo "💡 Escolha um número entre 1 e 5"
                echo ""
                read -p "Pressione Enter para continuar..."
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