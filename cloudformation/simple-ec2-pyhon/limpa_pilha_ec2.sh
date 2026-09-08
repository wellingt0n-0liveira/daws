#!/bin/bash

STACK_NAME="simple-ec2-python"
KEY_NAME="default"
KEY_FILE="default.pem"

echo "🛑 Iniciando destruição completa da infraestrutura..."

# 1. Deletar a Stack do CloudFormation (Desliga e apaga a EC2, discos e redes)
echo "🔄 Removendo a Stack '$STACK_NAME' do CloudFormation (isso pode levar alguns minutos)..."
aws cloudformation delete-stack --stack-name "$STACK_NAME"

echo "⏳ Aguardando a remoção completa dos recursos da AWS..."
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
echo "✅ EC2, discos e Security Groups foram completamente destruídos!"

# 2. Apagar o par de chaves (Key Pair) da AWS
echo "🔄 Removendo o Key Pair '$KEY_NAME' da AWS..."
aws ec2 delete-key-pair --key-name "$KEY_NAME"
echo "✅ Chave removida do painel AWS."

# 3. Apagar o arquivo .pem local do seu computador
if [ -f "$KEY_FILE" ]; then
    echo "🔄 Removendo o arquivo de chave local '$KEY_FILE'..."
    rm -f "$KEY_FILE"
    echo "✅ Arquivo privado deletado do seu computador."
else
    echo "⚠️ Arquivo '$KEY_FILE' não encontrado localmente, pulando..."
fi

echo "🎉 Limpeza concluída com sucesso! Nenhum recurso foi deixado para trás."

