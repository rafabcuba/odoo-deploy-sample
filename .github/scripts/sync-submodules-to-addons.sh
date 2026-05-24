#!/bin/bash
# Sincroniza submódulos del repositorio a la carpeta addons local
# Uso: ./sync-submodules-to-addons.sh

set -e

REPO_URL="git@github.com:rafabcuba/deploy-test.git"
BRANCH="release"
ADDONS_TARGET="/home/rbg/odoo/deploy-test/addons"
TEMP_DIR="/tmp/odoo-sync-$$"

echo "🔁 Sincronizando submódulos Odoo desde $BRANCH"

# Clonar repositorio con submódulos
git clone --recurse-submodules --branch $BRANCH --depth 1 $REPO_URL $TEMP_DIR

# Crear target si no existe
mkdir -p $ADDONS_TARGET

# Obtener submódulos
cd $TEMP_DIR
SUBMODULES=$(git config --file .gitmodules --name-only --get-regexp path | cut -d '.' -f2-)

for SUBMODULE in $SUBMODULES; do
    TARGET_PATH="$ADDONS_TARGET/$(basename $SUBMODULE)"
    
    # Backup
    if [ -d "$TARGET_PATH" ]; then
        mv "$TARGET_PATH" "$TARGET_PATH.backup.$(date +%s)"
    fi
    
    # Copiar
    rsync -av --exclude='.git' "$SUBMODULE/" "$TARGET_PATH/"
    echo "✅ Sincronizado: $(basename $SUBMODULE)"
done

# Limpiar
rm -rf $TEMP_DIR
echo "🎉 Sincronización completa"