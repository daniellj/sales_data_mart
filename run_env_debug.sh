#!/bin/bash
set -e
set -a

# Caminho base do projeto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Caminho do arquivo .env.activate
ACTIVATE_FILE="$PROJECT_DIR/.env.activate"

# Verifica se o arquivo .env.activate existe
if [ ! -f "$ACTIVATE_FILE" ]; then
  echo "[ERRO] Arquivo .env.activate não encontrado."
  exit 1
fi

# Lê a variável DBT_ACTIVE_ENV
source "$ACTIVATE_FILE"

if [ -z "$DBT_ACTIVE_ENV" ]; then
  echo "[ERRO] Variável DBT_ACTIVE_ENV não definida em .env.activate"
  exit 1
fi

echo "Ambiente ativo: $DBT_ACTIVE_ENV"

# Caminho do arquivo .env.<ambiente>
ENV_FILE="$PROJECT_DIR/.env.$DBT_ACTIVE_ENV"

if [ ! -f "$ENV_FILE" ]; then
  echo "[ERRO] Arquivo $ENV_FILE não encontrado."
  exit 1
fi

# Lê o .env.<ambiente> para capturar VENV_NAME
VENV_NAME=$(grep "^VENV_NAME=" "$ENV_FILE" | cut -d '=' -f2)

if [ -z "$VENV_NAME" ]; then
  echo "[ERRO] VENV_NAME não definido em $ENV_FILE"
  exit 1
fi

VENV_PATH="$PROJECT_DIR/$VENV_NAME"
DBT_EXE="$VENV_PATH/bin/dbt"
DBT_DIR="$PROJECT_DIR/dbt"

# Ativa o ambiente virtual
if [ -f "$VENV_PATH/bin/activate" ]; then
  echo "Ativando o virtual environment: $VENV_PATH"
  source "$VENV_PATH/bin/activate"
else
  echo "[ERRO] Ambiente virtual não encontrado em $VENV_PATH"
  exit 1
fi

# Carrega todas as variáveis do .env.<ambiente>
source "$ENV_FILE"

# Executa dbt debug com ambiente ativado
echo "Executando: $DBT_EXE debug --profiles-dir $DBT_DIR --project-dir $DBT_DIR"
"$DBT_EXE" debug --profiles-dir "$DBT_DIR" --project-dir "$DBT_DIR"
