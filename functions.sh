# Funções AWS - Gerenciamento inteligente de perfis
# Adicione isso ao seu ~/.bashrc

# Lista todos os perfis AWS disponíveis
aws-list() {
    echo "📋 Perfis AWS disponíveis:"
    echo "─────────────────────────────────"
    
    local current_profile="${AWS_PROFILE:-default}"
    
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
        echo "✅ Login realizado com sucesso!"
        aws sts get-caller-identity --query '[UserId,Account]' --output table 2>/dev/null
    else
        echo "❌ Falha no login SSO"
    fi
}

# Mostra informações da conta atual
aws-who() {
    echo "📋 Perfil atual: ${AWS_PROFILE:-default}"
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