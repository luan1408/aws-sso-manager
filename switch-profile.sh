#!/bin/bash

# Script para trocar perfis AWS SSO
# Uso: ./aws-switch.sh dev|prod|local

if [ $# -eq 0 ]; then
    echo "Uso: $0 [dev|prod|local|default]"
    echo "Perfil atual: ${AWS_PROFILE:-default}"
    exit 1
fi

PROFILE=$1

# Limpa credenciais de ambiente que podem sobrescrever SSO
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

# Define o perfil baseado no argumento
case $PROFILE in
    "dev")
        export AWS_PROFILE=empresa-dev
        ;;
    "prod")
        export AWS_PROFILE=empresa-prod
        ;;
    "local")
        export AWS_PROFILE=local
        ;;
    "default")
        export AWS_PROFILE=default
        ;;
    *)
        echo "Perfil inválido. Use: dev, prod, local ou default"
        exit 1
        ;;
esac

echo "✅ Trocado para perfil: $AWS_PROFILE"

# Mostra qual conta está sendo usada
aws sts get-caller-identity --query '[UserId,Account]' --output table 2>/dev/null || echo "❌ Erro ao verificar credenciais"