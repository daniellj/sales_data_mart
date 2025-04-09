import os
import re

env_files = [".env.dev", ".env.hom", ".env.prod", ".env.development", ".env.homologation", ".env.production"]

for file in env_files:
    if os.path.exists(file):
        with open(file, "r", encoding="utf-8") as f:
            lines = f.readlines()

        cleaned_lines = []
        modified = False

        for line in lines:
            new_line = re.sub(r"^(DBT_CH_PASSWORD)\s*=\s*.*", r"\1=", line)
            if new_line != line:
                modified = True
            cleaned_lines.append(new_line)

        if modified:
            with open(file, "w", encoding="utf-8") as f:
                f.writelines(cleaned_lines)
            print(f"Cleaned: {file}")
