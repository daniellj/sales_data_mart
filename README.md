# DBT Project with Multi-Environment Support

This DBT project is structured to support multiple environments (`development`, `homologation`, and `production`) in a secure, modular, and automated way, including pre-commit hooks, environment control via `.env` files, and script-based execution with automatic virtual environment activation.

## 🚀 Folder Structure

```bash
dbt_dw/
├── sales_data_mart/           # Main DBT project directory
│   ├── dbt/                   # DBT folder
│   ├── dbt/analyses
│   ├── dbt/logs
│   ├── dbt/macros
│   ├── dbt/models
│   ├── dbt/seeds
│   ├── dbt/snapshots
│   ├── dbt/target
│   ├── dbt/tests
│   ├── dbt/dbt_project.yml    # DBT configuration file
│   └── dbt/profiles.yml       # Profile file with dynamic targets
│
├── scripts/                   # Auxiliary scripts
│   └── clean_env_passwords.py  # Removes .env passwords before commits
│
├── .env.activate              # Defines the active environment (e.g., development)
├── .env.development           # Environment variables for development
├── .env.homologation          # Environment variables for homologation
├── .env.production            # Environment variables for production
│
├── run_env_debug.bat          # Executes DBT Debug on Windows
├── run_env_debug.sh           # Executes DBT Debug on Linux/macOS
│
├── requirements.txt           # Project's Python dependencies
└── .pre-commit-config.yaml    # Git hook to remove passwords before commits
```

## 📦 Dependencies
Python 3.13.1 or higher

## ⚙️ Installation
1. Prerequisites (for Windows)
Install the Visual Studio C++ Build Tools:
👉 https://visualstudio.microsoft.com/visual-cpp-build-tools/

Update PowerShell execution policy:
```
Set-ExecutionPolicy RemoteSigned
```

2. Clone and configure the project
```
git clone --branch main https://github.com/daniellj/sales_data_mart.git
cd sales_data_mart
```

3. Create the virtual environment

3.1. Windows
```
python -m venv venv
.\venv\Scripts\Activate.ps1
```

3.2. Linux/macOS
```
python -m venv venv
source venv/bin/activate
```

4. Install dependencies
```
python -m pip install --upgrade pip
pip install -r requirements.txt
pre-commit install
```

✅ Pre-commit: automatic security
This project includes a pre-commit hook that automatically removes passwords from .env files before every commit.

📄 .pre-commit-config.yaml
```
repos:
  - repo: local
    hooks:
      - id: clear-env-passwords
        name: Remove DBT passwords from .envs
        entry: python scripts/clean_env_passwords.py
        language: system
        files: ^\.env\.(dev|hom|prod|development|homologation|production)$
```

## 🌎 Environments and variables
Each environment has its own .env file with specific variables:

📄 .env.development
```
VENV_NAME=venv
DBT_CH_ENV=development
DBT_CH_SCHEMA=dw_rep
DBT_CH_HOST=127.0.0.1
DBT_CH_PORT=8126
DBT_CH_USER=admin
DBT_CH_PASSWORD=
```

📄 .env.homologation and .env.production follow the same structure as .env.development, with DBT_CH_ENV adapted accordingly.

## 🧠 Activating the current environment
The active environment is defined in:
📄 .env.activate
```
DBT_ACTIVE_ENV=development
```

## 🛠️ Run with debug (project validation)
This step performs:
- Variable loading
- Automatic virtualenv activation
- Validation of profiles.yml, dbt_project.yml, Git, and database connection

▶️ Windows
```
.\run_env_debug.bat
```

▶️ Linux/macOS
```
./run_env_debug.sh
```

✅ What is validated by dbt debug
Presence and correctness of:
- dbt_project.yml
- profiles.yml
- Git installation
- Database connection
- Environment detection (development, homologation, production)
- Secure execution: password is read from .env, never hardcoded
