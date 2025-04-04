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
    echo [ERRO] DBT_ACTIVE_ENV not defined in .env.activate
    exit /b 1
)

echo Active environment: %ENVIRONMENT%

REM Lê o nome da venv
for /f "delims=" %%V in ('findstr "^VENV_NAME=" .env.%ENVIRONMENT%') do (
    set "VENV_LINE=%%V"
)
for /f "tokens=2 delims==" %%W in ("!VENV_LINE!") do (
    set "VENV_NAME=%%W"
)

REM Caminho da venv e pasta do projeto
set "VENV_PATH=%~dp0%VENV_NAME%"
set "DBT_EXE=%VENV_PATH%\Scripts\dbt.exe"
set "DBT_DIR=%~dp0dbt"

REM Ativa a venv
call "%VENV_PATH%\Scripts\activate.bat"

REM Carrega todas as variáveis do .env.<ambiente>
for /f "usebackq tokens=1,2 delims==" %%A in (".env.%ENVIRONMENT%") do (
    set "%%A=%%B"
)

for /f "usebackq tokens=* delims=" %%L in (".env.%ENVIRONMENT%") do (
    set "LINE=%%L"
    echo !LINE! | findstr "=" >nul
    if !errorlevel! == 0 (
        for /f "tokens=1,2 delims==" %%A in ("!LINE!") do (
            set "%%A=%%B"
        )
    )
)

REM Executa dbt seed
echo Running seed: %DBT_EXE% seed --project-dir %DBT_DIR% --profiles-dir %DBT_DIR%
"%DBT_EXE%" seed --project-dir "%DBT_DIR%" --profiles-dir "%DBT_DIR%"
