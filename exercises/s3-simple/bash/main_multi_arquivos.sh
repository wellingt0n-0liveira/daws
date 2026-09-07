#!/bin/bash

# Garante que pelo menos UM arquivo foi passado como argumento
if [ $# -eq 0 ]; then
	echo "Usage: $0 <file1> <file2> <file3> ..."
	exit 1
fi

# Generate a bucket name
BUCKET_NAME="daws-s3-simple-$(date +%y%m%d)"

# Check if the bucket already exists, create if not.
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
	echo "Creating bucket: $BUCKET_NAME"
	aws s3api create-bucket --bucket "$BUCKET_NAME"
else
	echo "Bucket already exists: $BUCKET_NAME"
fi

# 1. Habilita as ACLs no bucket
aws s3api put-bucket-ownership-controls \
    --bucket "$BUCKET_NAME" \
    --ownership-controls "Rules=[{ObjectOwnership=BucketOwnerPreferred}]"

# 2. Desativa o Bloqueio de Acesso Público
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

echo "----------------------------------------"
echo "Iniciando o upload dos arquivos..."
echo "----------------------------------------"

# Loop para processar cada arquivo passado como argumento ($@ representa todos eles)
for FILE in "$@"; do
    # Verifica se o arquivo realmente existe localmente antes de tentar o upload
    if [ ! -f "$FILE" ]; then
        echo "❌ Erro: O arquivo '$FILE' não existe localmente. Pulando..."
        echo "----------------------------------------"
        continue
    fi

    echo "Subindo: $FILE..."
    aws s3 cp "$FILE" "s3://$BUCKET_NAME/" --acl public-read

    if [ $? -eq 0 ]; then
        FILE_NAME=$(basename "$FILE")
        PUBLIC_URL="https://$BUCKET_://amazonaws.com"
        echo "✅ Sucesso!"
        echo "🔗 URL Pública: $PUBLIC_URL"
    else
        echo "❌ Falha ao subir o arquivo '$FILE'"
    fi
    echo "----------------------------------------"
done
