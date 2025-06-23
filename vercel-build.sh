#!/bin/bash
# Este script instrui a Vercel a como instalar e compilar um projeto Flutter.

# Para a execução se ocorrer um erro
set -e

# Corrige o problema "fatal: bad object" que pode ocorrer no ambiente da Vercel
git config --global fetch.fsckObjects false

# Clona o SDK do Flutter na versão estável para uma pasta temporária
echo "Clonando o SDK do Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 --branch stable /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

# Executa o flutter doctor para verificar a instalação
flutter doctor

# Baixa as dependências do projeto
echo "Baixando as dependências do projeto..."
flutter pub get

# Compila a versão web do projeto em modo 'release' para otimização
echo "Compilando a aplicação web..."
flutter build web --release

echo "Build finalizado com sucesso!"
