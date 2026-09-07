#!/bin/bash

# Define o nome do bucket baseado na data atual (padrão do seu projeto)
BUCKET_NAME="daws-s3-simple-$(date +%y%m%d)"

echo "Iniciando a remoção do bucket: $BUCKET_NAME"

# Verifica se o bucket realmente existe antes de tentar deletar
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    
    # 1. Esvazia o bucket (deleta todos os objetos e marcadores de exclusão)
    echo "Esvaziando objetos do bucket..."
    aws s3 rm "s3://$BUCKET_NAME" --recursive

    # 2. Remove o bucket permanentemente
    echo "Removendo o bucket da AWS..."
    aws s3api delete-bucket --bucket "$BUCKET_NAME"
    
    if [ $? -eq 0 ]; then
        echo "Sucesso! O bucket '$BUCKET_NAME' foi deletado permanentemente."
    else
        echo "Erro ao tentar deletar o bucket."
        exit 1
    fi
else
    echo "Aviso: O bucket '$BUCKET_NAME' não foi encontrado ou você não tem permissão de acesso."
fi
