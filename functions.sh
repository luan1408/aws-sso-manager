# Funções AWS - Gerenciamento inteligente de perfis (Versão Corrigida)

# Função auxiliar para obter o perfil atual com persistência
_get_current_profile() {
    # Lê sempre do arquivo de estado primeiro (mais confiável)
    if [ -f ~/.aws/current_profile ]; then
        local saved_profile
        saved_profile=$(cat ~/.aws/current_profile 2>/dev/null)
        if [ -n "$saved_profile" ]; then
            echo "$saved_profile"
            return
        fi
    fi
    
    # Se não há arquivo ou está vazio, usa AWS_PROFILE ou default
    if [ -n "$AWS_PROFILE" ]; then
        echo "$AWS_PROFILE"
    else
        echo "default"
    fi
}

# Lista todos os perfis AWS disponíveis
aws-list() {
    echo "📋 Perfis AWS disponíveis:"
    echo "─────────────────────────────────"
    
    local current_profile
    current_profile=$(_get_current_profile)
    
    # Lista perfis do ~/.aws/config
    aws configure list-profiles 2>/dev/null | while read profile; do
        if [ "$profile" = "$current_profile" ]; then
            echo "➤ $profile (atual)"
        else
            echo "  $profile"
        fi
    done
    
    echo "─────────────────────────────────"
    echo "Uso: aws-switch <perfil>"
    echo "Login SSO: aws-login <perfil>"
}

# Função inteligente para trocar perfis AWS
aws-switch() {
    if [ $# -eq 0 ]; then
        aws-list
        return 1
    fi

    local target_profile=$1
    
    # Limpa credenciais de ambiente
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    
    # Verifica se o perfil existe
    if ! aws configure list-profiles 2>/dev/null | grep -q "^${target_profile}$"; then
        echo "❌ Perfil '$target_profile' não encontrado."
        aws-list
        return 1
    fi
    
    # Define o perfil
    export AWS_PROFILE="$target_profile"
    
    # Salva o perfil atual para persistência entre sessões
    mkdir -p ~/.aws
    echo "$target_profile" > ~/.aws/current_profile
    
    echo "✅ Trocado para perfil: $AWS_PROFILE"
    
    # Verifica se as credenciais estão válidas
    if aws sts get-caller-identity --query '[UserId,Account]' --output table 2>/dev/null; then
        echo "🔑 Credenciais válidas"
    else
        echo "⚠️  Credenciais inválidas ou expiradas. Execute: aws-login $AWS_PROFILE"
    fi
}

# Faz login SSO em um perfil específico
aws-login() {
    if [ $# -eq 0 ]; then
        echo "Uso: aws-login <perfil>"
        aws-list
        return 1
    fi

    local profile=$1
    
    # Verifica se o perfil existe
    if ! aws configure list-profiles 2>/dev/null | grep -q "^${profile}$"; then
        echo "❌ Perfil '$profile' não encontrado."
        aws-list
        return 1
    fi
    
    echo "🔐 Fazendo login SSO no perfil: $profile"
    aws sso login --profile "$profile"
    
    if [ $? -eq 0 ]; then
        export AWS_PROFILE="$profile"
        # Salva o perfil atual para persistência entre sessões
        mkdir -p ~/.aws
        echo "$profile" > ~/.aws/current_profile
        echo "✅ Login realizado com sucesso!"
        aws sts get-caller-identity --query '[UserId,Account]' --output table 2>/dev/null
    else
        echo "❌ Falha no login SSO"
    fi
}

# Mostra informações da conta atual
aws-who() {
    local current_profile
    current_profile=$(_get_current_profile)
    echo "📋 Perfil atual: $current_profile"
    aws sts get-caller-identity --query '[UserId,Account]' --output table 2>/dev/null || echo "❌ Não logado ou credenciais expiradas"
}

# Logout de todos os perfis SSO
aws-logout() {
    echo "🚪 Fazendo logout SSO..."
    aws sso logout
    unset AWS_PROFILE
    echo "✅ Logout realizado"
}

# Atalhos para perfis mais usados
alias aws-dev='aws-switch empresa-dev'
alias aws-prod='aws-switch empresa-prod'
alias aws-default='aws-switch default'

echo "✅ Funções AWS carregadas com sucesso!"
echo "📋 Comandos disponíveis: aws-list, aws-switch, aws-login, aws-who, aws-logout"