#!/bin/bash
# Script para usar diretamente as funções AWS

cd "$(dirname "$0")"
source ./functions.sh

case "$1" in
    "list")
        aws-list
        ;;
    "switch")
        if [ -z "$2" ]; then
            echo "Uso: $0 switch <perfil>"
            aws-list
        else
            aws-switch "$2"
        fi
        ;;
    "who")
        aws-who
        ;;
    "login")
        if [ -z "$2" ]; then
            echo "Uso: $0 login <perfil>"
        else
            aws-login "$2"
        fi
        ;;
    *)
        echo "🚀 AWS SSO Manager - Uso Direto"
        echo "Comandos disponíveis:"
        echo "  $0 list                 - Lista perfis"
        echo "  $0 switch <perfil>      - Troca perfil"
        echo "  $0 who                  - Perfil atual"
        echo "  $0 login <perfil>       - Login SSO"
        echo ""
        echo "Exemplo: $0 list"
        ;;
esac