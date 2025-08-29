# AWS SSO Manager 🚀

[![Author](https://img.shields.io/badge/Author-luan1408-blue?style=flat-square)](https://github.com/luan1408)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Bash](https://img.shields.io/badge/Shell-Bash-brightgreen?style=flat-square)
![AWS](https://img.shields.io/badge/AWS-SSO-orange?style=flat-square)

**Gerenciador visual e intuitivo para perfis AWS SSO com interface TUI moderna e persistência automática.**

## 🎯 O que é?

AWS SSO Manager é uma ferramenta de linha de comando que simplifica drasticamente o gerenciamento de múltiplos perfis AWS SSO. Com uma interface visual elegante e navegação intuitiva, permite trocar entre contas AWS de forma rápida e persistente.

## ✨ Principais Recursos

### 🎨 **Interface Visual Moderna**
- Menu TUI com bordas elegantes e emojis
- Seleção visual de perfis com números
- Feedback claro de status e operações
- Navegação completamente através de menus

### 🔄 **Gerenciamento Inteligente de Perfis**
- **Persistência automática** - perfil selecionado mantém-se entre sessões
- **Seleção flexível** - aceita números (1, 2, 3) ou nomes completos
- **Lista visual** - perfis organizados e destacados
- **Indicação clara** do perfil ativo atual

### 🔐 **Login SSO Otimizado**
- **Instruções claras** para ambientes WSL/Linux
- **Detecção automática** de problemas de navegador
- **URLs e códigos** claramente exibidos
- **Dicas específicas** para cada ambiente

### 🌍 **Acesso Global**
- **Comando global** - funciona de qualquer diretório
- **Instalação única** - configure uma vez, use sempre
- **Zero dependências** - apenas bash e AWS CLI

## 🚀 Instalação

### Método 1: Instalação Global (Recomendado)

```bash
# Clone o repositório
git clone https://github.com/luan1408/aws-sso-manager.git
cd aws-sso-manager

# Instale globalmente
./install-global.sh
```

### Método 2: Uso Direto

```bash
# Clone e use imediatamente
git clone https://github.com/luan1408/aws-sso-manager.git
cd aws-sso-manager
./aws-simple.sh
```

## 💻 Como Usar

### Interface Interativa (Principal)

```bash
# Abre o menu visual elegante
aws-manager
```

**Opções disponíveis:**
- **1** → Listar todos os perfis
- **2** → Seletor visual de perfis (com números)
- **3** → Login SSO (aceita números ou nomes)
- **4** → Ver status e credenciais atuais
- **5** → Sair

### Comandos Diretos

```bash
# Lista perfis rapidamente
aws-manager list

# Troca perfil por nome
aws-manager switch empresa-prod

# Troca perfil por posição (se disponível via interface)
aws-manager switch 2
```

### Exemplo de Fluxo Completo

```bash
# 1. Abre interface
aws-manager

# 2. Escolhe opção 2 (Seletor visual)
# 3. Digita: 3  (para o terceiro perfil)
# 4. ✅ Perfil alterado e persistido

# 5. Verifica em novo terminal
aws-manager list
# ➤ empresa-dev (perfil atual)
```

## 🔧 Pré-requisitos

- **Bash** (Linux, macOS, WSL)
- **AWS CLI v2** instalado e configurado
- **Perfis AWS SSO** já configurados no `~/.aws/config`

## 📊 Comparação com Outras Soluções

| Recurso | AWS SSO Manager | AWS CLI Nativo | aws-vault | granted |
|---------|----------------|----------------|-----------|---------|
| **Interface Visual** | ✅ TUI Moderna | ❌ Apenas CLI | ❌ CLI | ✅ TUI |
| **Seleção por Número** | ✅ Sim | ❌ Não | ❌ Não | ❌ Não |
| **Persistência Automática** | ✅ Sim | ❌ Não | ✅ Sim | ✅ Sim |
| **Zero Configuração** | ✅ Sim | ❌ Complexo | ❌ Configuração | ❌ Setup |
| **Comando Global** | ✅ Sim | ✅ Sim | ✅ Sim | ✅ Sim |
| **Suporte WSL** | ✅ Otimizado | ⚠️ Limitado | ⚠️ Limitado | ⚠️ Limitado |
| **Dependências** | ✅ Apenas Bash | ✅ Nenhuma | ❌ Go | ❌ Rust |
| **Tamanho** | ✅ ~300 linhas | - | ❌ >50MB | ❌ >20MB |

## 🎯 Diferenciais Únicos

### 🚀 **Simplicidade Extrema**
- **Um único arquivo** - toda funcionalidade em `aws-simple.sh`
- **Instalação instantânea** - sem compilação ou dependências
- **Interface intuitiva** - qualquer pessoa consegue usar

### 🎨 **Experiência Visual Superior**
- **Menus com bordas** elegantes usando caracteres Unicode
- **Emojis informativos** para cada ação
- **Cores e destaque** do perfil atual
- **Feedback visual** claro de todas operações

### ⚡ **Performance e Leveza**
- **Startup instantâneo** - sem overhead de linguagens compiladas
- **Memória mínima** - apenas shell nativo
- **Responsivo** - interface reativa e fluida

### 🔄 **Persistência Inteligente**
- **Estado global** mantido entre terminais
- **Compatibilidade total** com ferramentas AWS existentes
- **Sincronização automática** com `AWS_PROFILE`

### 🌍 **Otimização WSL**
- **Instruções específicas** para ambientes Windows/Linux
- **Detecção automática** de problemas de navegador
- **Comandos auxiliares** para abertura de URLs

### 🛠️ **Flexibilidade de Uso**
- **Seleção múltipla** - números OU nomes de perfis
- **Comandos diretos** para automação
- **Menu interativo** para uso manual
- **Compatível** com scripts existentes

## 📋 Casos de Uso

### 👨‍💻 **Desenvolvedores**
```bash
# Troca rápida entre ambientes
aws-manager  # Escolhe "dev" → trabalha → "prod" → deploy
```

### 🏢 **DevOps/SRE**
```bash
# Gestão de múltiplas contas
aws-manager  # Cliente A → Client B → Infraestrutura → Monitoramento
```

### 🔧 **Automação**
```bash
# Em pipelines/scripts
aws-manager switch prod-deployment
terraform apply
aws-manager switch monitoring
kubectl get pods
```

## 🤝 Contribuição

Contribuições são bem-vindas! Este projeto foca em **simplicidade máxima**:

### Diretrizes
- ✅ Mantenha tudo em um arquivo
- ✅ Zero dependências além do bash
- ✅ Interface visual consistente
- ❌ Não adicione complexidade desnecessária

### Como Contribuir
```bash
# Fork → Clone → Modificações → Pull Request
git clone https://github.com/SEU-USER/aws-sso-manager.git
cd aws-sso-manager
# Faça suas modificações em aws-simple.sh
# Teste localmente: ./aws-simple.sh
# Crie PR com descrição clara
```

## 📞 Suporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/luan1408/aws-sso-manager/issues)
- 📧 **Email**: luan.1408lg@gmail.com
- ⭐ **Star**: Mostre que gostou dando uma estrela!

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Luan Messias** - [@luan1408](https://github.com/luan1408)

---

## 🎉 Comece Agora!

```bash
git clone https://github.com/luan1408/aws-sso-manager.git
cd aws-sso-manager
./install-global.sh
aws-manager
```

**🚀 Interface elegante, zero configuração, máxima produtividade!**