#!/bin/bash

# AWS SSO Manager - Script de Instalação
# Este script instala as funções AWS SSO no seu sistema

set -e  # Para na primeira falha

echo "🚀 AWS SSO Manager - Instalador"
echo "================================"

# Verificar requisitos
check_requirements() {
    echo "🔍 Verificando requisitos..."
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI não encontrado. Instale primeiro: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Verificar versão do AWS CLI
    aws_version=$(aws --version 2>&1 | grep -o 'aws-cli/[0-9]\+\.[0-9]\+' | cut -d'/' -f2 | cut -d'.' -f1)
    if [ "$aws_version" -lt 2 ]; then
        echo "⚠️  AWS CLI v2 é recomendado. Versão atual: $(aws --version)"
        read -p "Continuar mesmo assim? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo "✅ AWS CLI v2 encontrado"
}

# Backup do .bashrc atual
backup_bashrc() {
    if [ -f ~/.bashrc ]; then
        echo "💾 Fazendo backup do .bashrc..."
        cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
        echo "✅ Backup salvo em ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Instalar funções no .bashrc
install_functions() {
    echo "📦 Instalando funções AWS SSO..."
    
    # Verificar se já está instalado
    if grep -q "# AWS SSO Manager Functions" ~/.bashrc 2>/dev/null; then
        echo "⚠️  Funções já estão instaladas no .bashrc"
        read -p "Reinstalar? Isso irá duplicar as funções (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "⏭️  Pulando instalação das funções"
            return 0
        fi
    fi
    
    # Adicionar marcador e funções ao .bashrc
    echo "" >> ~/.bashrc
    echo "# AWS SSO Manager Functions" >> ~/.bashrc
    echo "# Instalado em $(date)" >> ~/.bashrc
    cat functions.sh >> ~/.bashrc
    echo "" >> ~/.bashrc
    
    echo "✅ Funções adicionadas ao ~/.bashrc"
}

# Criar diretório bin se não existir
setup_bin_directory() {
    if [ ! -d ~/bin ]; then
        echo "📁 Criando diretório ~/bin..."
        mkdir -p ~/bin
        
        # Adicionar ~/bin ao PATH se não estiver
        if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
            echo "🔗 Adicionando ~/bin ao PATH..."
            echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        fi
    fi
}

# Instalar scripts auxiliares
install_scripts() {
    echo "📋 Instalando scripts auxiliares..."
    
    setup_bin_directory
    
    # Copiar e dar permissão de execução
    cp add-profile.sh ~/bin/aws-add-profile
    cp switch-profile.sh ~/bin/aws-switch-standalone
    chmod +x ~/bin/aws-add-profile
    chmod +x ~/bin/aws-switch-standalone
    
    echo "✅ Scripts instalados em ~/bin/"
    echo "   - aws-add-profile (para adicionar novos perfis)"
    echo "   - aws-switch-standalone (script standalone)"
}

# Configurar atalhos personalizáveis
configure_aliases() {
    echo "⚙️  Configurando atalhos..."
    
    # Perguntar sobre customização de atalhos
    echo ""
    echo "🎯 Quer configurar atalhos personalizados? (ex: aws-dev, aws-prod)"
    read -p "Configurar atalhos agora? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Configure seus atalhos (pressione Enter para pular):"
        
        read -p "Perfil de desenvolvimento (ex: empresa-dev): " dev_profile
        read -p "Perfil de produção (ex: empresa-prod): " prod_profile
        read -p "Perfil padrão (ex: default): " default_profile
        
        if [ -n "$dev_profile" ] || [ -n "$prod_profile" ] || [ -n "$default_profile" ]; then
            echo "" >> ~/.bashrc
            echo "# AWS SSO Manager - Atalhos Personalizados" >> ~/.bashrc
            
            [ -n "$dev_profile" ] && echo "alias aws-dev='aws-switch $dev_profile'" >> ~/.bashrc
            [ -n "$prod_profile" ] && echo "alias aws-prod='aws-switch $prod_profile'" >> ~/.bashrc
            [ -n "$default_profile" ] && echo "alias aws-default='aws-switch $default_profile'" >> ~/.bashrc
            
            echo "✅ Atalhos personalizados configurados!"
        fi
    fi
}

# Testar instalação
test_installation() {
    echo "🧪 Testando instalação..."
    
    # Recarregar .bashrc no contexto atual
    source ~/.bashrc
    
    # Verificar se as funções estão disponíveis
    if command -v aws-list &> /dev/null; then
        echo "✅ Funções instaladas com sucesso!"
        
        # Mostrar perfis disponíveis se existirem
        echo ""
        echo "📋 Perfis AWS encontrados:"
        aws configure list-profiles 2>/dev/null || echo "   Nenhum perfil configurado ainda"
        
    else
        echo "⚠️  Funções instaladas mas não carregadas. Execute:"
        echo "   source ~/.bashrc"
    fi
}

# Mostrar próximos passos
show_next_steps() {
    echo ""
    echo "🎉 Instalação concluída!"
    echo "======================="
    echo ""
    echo "📚 Próximos passos:"
    echo "1. Recarregue o terminal: source ~/.bashrc"
    echo "2. Liste perfis disponíveis: aws-list"
    echo "3. Configure um novo perfil: aws-add-profile"
    echo "4. Faça login SSO: aws-login <perfil>"
    echo "5. Troque entre perfis: aws-switch <perfil>"
    echo ""
    echo "📖 Para mais detalhes, veja o README.md"
    echo "🆘 Para suporte: https://github.com/SEU_USUARIO/aws-sso-manager/issues"
}

# Função principal
main() {
    # Verificar se estamos no diretório correto
    if [ ! -f "functions.sh" ]; then
        echo "❌ Arquivo functions.sh não encontrado."
        echo "Execute este script do diretório aws-sso-manager/"
        exit 1
    fi
    
    check_requirements
    backup_bashrc
    install_functions
    install_scripts
    configure_aliases
    test_installation
    show_next_steps
}

# Executar instalação
main "$@"