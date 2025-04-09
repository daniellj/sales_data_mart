@echo off
setlocal enabledelayedexpansion

REM Lê o ambiente do .env.activate
for /f "delims=" %%A in ('findstr "^DBT_ACTIVE_ENV=" .env.activate') do (
    set "ENV_LINE=%%A"
)
for /f "tokens=2 delims==" %%B in ("!ENV_LINE!") do (
    set "ENVIRONMENT=%%B"
)

if "%ENVIRONMENT%"=="" (
    echo [ERRO] Variável DBT_ACTIVE_ENV não encontrada ou vazia em .env.activate
    exit /b 1
)

echo Ambiente ativo: %ENVIRONMENT%

REM Carrega o nome da venv do .env.<ambiente>
for /f "delims=" %%V in ('findstr "^VENV_NAME=" .env.%ENVIRONMENT%') do (
    set "VENV_LINE=%%V"
)
for /f "tokens=2 delims==" %%W in ("!VENV_LINE!") do (
    set "VENV_NAME=%%W"
)

REM Caminho do venv e dbt
set "VENV_PATH=%~dp0%VENV_NAME%"
set "DBT_EXE=%VENV_PATH%\Scripts\dbt.exe"
set "DBT_MAIN_DIR=%~dp0dbt_main"
set "DBT_SEEDS_DIR=%~dp0dbt_seeds"

REM Ativa o ambiente virtual
echo Ativando o virtual environment: "%VENV_PATH%\Scripts\activate.bat"
call "%VENV_PATH%\Scripts\activate.bat"

REM Carrega todas as variáveis do .env.<ambiente> manualmente
for /f "usebackq tokens=1,2 delims==" %%A in (".env.%ENVIRONMENT%") do (
    set "%%A=%%B"
)

echo -----------------------------------------------------------
REM Executa dbt clean
echo Running: %DBT_EXE% clean --project-dir %DBT_MAIN_DIR% --profiles-dir %DBT_MAIN_DIR%
"%DBT_EXE%" clean --project-dir "%DBT_MAIN_DIR%" --profiles-dir "%DBT_MAIN_DIR%"
echo -----------------------------------------------------------
REM Executa dbt deps
echo Running: %DBT_EXE% deps --project-dir %DBT_MAIN_DIR% --profiles-dir %DBT_MAIN_DIR%
"%DBT_EXE%" deps --project-dir "%DBT_MAIN_DIR%" --profiles-dir "%DBT_MAIN_DIR%"
echo -----------------------------------------------------------
REM Executa dbt debug com ambiente já carregado
echo Executando: %DBT_EXE% debug --profiles-dir %DBT_MAIN_DIR% --project-dir %DBT_MAIN_DIR%
"%DBT_EXE%" debug --profiles-dir "%DBT_MAIN_DIR%" --project-dir "%DBT_MAIN_DIR%"
echo -----------------------------------------------------------
REM Executa dbt ls com ambiente já carregado
echo Executando: %DBT_EXE% ls --select countries --output name --profiles-dir %DBT_MAIN_DIR% --project-dir %DBT_MAIN_DIR%
"%DBT_EXE%" ls --select countries --output name --profiles-dir "%DBT_MAIN_DIR%" --project-dir "%DBT_MAIN_DIR%"
echo -----------------------------------------------------------