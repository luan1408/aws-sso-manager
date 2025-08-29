#!/bin/bash

# AWS SSO Manager - Script de Instalação/Atualização Inteligente
# Detecta versões antigas, remove conflitos e instala versão atualizada

set -e  # Para no primeiro erro

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASHRC_FILE="$HOME/.bashrc"
AWS_SSO_TEMP_BACKUP="$HOME/.bashrc.aws-sso-backup.$(date +%s)"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║          🚀 AWS SSO Manager - Auto Installer            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Função para log colorido
log_info() { echo "ℹ️  $1"; }
log_success() { echo "✅ $1"; }
log_warning() { echo "⚠️  $1"; }
log_error() { echo "❌ $1"; }

# Backup do .bashrc
backup_bashrc() {
    if [ -f "$BASHRC_FILE" ]; then
        log_info "Criando backup do .bashrc..."
        cp "$BASHRC_FILE" "$AWS_SSO_TEMP_BACKUP"
        log_success "Backup salvo em: $AWS_SSO_TEMP_BACKUP"
    fi
}

# Detecta instalações antigas
detect_old_installations() {
    log_info "🔍 Detectando instalações antigas..."
    
    local found_old=false
    
    # Procura por linhas relacionadas ao AWS SSO Manager
    if grep -q "aws-sso-manager\|AWS SSO Manager\|aws-list\|aws-switch\|aws-menu" "$BASHRC_FILE" 2>/dev/null; then
        log_warning "Encontradas instalações antigas no .bashrc"
        
        echo ""
        echo "📋 Linhas encontradas:"
        grep -n "aws-sso-manager\|AWS SSO Manager\|aws-list\|aws-switch\|aws-menu" "$BASHRC_FILE" | head -10
        
        found_old=true
    fi
    
    # Verifica funções já carregadas no ambiente atual
    if type aws-list >/dev/null 2>&1; then
        log_warning "Funções AWS SSO já carregadas no ambiente atual"
        found_old=true
    fi
    
    if [ "$found_old" = true ]; then
        echo ""
        read -p "🧹 Deseja remover instalações antigas e instalar versão limpa? (Y/n): " confirm
        confirm=${confirm:-Y}
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_error "Instalação cancelada pelo usuário"
            exit 1
        fi
    else
        log_success "Nenhuma instalação antiga detectada"
    fi
}

# Remove instalações antigas
remove_old_installations() {
    log_info "🧹 Removendo instalações antigas..."
    
    # Cria arquivo temporário limpo
    local temp_bashrc=$(mktemp)
    local inside_aws_block=false
    
    # Lê linha por linha e remove blocos AWS
    while IFS= read -r line; do
        # Detecta início de bloco AWS
        if echo "$line" | grep -q "AWS SSO Manager\|aws-sso-manager\|# Lista todos os perfis AWS\|# Função inteligente para trocar"; then
            inside_aws_block=true
            continue
        fi
        
        # Detecta fim de bloco AWS (linha vazia após funções AWS)
        if [ "$inside_aws_block" = true ] && [ -z "$line" ]; then
            inside_aws_block=false
            continue
        fi
        
        # Pula linhas relacionadas ao AWS
        if echo "$line" | grep -q "aws-list\|aws-switch\|aws-menu\|aws-choose\|aws-quick\|aws-who\|aws-login\|aws-logout\|aws-dev\|aws-prod"; then
            continue
        fi
        
        # Mantém linha se não estiver em bloco AWS
        if [ "$inside_aws_block" = false ]; then
            echo "$line" >> "$temp_bashrc"
        fi
        
    done < "$BASHRC_FILE"
    
    # Substitui o .bashrc
    mv "$temp_bashrc" "$BASHRC_FILE"
    
    log_success "Instalações antigas removidas"
}

# Instala versão atual
install_current_version() {
    log_info "📦 Instalando versão atual..."
    
    # Adiciona configuração limpa ao .bashrc
    cat >> "$BASHRC_FILE" << EOF

# ═══════════════════════════════════════════════════════════════════
# 🚀 AWS SSO Manager Enhanced - Instalação Automatizada
# Instalado automaticamente em: $(date)
# ═══════════════════════════════════════════════════════════════════

# Carrega AWS SSO Manager se disponível
if [ -f "$SCRIPT_DIR/functions.sh" ]; then
    source "$SCRIPT_DIR/functions.sh"
fi
EOF

    log_success "Instalação no .bashrc concluída"
}

# Valida instalação
validate_installation() {
    log_info "🧪 Validando instalação..."
    
    # Testa em nova sessão bash
    if bash -c "source '$BASHRC_FILE' >/dev/null 2>&1 && type aws-list >/dev/null 2>&1"; then
        log_success "Funções AWS carregadas com sucesso"
        
        # Testa funcionalidade básica
        if bash -c "source '$BASHRC_FILE' >/dev/null 2>&1 && aws-list >/dev/null 2>&1"; then
            log_success "Comando aws-list funcionando"
        else
            log_warning "aws-list com problemas - verifique configuração AWS"
        fi
        
    else
        log_error "Falha no carregamento das funções"
        return 1
    fi
}

# Recarrega ambiente
reload_environment() {
    log_info "🔄 Recarregando ambiente..."
    
    # Limpa funções antigas do ambiente atual
    unset -f aws-list aws-switch aws-who aws-login aws-logout aws-menu 2>/dev/null || true
    unset -f aws-choose aws-quick aws-tree aws-help 2>/dev/null || true
    unset -f _get_current_profile _init_aws_profile 2>/dev/null || true
    
    # Recarrega .bashrc
    if source "$BASHRC_FILE" >/dev/null 2>&1; then
        log_success "Ambiente recarregado com sucesso"
    else
        log_warning "Erro ao recarregar - execute 'source ~/.bashrc' manualmente"
    fi
}

# Mostra instruções finais
show_final_instructions() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                   ✅ INSTALAÇÃO CONCLUÍDA                ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║                                                          ║"
    echo "║  🎯 COMANDOS DISPONÍVEIS:                               ║"
    echo "║    aws-menu         - Interface interativa               ║"
    echo "║    aws-list         - Lista perfis                      ║"
    echo "║    aws-switch       - Troca perfil                      ║"
    echo "║    aws-who          - Perfil atual                      ║"
    echo "║    aws-help         - Ajuda completa                    ║"
    echo "║                                                          ║"
    echo "║  💡 PARA NOVOS TERMINAIS:                               ║"
    echo "║    As funções serão carregadas automaticamente          ║"
    echo "║                                                          ║"
    echo "║  🔄 PARA ATUALIZAR NOVAMENTE:                           ║"
    echo "║    ./install-or-update.sh                               ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    
    # Testa comando final
    if type aws-list >/dev/null 2>&1; then
        echo "🎉 Teste final: aws-list funcionando!"
        aws-list 2>/dev/null || echo "⚠️  Configure seus perfis AWS primeiro"
    else
        echo "⚠️  Execute 'source ~/.bashrc' para ativar as funções"
    fi
}

# Função principal
main() {
    echo "🚀 Iniciando instalação/atualização do AWS SSO Manager..."
    echo ""
    
    # Verifica se estamos no diretório correto
    if [ ! -f "$SCRIPT_DIR/functions.sh" ]; then
        log_error "Arquivo functions.sh não encontrado em $SCRIPT_DIR"
        log_error "Execute este script dentro do diretório aws-sso-manager"
        exit 1
    fi
    
    backup_bashrc
    detect_old_installations
    remove_old_installations
    install_current_version
    reload_environment
    validate_installation
    show_final_instructions
    
    echo ""
    log_success "🎯 Instalação/atualização concluída com sucesso!"
    log_info "🗑️  Backup anterior salvo em: $AWS_SSO_TEMP_BACKUP"
}

# Executa instalação
main "$@"