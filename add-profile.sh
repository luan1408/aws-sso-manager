#!/bin/bash

# Script para adicionar novos perfis AWS SSO
# Uso: ./add-aws-profile.sh

echo "🔧 Assistente para adicionar perfis AWS SSO"
echo "═══════════════════════════════════════════"

read -p "Nome do perfil (ex: empresa-prod): " profile_name
read -p "SSO Start URL (ex: https://empresa.awsapps.com/start): " sso_url  
read -p "SSO Region (ex: us-east-1): " sso_region
read -p "Account ID: " account_id
read -p "Role Name (ex: AdministratorAccess): " role_name
read -p "Region padrão (ex: us-east-1): " default_region

echo ""
echo "📝 Adicionando perfil ao ~/.aws/config..."

cat >> ~/.aws/config << EOF

[profile $profile_name]
sso_start_url = $sso_url
sso_region = $sso_region
sso_account_id = $account_id
sso_role_name = $role_name
region = $default_region
output = json
EOF

echo "✅ Perfil '$profile_name' adicionado com sucesso!"
echo ""
echo "🔐 Para fazer login:"
echo "   aws-login $profile_name"
echo ""
echo "🔄 Para usar:"  
echo "   aws-switch $profile_name"
echo ""
echo "📋 Ver todos os perfis:"
echo "   aws-list"