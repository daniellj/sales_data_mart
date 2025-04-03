import os
import re
import sys
sys.stdout.reconfigure(encoding='utf-8')

env_files = [".env.dev", ".env.hom", ".env.prod", ".env.development", ".env.homologation", ".env.production"]

for file in env_files:
    if os.path.exists(file):
        with open(file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        with open(file, "w", encoding="utf-8") as f:
            for line in lines:
                line = re.sub(r"^(DBT_CH_PASSWORD)=.*", r"\1=", line)
                f.write(line)
        print(f"Cleaned: {file}")
