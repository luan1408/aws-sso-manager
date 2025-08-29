#!/bin/bash

# Funções de criptografia para tokens AWS SSO
# Autor: AWS SSO Manager Enhanced

# Configurações
AWS_SSO_SECURE_DIR="$HOME/.aws-sso-secure"
AWS_SSO_CACHE_DIR="$HOME/.aws/sso/cache"
AWS_SSO_KEY_FILE="$AWS_SSO_SECURE_DIR/master.key"

# Cria diretório seguro se não existir
_ensure_secure_dir() {
    if [ ! -d "$AWS_SSO_SECURE_DIR" ]; then
        mkdir -p "$AWS_SSO_SECURE_DIR"
        chmod 700 "$AWS_SSO_SECURE_DIR"
    fi
}

# Gera ou obtém chave mestre
_get_master_key() {
    _ensure_secure_dir
    
    if [ ! -f "$AWS_SSO_KEY_FILE" ]; then
        echo "🔐 Gerando chave mestre para criptografia..."
        # Gera chave de 256 bits
        openssl rand -base64 32 > "$AWS_SSO_KEY_FILE"
        chmod 600 "$AWS_SSO_KEY_FILE"
        echo "✅ Chave mestre criada"
    fi
    
    cat "$AWS_SSO_KEY_FILE"
}

# Criptografa arquivo
aws-encrypt-token() {
    local input_file="$1"
    local output_file="$2"
    
    if [ ! -f "$input_file" ]; then
        echo "❌ Arquivo não encontrado: $input_file"
        return 1
    fi
    
    local key
    key=$(_get_master_key)
    
    # Criptografa com AES-256-CBC
    openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file" -pass pass:"$key" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "🔒 Token criptografado: $(basename "$output_file")"
        return 0
    else
        echo "❌ Erro na criptografia"
        return 1
    fi
}

# Descriptografa arquivo
aws-decrypt-token() {
    local input_file="$1"
    local output_file="$2"
    
    if [ ! -f "$input_file" ]; then
        echo "❌ Arquivo criptografado não encontrado: $input_file"
        return 1
    fi
    
    local key
    key=$(_get_master_key)
    
    # Descriptografa
    openssl enc -d -aes-256-cbc -in "$input_file" -out "$output_file" -pass pass:"$key" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        return 0
    else
        echo "❌ Erro na descriptografia"
        return 1
    fi
}

# Move tokens para armazenamento seguro
aws-secure-tokens() {
    echo "🔐 Protegendo tokens SSO existentes..."
    
    if [ ! -d "$AWS_SSO_CACHE_DIR" ]; then
        echo "📁 Diretório de cache SSO não encontrado"
        return 0
    fi
    
    _ensure_secure_dir
    local count=0
    
    # Criptografa todos os arquivos JSON do cache
    for token_file in "$AWS_SSO_CACHE_DIR"/*.json; do
        if [ -f "$token_file" ]; then
            local filename
            filename=$(basename "$token_file")
            local secure_file="$AWS_SSO_SECURE_DIR/$filename.enc"
            
            if aws-encrypt-token "$token_file" "$secure_file"; then
                # Remove token original após criptografar
                rm "$token_file"
                count=$((count + 1))
            fi
        fi
    done
    
    echo "✅ $count tokens protegidos com criptografia"
}

# Restaura token específico quando necessário
aws-restore-token() {
    local token_name="$1"
    
    if [ -z "$token_name" ]; then
        echo "Uso: aws-restore-token <nome-do-arquivo>"
        return 1
    fi
    
    local encrypted_file="$AWS_SSO_SECURE_DIR/$token_name.enc"
    local output_file="$AWS_SSO_CACHE_DIR/$token_name"
    
    if [ ! -f "$encrypted_file" ]; then
        # Token não estava criptografado, verificar se existe normal
        if [ -f "$output_file" ]; then
            echo "📁 Token já disponível: $token_name"
            return 0
        else
            echo "❌ Token não encontrado: $token_name"
            return 1
        fi
    fi
    
    # Cria diretório de cache se necessário
    mkdir -p "$AWS_SSO_CACHE_DIR"
    
    if aws-decrypt-token "$encrypted_file" "$output_file"; then
        echo "🔓 Token restaurado: $token_name"
        return 0
    else
        return 1
    fi
}

# Lista tokens criptografados
aws-list-secure-tokens() {
    echo "🔐 Tokens criptografados:"
    echo "─────────────────────────"
    
    if [ ! -d "$AWS_SSO_SECURE_DIR" ]; then
        echo "Nenhum token criptografado encontrado"
        return 0
    fi
    
    local count=0
    for encrypted_file in "$AWS_SSO_SECURE_DIR"/*.enc; do
        if [ -f "$encrypted_file" ]; then
            local filename
            filename=$(basename "$encrypted_file" .enc)
            echo "🔒 $filename"
            count=$((count + 1))
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo "Nenhum token criptografado encontrado"
    else
        echo "─────────────────────────"
        echo "Total: $count tokens protegidos"
    fi
}

# Hook automático para interceptar comandos AWS SSO
_aws_sso_secure_hook() {
    # Intercepta comandos que podem precisar de tokens
    if [[ "$1" == "sso" && "$2" == "login" ]] || [[ "$1" == "sts" && "$2" == "get-caller-identity" ]]; then
        # Restaura tokens necessários antes do comando
        local profile="${AWS_PROFILE:-default}"
        
        # Procura por arquivos de token que podem ser necessários
        for encrypted_file in "$AWS_SSO_SECURE_DIR"/*.enc; do
            if [ -f "$encrypted_file" ]; then
                local token_name
                token_name=$(basename "$encrypted_file" .enc)
                
                # Se o token não existe no cache, restaura
                if [ ! -f "$AWS_SSO_CACHE_DIR/$token_name" ]; then
                    aws-restore-token "$token_name" >/dev/null 2>&1
                fi
            fi
        done
    fi
}

# Substitui comando aws para interceptar automaticamente
aws() {
    # Executa hook de segurança
    _aws_sso_secure_hook "$@"
    
    # Executa comando AWS original
    command aws "$@"
    
    # Após comando SSO login, criptografa novos tokens
    if [[ "$1" == "sso" && "$2" == "login" ]] && [ $? -eq 0 ]; then
        # Aguarda 1 segundo para garantir que os arquivos foram escritos
        sleep 1
        aws-secure-tokens >/dev/null 2>&1
    fi
}

echo "🔐 Funções de criptografia AWS SSO carregadas"
echo "📋 Comandos disponíveis:"
echo "   aws-secure-tokens     - Protege tokens existentes"
echo "   aws-list-secure-tokens - Lista tokens criptografados"
echo "   aws-restore-token     - Restaura token específico"