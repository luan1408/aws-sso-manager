# AWS SSO Manager

[![Author](https://img.shields.io/badge/Author-luan1408-blue?style=flat-square)](https://github.com/luan1408)

🚀 Gerenciador inteligente para perfis AWS SSO que simplifica a troca entre diferentes ambientes AWS.

## 📋 Requisitos

Antes de instalar, certifique-se de ter:

- ✅ **AWS CLI v2** instalado ([guia de instalação](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- ✅ **Bash** (Linux/macOS ou WSL no Windows)
- ✅ **Permissões** para modificar arquivos de configuração (`~/.bashrc`)
- ✅ **Conta AWS com SSO** configurada

### Verificando os Requisitos

```bash
# Verificar versão do AWS CLI
aws --version

# Deve retornar algo como: aws-cli/2.x.x
```

## 🔧 Instalação Rápida

### Opção 1: Instalação Automática
```bash
curl -sSL https://raw.githubusercontent.com/luan1408/aws-sso-manager/main/install.sh | bash
```

### Opção 2: Instalação Manual
```bash
# 1. Clone o repositório
git clone https://github.com/luan1408/aws-sso-manager.git
cd aws-sso-manager

# 2. Execute o instalador
./install.sh
```

### Opção 3: Instalação Passo a Passo
```bash
# 1. Copie as funções para seu .bashrc
cat functions.sh >> ~/.bashrc

# 2. Recarregue o terminal
source ~/.bashrc

# 3. Copie os scripts auxiliares (opcional)
cp add-profile.sh ~/bin/  # ou outro diretório no seu PATH
cp switch-profile.sh ~/bin/
chmod +x ~/bin/*.sh
```

## 🎯 Como Usar

### Comandos Principais

| Comando | Descrição |
|---------|-----------|
| `aws-list` | Lista todos os perfis disponíveis |
| `aws-switch <perfil>` | Troca para um perfil específico |
| `aws-login <perfil>` | Faz login SSO em um perfil |
| `aws-who` | Mostra qual perfil está ativo |
| `aws-logout` | Faz logout de todos os perfis |
| `aws-discover-org` | 🆕 Descobre automaticamente todas as contas da organização e configura perfis SSO |

### Exemplos de Uso

```bash
# Descobrir e configurar automaticamente todas as contas da organização
aws-discover-org

# Listar perfis disponíveis
aws-list

# Trocar para ambiente de desenvolvimento
aws-switch empresa-dev

# Fazer login SSO
aws-login empresa-prod

# Verificar qual conta está ativa
aws-who

# Atalhos rápidos (configuráveis)
aws-dev     # Troca para empresa-dev
aws-prod    # Troca para empresa-prod
```

### Adicionar Novo Perfil

#### Descoberta Automática de Contas da Organização 🆕

```bash
# Descobre automaticamente todas as contas da sua organização AWS
aws-discover-org

# O comando irá:
# 1. Listar todas as contas ativas da organização
# 2. Para cada conta, perguntar se você quer criar um perfil
# 3. Sugerir nomes de perfil baseados no nome da conta
# 4. Configurar automaticamente os perfis SSO
```

**Pré-requisitos para usar `aws-discover-org`:**
- Estar logado em uma conta que faz parte da organização AWS
- Ter permissões para `organizations:ListAccounts`
- Python 3 instalado (geralmente já vem no sistema)

#### Método Manual Individual

```bash
# Método interativo
./add-profile.sh

# Ou manualmente no ~/.aws/config
[profile meu-perfil]
sso_start_url = https://empresa.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = AdministratorAccess
region = us-east-1
output = json
```

## 📁 Estrutura do Projeto

```
aws-sso-manager/
├── README.md           # Documentação principal
├── install.sh          # Script de instalação automática
├── functions.sh        # Funções principais (para ~/.bashrc)
├── add-profile.sh      # Script para adicionar perfis
└── switch-profile.sh   # Script standalone para troca
```

## 🔄 Fluxo de Trabalho Típico

1. **Setup inicial (organizações AWS):**
   ```bash
   aws-discover-org         # Descobre e configura todas as contas automaticamente
   ```

2. **Primeira vez:**
   ```bash
   aws-login empresa-dev    # Login inicial
   ```

3. **Trabalho diário:**
   ```bash
   aws-switch empresa-dev   # Troca rápida entre perfis
   aws-switch empresa-prod
   ```

4. **Verificação:**
   ```bash
   aws-who                  # Confirma qual ambiente está ativo
   ```

## ⚡ Funcionalidades

- 🔍 **Validação automática** de credenciais
- 🔄 **Troca inteligente** entre perfis
- 📋 **Listagem visual** com perfil atual destacado
- 🚀 **Atalhos personalizáveis** para perfis frequentes
- 🧹 **Limpeza automática** de variáveis de ambiente conflitantes
- ⚠️ **Avisos úteis** quando credenciais expiram
- 🏢 **Descoberta automática** de contas da organização AWS
- 🤖 **Configuração automática** de perfis SSO para todas as contas

## 🛠️ Personalização

### Adicionar Atalhos Próprios
Edite o final do arquivo `functions.sh`:

```bash
# Seus atalhos personalizados
alias aws-staging='aws-switch empresa-staging'
alias aws-sandbox='aws-switch empresa-sandbox'
```

### Configurar Perfis Padrão
Modifique as variáveis no início das funções conforme sua organização.

## 🐛 Solução de Problemas

### Erro: "Perfil não encontrado"
```bash
# Verifique se o perfil existe
aws configure list-profiles

# Adicione o perfil se necessário
./add-profile.sh
```

### Erro: "Credenciais inválidas"
```bash
# Refaça o login SSO
aws-login <seu-perfil>
```

### Comandos não reconhecidos
```bash
# Recarregue o .bashrc
source ~/.bashrc

# Ou reinicie o terminal
```

### Erro: "Não foi possível acessar AWS Organizations"
```bash
# Certifique-se de ter as permissões necessárias
# A conta deve ter permissão: organizations:ListAccounts

# Verifique se está na conta master/management da organização
aws-who

# Certifique-se de que está usando uma conta da organização (não conta standalone)
```


## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Add nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 👨‍💻 Autor

**Luan Messias** - [@luan1408](https://github.com/luan1408)

📧 Contato: luan.1408lg@gmail.com

Se este projeto te ajudou, considere dar uma ⭐!

## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

- 📖 **Documentação AWS CLI**: https://docs.aws.amazon.com/cli/
- 🔗 **AWS SSO Setup**: https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html
- 🐛 **Issues**: Abra uma issue neste repositório para reportar bugs ou sugerir melhorias

---

⭐ **Gostou do projeto?** Dê uma estrela no repositório para apoiar o desenvolvimento!