# AWS SSO Manager Enhanced 🚀

[![Author](https://img.shields.io/badge/Author-luan1408-blue?style=flat-square)](https://github.com/luan1408)
![Enhanced](https://img.shields.io/badge/Enhanced-Security%20%2B%20TUI-green?style=flat-square)
![Status](https://img.shields.io/badge/Status-Ready-brightgreen?style=flat-square)

🔐 **Versão aprimorada** do AWS SSO Manager com **criptografia de tokens** e **interface TUI interativa**!

## ✨ Novos Recursos

### 🔐 **Segurança Avançada**
- **Criptografia automática** de tokens SSO (AES-256-CBC)
- **Proteção transparente** - funciona sem interferir no workflow
- **Chave mestre** gerada automaticamente e protegida
- **Interceptação inteligente** - criptografa novos tokens automaticamente

### 🎯 **Interface TUI Moderna**
- **Fuzzy finder** para seleção rápida de perfis
- **Preview em tempo real** do status das credenciais
- **Navegação interativa** com setas e atalhos
- **Menu principal** com todas as funcionalidades
- **Compatível** com terminais modernos

## 🚀 Instalação Enhanced

### Opção 1: Instalação Automática Enhanced
```bash
curl -sSL https://raw.githubusercontent.com/luan1408/aws-sso-manager/main/install-enhanced.sh | bash
```

### Opção 2: Instalação Manual Enhanced
```bash
# 1. Clone o repositório
git clone https://github.com/luan1408/aws-sso-manager.git
cd aws-sso-manager

# 2. Execute o instalador enhanced
./install-enhanced.sh
```

### Opção 3: Upgrade de Instalação Existente
Se você já tem o AWS SSO Manager instalado:
```bash
# No diretório do projeto
git pull origin main
./install-enhanced.sh
```

## 🎯 Novos Comandos

### 🔥 Interface TUI Interativa

| Comando | Descrição |
|---------|-----------|
| `aws-menu` | **Menu principal interativo** - Acesso a todas as funcionalidades |
| `aws-choose` | **Seletor de perfil com preview** - Fuzzy finder com status em tempo real |
| `aws-quick` | **Troca rápida** - Seleção direta com fuzzy finder |
| `aws-tree` | **Navegação em árvore** - Organiza perfis por grupos |

### 🔐 Segurança de Tokens

| Comando | Descrição |
|---------|-----------|
| `aws-secure-tokens` | Criptografa todos os tokens SSO existentes |
| `aws-list-secure-tokens` | Lista tokens protegidos |
| `aws-restore-token <nome>` | Restaura token específico para uso |

### 📋 Comandos Originais (Mantidos)

| Comando | Descrição |
|---------|-----------|
| `aws-list` | Lista todos os perfis disponíveis |
| `aws-switch <perfil>` | Troca para um perfil específico |
| `aws-login <perfil>` | Faz login SSO em um perfil |
| `aws-who` | Mostra qual perfil está ativo |
| `aws-logout` | Faz logout de todos os perfis |
| `aws-discover-org` | Descobre automaticamente contas da organização |
| `aws-help` | **NOVO!** Manual completo de comandos |

## 💫 Experiência de Uso

### 1. **Interface Principal**
```bash
aws-menu
```
![TUI Menu](https://via.placeholder.com/600x400/1a1a2e/fff?text=AWS+SSO+Manager+TUI)

### 2. **Seleção Interativa de Perfis**
```bash
aws-choose
```
- ✅ **Preview de status** em tempo real
- 🔍 **Busca fuzzy** por nome
- ⌨️ **Navegação com setas**
- 📋 **Detalhes do perfil** no painel lateral

### 3. **Troca Rápida**
```bash
aws-quick
```
- ⚡ **Seleção direta** com fuzzy finder
- 🚀 **Mais rápido** para usuários avançados

## 🔐 Como Funciona a Criptografia

### Automática e Transparente
1. **Interceptação**: Monitora criação de novos tokens
2. **Criptografia**: Automaticamente criptografa com AES-256-CBC
3. **Restauração**: Descriptografa transparentemente quando necessário
4. **Limpeza**: Remove tokens não criptografados do cache

### Estrutura de Arquivos
```
~/.aws-sso-secure/
├── master.key           # Chave mestre (600 permissions)
├── <token1>.json.enc    # Token criptografado
├── <token2>.json.enc    # Token criptografado
└── ...
```

### Comandos Manuais
```bash
# Proteger tokens existentes
aws-secure-tokens

# Ver tokens protegidos
aws-list-secure-tokens

# Restaurar token específico (raramente necessário)
aws-restore-token a1b2c3d4e5f6.json
```

## 🎨 Personalização da TUI

### Cores e Tema
A TUI usa um esquema de cores moderno compatível com terminais modernos:
- **Catppuccin-inspired** color scheme
- **Bordas e separadores** elegantes
- **Status icons** informativos (✅❌⚡🔒)

### Atalhos de Teclado
- `↑↓` ou `Ctrl+K/J`: Navegação
- `Enter`: Selecionar
- `Tab`: Toggle preview
- `Ctrl+C`: Cancelar
- `?`: Ajuda (em algumas interfaces)

## 📊 Comparação com Ferramentas Similares

| Recurso | AWS SSO Manager | aws-sso-creds | synfinatic/aws-sso-cli |
|---------|-----------------|---------------|------------------------|
| **Interface TUI** | ✅ Completa | ❌ | ❌ |
| **Fuzzy Finder** | ✅ fzf | ❌ | ❌ |
| **Criptografia** | ✅ AES-256 | ❌ | ✅ Keyring |
| **Auto-discovery** | ✅ Organizations | ❌ | ✅ |
| **Preview Status** | ✅ Tempo real | ❌ | ❌ |
| **Bash Integration** | ✅ Nativo | ✅ | ❌ |

## 🔧 Dependências

### Automaticamente Instaladas
- **fzf**: Fuzzy finder para seleção interativa
- **openssl**: Criptografia AES-256

### Pré-requisitos
- ✅ **AWS CLI v2** 
- ✅ **Bash** (Linux/macOS/WSL)
- ✅ **Python 3** (para descoberta de organizações)

## 🚀 Workflow Recomendado

### Configuração Inicial (Uma vez)
```bash
# 1. Instalar o enhanced
./install-enhanced.sh

# 2. Recarregar terminal
source ~/.bashrc

# 3. Descobrir contas da organização
aws-discover-org

# 4. Proteger tokens existentes
aws-secure-tokens
```

### Uso Diário
```bash
# Opção 1: Menu interativo (recomendado)
aws-menu

# Opção 2: Seleção rápida
aws-choose

# Opção 3: Troca ultra-rápida
aws-quick

# Opção 4: Comandos tradicionais
aws-switch meu-perfil
```

## 🛡️ Segurança e Privacidade

### O que é Criptografado
- ✅ **Tokens de acesso** SSO
- ✅ **Tokens de refresh**
- ✅ **Metadados de sessão**

### O que NÃO é Criptografado
- ❌ **Configuração de perfis** (`~/.aws/config`)
- ❌ **Configurações do AWS CLI**
- ❌ **Logs do sistema**

### Chave Mestre
- 🔐 **256-bit** gerada com OpenSSL
- 📁 **Stored** em `~/.aws-sso-secure/master.key`
- 🔒 **Permissions** 600 (somente owner)
- 🔄 **Regenerável** (re-criptografa todos os tokens)

## 🐛 Troubleshooting Enhanced

### fzf não encontrado
```bash
# Ubuntu/Debian
sudo apt install fzf

# CentOS/RHEL
sudo yum install fzf

# macOS
brew install fzf

# Arch Linux
sudo pacman -S fzf
```

### Erro de criptografia
```bash
# Verifica se OpenSSL está disponível
openssl version

# Re-gera chave mestre se necessário
rm ~/.aws-sso-secure/master.key
aws-secure-tokens
```

### Interface TUI com problemas
```bash
# Verifica compatibilidade do terminal
echo $TERM

# Testa fzf diretamente
echo -e "item1\nitem2\nitem3" | fzf
```

### Migração de versão anterior
```bash
# Backup de configurações existentes
cp ~/.bashrc ~/.bashrc.backup

# Re-instalar
./install-enhanced.sh

# Testar funcionalidades
aws-help
```

## 📈 Roadmap Futuro

### Versão 3.0 (Planejado)
- 🔍 **Integração com AWS CloudFormation** stacks
- 📊 **Dashboard de uso** de recursos
- 🔔 **Notificações** de expiração de credenciais
- 🌐 **Interface web** opcional
- 📱 **Exportação** de configurações

### Contribuições
- 🤝 **Pull requests** bem-vindos
- 🐛 **Issues** para bugs e sugestões
- 📖 **Documentação** sempre pode melhorar

## 📞 Suporte Enhanced

### Canais de Suporte
- 🐛 **GitHub Issues**: Para bugs e feature requests
- 📖 **Documentação**: Este README + comentários no código
- ⭐ **GitHub Stars**: Mostra que o projeto é útil!

### Informações de Debug
```bash
# Versões de dependências
aws --version
fzf --version
openssl version
bash --version

# Status do projeto
aws-help
aws-list-secure-tokens
```

## 👨‍💻 Autor Enhanced

**Luan Messias** - [@luan1408](https://github.com/luan1408)

📧 **Contato**: luan.1408lg@gmail.com
🌟 **GitHub**: https://github.com/luan1408/aws-sso-manager

---

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

## 🙏 Agradecimentos

- **AWS CLI Team** - Pela ferramenta fundamental
- **fzf creators** - Pelo fuzzy finder incrível
- **Community** - Por feedback e contribuições

---

⚡ **Enhanced by**: Criptografia + TUI interativa + Fuzzy finder  
🚀 **Performance**: Otimizado para uso diário  
🔐 **Security**: Tokens protegidos automaticamente  
🎯 **UX**: Interface moderna e intuitiva  

**Gostou?** ⭐ Dê uma estrela no repositório!