#!/bin/bash

# Solicita o nome do bucket ao usuário
echo -n "Digite o nome do bucket que deseja deletar: "
read BUCKET_NAME

# Verifica se o usuário não deixou o nome em branco
if [ -z "$BUCKET_NAME" ]; then
    echo "Erro: O nome do bucket não pode ser vazio."
    exit 1
fi

echo "Verificando o bucket: $BUCKET_NAME..."

# Verifica se o bucket realmente existe na AWS
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Bucket encontrado! Iniciando processo de remoção..."
    
    # 1. Esvazia o bucket (deleta todos os objetos recursivamente)
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
    # Exibe o aviso caso o bucket não exista ou o nome esteja errado
    echo "Aviso: O bucket '$BUCKET_NAME' não foi encontrado na sua conta AWS."
fi
