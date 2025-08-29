# Funções AWS - Gerenciamento inteligente de perfis
# Adicione isso ao seu ~/.bashrc

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

# Inicializa o perfil AWS se não estiver definido
_init_aws_profile() {
    if [ -z "$AWS_PROFILE" ] && [ -f ~/.aws/current_profile ]; then
        local saved_profile
        saved_profile=$(cat ~/.aws/current_profile 2>/dev/null)
        if [ -n "$saved_profile" ]; then
            export AWS_PROFILE="$saved_profile"
        fi
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

# Descobre e configura todas as contas da organização
aws-discover-org() {
    echo "🔍 Descobrindo contas da organização AWS..."
    echo "═══════════════════════════════════════════"
    
    # Verifica se tem permissões para listar contas da organização
    if ! aws organizations list-accounts --query 'Accounts[0].Id' --output text >/dev/null 2>&1; then
        echo "❌ Erro: Não foi possível acessar AWS Organizations."
        echo "   Certifique-se de ter permissões para 'organizations:ListAccounts'"
        echo "   E estar logado em uma conta que é parte da organização."
        return 1
    fi
    
    # Parâmetros padrão (podem ser customizados)
    read -p "🔗 SSO Start URL (ex: https://sua-empresa.awsapps.com/start): " sso_start_url
    if [ -z "$sso_start_url" ]; then
        echo "❌ SSO Start URL é obrigatório"
        return 1
    fi
    
    read -p "🌎 SSO Region (padrão: us-east-1): " sso_region
    sso_region=${sso_region:-us-east-1}
    
    read -p "👤 Role Name padrão (ex: AdministratorAccess): " default_role
    if [ -z "$default_role" ]; then
        echo "❌ Role Name é obrigatório"
        return 1
    fi
    
    read -p "🌍 Region padrão (padrão: us-east-1): " default_region
    default_region=${default_region:-us-east-1}
    
    echo ""
    echo "📋 Buscando contas da organização..."
    
    # Lista todas as contas
    local accounts_json
    accounts_json=$(aws organizations list-accounts --output json)
    
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao buscar contas da organização"
        return 1
    fi
    
    # Processa cada conta usando Python ao invés de jq
    echo "$accounts_json" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for account in data['Accounts']:
    print(f\"{account['Id']}|{account['Name']}|{account['Status']}\")
" | while IFS='|' read -r account_id account_name status; do
        if [ "$status" = "ACTIVE" ]; then
            echo ""
            echo "🏢 Conta encontrada: $account_name (ID: $account_id)"
            
            # Sugere um nome de perfil baseado no nome da conta
            local suggested_name
            suggested_name=$(echo "$account_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
            
            read -p "   Criar perfil para esta conta? (Y/n): " create_profile
            create_profile=${create_profile:-Y}
            
            if [[ "$create_profile" =~ ^[Yy]$ ]]; then
                read -p "   Nome do perfil [$suggested_name]: " profile_name
                profile_name=${profile_name:-$suggested_name}
                
                read -p "   Role name [$default_role]: " role_name
                role_name=${role_name:-$default_role}
                
                # Verifica se o perfil já existe
                if aws configure list-profiles 2>/dev/null | grep -q "^${profile_name}$"; then
                    echo "   ⚠️  Perfil '$profile_name' já existe. Pulando..."
                else
                    # Adiciona o perfil ao ~/.aws/config
                    cat >> ~/.aws/config << EOF

[profile $profile_name]
sso_start_url = $sso_start_url
sso_region = $sso_region
sso_account_id = $account_id
sso_role_name = $role_name
region = $default_region
output = json
EOF
                    echo "   ✅ Perfil '$profile_name' criado com sucesso!"
                fi
            fi
        else
            echo "⏸️  Conta inativa ignorada: $account_name (Status: $status)"
        fi
    done
    
    echo ""
    echo "🎉 Descoberta concluída!"
    echo "📋 Para ver todos os perfis: aws-list"
    echo "🔐 Para fazer login em um perfil: aws-login <nome-do-perfil>"
}

# Atalhos para perfis mais usados
alias aws-dev='aws-switch empresa-dev'
alias aws-prod='aws-switch empresa-prod'
alias aws-default='aws-switch default'

# ═══════════════════════════════════════════════════════════════════
# 🚀 AWS SSO Manager Enhanced - Novos Recursos
# ═══════════════════════════════════════════════════════════════════

# Detecta diretório do AWS SSO Manager
AWS_SSO_MANAGER_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Carrega funções de criptografia (se disponível)
if [ -f "$AWS_SSO_MANAGER_DIR/crypto-functions.sh" ]; then
    source "$AWS_SSO_MANAGER_DIR/crypto-functions.sh"
fi

# Carrega funções TUI (se disponível)
if [ -f "$AWS_SSO_MANAGER_DIR/tui-functions.sh" ]; then
    source "$AWS_SSO_MANAGER_DIR/tui-functions.sh"
fi

# Função de boas-vindas com novos recursos
aws-help() {
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║               🚀 AWS SSO Manager Enhanced               ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║                                                          ║"
    echo "║  📋 COMANDOS BÁSICOS:                                   ║"
    echo "║    aws-list         - Lista perfis disponíveis          ║"
    echo "║    aws-switch       - Troca perfil                      ║"
    echo "║    aws-login        - Login SSO                          ║"
    echo "║    aws-who          - Perfil atual                      ║"
    echo "║    aws-logout       - Logout completo                   ║"
    echo "║    aws-discover-org - Descobrir contas da organização   ║"
    echo "║                                                          ║"
    echo "║  🎯 INTERFACE TUI (NOVO!):                              ║"
    echo "║    aws-menu         - Menu principal interativo         ║"
    echo "║    aws-choose       - Seletor interativo c/ preview     ║"
    echo "║    aws-quick        - Troca rápida com fuzzy finder     ║"
    echo "║    aws-tree         - Navegação em árvore               ║"
    echo "║                                                          ║"
    echo "║  🔐 SEGURANÇA (NOVO!):                                  ║"
    echo "║    aws-secure-tokens     - Criptografar tokens          ║"
    echo "║    aws-list-secure-tokens - Listar tokens protegidos    ║"
    echo "║    aws-restore-token     - Restaurar token específico   ║"
    echo "║                                                          ║"
    echo "║  ⚡ ATALHOS RÁPIDOS:                                    ║"
    echo "║    aws-dev          - Trocar para empresa-dev           ║"
    echo "║    aws-prod         - Trocar para empresa-prod          ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "💡 Dica: Use 'aws-menu' para uma experiência interativa completa!"
    echo "🔐 Dica: Seus tokens são automaticamente criptografados para segurança!"
}

echo ""
echo "🚀 AWS SSO Manager Enhanced carregado!"
echo "📋 Digite 'aws-help' para ver todos os comandos disponíveis"
echo "🎯 Digite 'aws-menu' para interface interativa"