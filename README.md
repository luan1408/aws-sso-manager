# AWS SSO Manager 🚀

[![Author](https://img.shields.io/badge/Author-luan1408-blue?style=flat-square)](https://github.com/luan1408)
![Simple](https://img.shields.io/badge/Simple-Ultra%20Clean-green?style=flat-square)
![Status](https://img.shields.io/badge/Status-Ready-brightgreen?style=flat-square)

🎯 **Versão ultra-simplificada** do AWS SSO Manager - **zero configuração, zero problemas**!

## ✨ Por que esta versão?

**❌ Problema das versões anteriores:**
- Muitos scripts confusos
- Problemas de carregamento de funções
- Instalação complexa
- Conflitos entre versões

**✅ Solução desta versão:**
- **1 único arquivo** (`aws-simple.sh`)
- **Funciona imediatamente**
- **Zero configuração**
- **Persistência garantida**

## 🚀 Instalação Ultra-Simples

```bash
# 1. Clone o repositório
git clone https://github.com/luan1408/aws-sso-manager.git
cd aws-sso-manager

# 2. Use imediatamente (não precisa instalar nada!)
./aws-simple.sh
```

**Pronto! Não há passo 3.** 🎉

## 🎯 Como Usar

### Menu Interativo (Recomendado)
```bash
./aws-simple.sh
```

Abre menu com opções:
1. **Listar perfis** - Veja todos os perfis disponíveis
2. **Trocar perfil** - Selecione outro perfil  
3. **Login SSO** - Faça login em um perfil
4. **Ver status** - Mostra perfil atual e credenciais
5. **Sair** - Fecha o menu

### Comandos Diretos (Para Scripts)
```bash
# Lista perfis rapidamente
./aws-simple.sh list

# Troca perfil diretamente  
./aws-simple.sh switch empresa-prod

# Mostra ajuda
./aws-simple.sh help
```

## 🔄 Persistência Automática

### ✅ O Problema Original foi RESOLVIDO!

**Antes:** Você trocava de conta, mas ela não persistia entre sessões.

**Agora:** 
```bash
./aws-simple.sh switch empresa-prod   # Troca para empresa-prod
./aws-simple.sh list                  # ✅ Mostra "empresa-prod (atual)"

# Em outro terminal:
./aws-simple.sh list                  # ✅ AINDA mostra "empresa-prod (atual)"
```

### Como funciona a persistência?

1. **Troca de perfil** → Salva automaticamente em `~/.aws/current_profile`
2. **Comando list** → Lê o arquivo e mostra perfil correto
3. **Novos terminais** → Mantêm o último perfil selecionado

## 📋 Exemplos Práticos

### Cenário 1: Uso Diário
```bash
# Abre menu interativo
./aws-simple.sh

# Escolhe opção 2 (Trocar perfil)
# Digita: empresa-dev
# ✅ Perfil alterado e persistido!
```

### Cenário 2: Automação/Scripts
```bash
# Em um script bash
./aws-simple.sh switch empresa-prod
aws s3 ls  # Usa o perfil empresa-prod automaticamente
```

### Cenário 3: Verificação Rápida
```bash
# Vê rapidamente todos os perfis
./aws-simple.sh list

# Resultado:
# 📋 Perfis AWS:
# ─────────────────────────────────
#   default
#   empresa-dev
# ➤ empresa-prod (atual)
#   empresa-sandbox  
# ─────────────────────────────────
```

## 🎨 Interface Limpa

### Menu Principal
```
🚀 AWS SSO Manager

Perfil atual: empresa-prod

1) Listar perfis
2) Trocar perfil
3) Login SSO
4) Ver status
5) Sair

Opção [1-5]: _
```

### Lista de Perfis
```
📋 Perfis AWS:
─────────────────────────────────
  default
  empresa-dev
➤ empresa-prod (atual)
  empresa-sandbox
─────────────────────────────────
```

## 🛡️ Sem Dependências Complexas

**✅ O que você NÃO precisa:**
- ❌ fzf, jq, ou outras ferramentas
- ❌ Configuração do bashrc
- ❌ Scripts de instalação 
- ❌ Permissões especiais

**✅ O que você PRECISA:**
- ✅ AWS CLI configurado
- ✅ Bash (já tem no Linux/macOS/WSL)

## 🔧 Estrutura Super Simples

### Arquivos do Projeto
```
aws-sso-manager/
├── aws-simple.sh    # ← Tudo em 1 arquivo!
├── README.md        # ← Esta documentação
└── LICENSE          # ← Licença MIT
```

### Dados do Usuário
```
~/.aws/
├── config           # Seus perfis AWS (não alterado)
├── credentials      # Credenciais (se houver)  
└── current_profile  # 🆕 Perfil persistido (criado automaticamente)
```

## 🐛 Troubleshooting

### Perfil não persiste?
```bash
# Verifica se arquivo foi criado
ls -la ~/.aws/current_profile

# Deve mostrar o perfil atual
cat ~/.aws/current_profile
```

### AWS CLI não encontrado?
```bash
# Verifica se AWS CLI está instalado
aws --version

# Se não estiver, instale:
# Ubuntu: sudo apt install awscli
# macOS: brew install awscli  
# Windows: https://aws.amazon.com/cli/
```

### Script não executa?
```bash
# Verifica permissões
ls -la aws-simple.sh

# Se necessário, adiciona permissão de execução:
chmod +x aws-simple.sh
```

## 📊 Comparação com Outras Versões

| Recurso | Versão Simples | Versões Anteriores |
|---------|---------------|-------------------|
| **Arquivos** | 1 arquivo | 15+ arquivos |
| **Instalação** | Zero configuração | Scripts complexos |
| **Problemas** | Zero | Múltiplos |
| **Dependências** | Nenhuma | fzf, openssl, etc. |
| **Persistência** | ✅ Funciona | ❌ Problemas |
| **Manutenção** | ✅ Simples | ❌ Complexa |

## 🎯 Casos de Uso

### Para Desenvolvedores
```bash
# Troca rápida entre ambientes
./aws-simple.sh switch dev-account
kubectl get pods  # Conecta no cluster de dev

./aws-simple.sh switch prod-account  
kubectl get pods  # Conecta no cluster de prod
```

### Para DevOps
```bash
# Em pipelines CI/CD
./aws-simple.sh switch deployment-account
terraform apply
```

### Para Administradores
```bash
# Gestão de múltiplas contas AWS
./aws-simple.sh              # Menu interativo
# Escolhe conta → faz operações → troca para próxima conta
```

## 🚀 Atualizações Futuras

Para atualizar para versões futuras:

```bash
# Atualiza o repositório
git pull origin main

# Pronto! O aws-simple.sh é atualizado automaticamente
```

**Não há scripts de instalação para quebrar!** 🎉

## 🤝 Contribuição

Este projeto foca na **simplicidade máxima**. Contribuições são bem-vindas, mas devem seguir o princípio:

> **"Se adicionar complexidade, não será aceito"**

### Como contribuir:
1. 🐛 **Bugs**: Reporte problemas via GitHub Issues
2. 💡 **Ideias**: Sugira melhorias que mantenham a simplicidade  
3. 🔧 **PRs**: Envie pull requests com melhorias simples

## 📞 Suporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/luan1408/aws-sso-manager/issues)
- 📧 **Email**: luan.1408lg@gmail.com
- ⭐ **Stars**: Mostre que gostou dando uma estrela!

## 👨‍💻 Autor

**Luan Messias** - [@luan1408](https://github.com/luan1408)

🌟 **GitHub**: https://github.com/luan1408/aws-sso-manager

---

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

## 🎉 Resultado Final

### ✅ **Antes desta versão:**
- ❌ 15+ arquivos confusos
- ❌ Problemas de instalação  
- ❌ Dependências complexas
- ❌ Persistência não funcionava

### ✅ **Com esta versão:**
- ✅ **1 arquivo simples**
- ✅ **Zero configuração** 
- ✅ **Funciona imediatamente**
- ✅ **Persistência garantida**

### 🚀 **Para usar agora:**
```bash
git clone https://github.com/luan1408/aws-sso-manager.git
cd aws-sso-manager
./aws-simple.sh
```

**Simples assim!** 🎯

---

⚡ **Ultra-simplificado**: 1 arquivo, zero problemas  
🎯 **Ultra-funcional**: Persistência, menu, comandos diretos  
🛡️ **Ultra-confiável**: Sem dependências ou conflitos  

**Gostou da simplicidade?** ⭐ **Dê uma estrela no repositório!**