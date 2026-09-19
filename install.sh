#!/bin/bash

# Kleuren voor terminal uitvoer
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PAYMENTER_DIR="/var/www/paymenter"
RAW_CSS_URL="https://raw.githubusercontent.com/JOUW_GITHUB_GEBRUIKERSNAAM/paymenter-craftnode-theme/main/theme.css"

echo -e "${GREEN}==> Starten van de CraftNode theme installatie...${NC}"

# Check of Paymenter directory bestaat
if [ ! -d "$PAYMENTER_DIR" ]; then
    echo -e "${RED}Fout: Paymenter map niet gevonden op $PAYMENTER_DIR!${NC}"
    exit 1
fi

cd $PAYMENTER_DIR

# Downloaden van de custom CSS
echo -e "${GREEN}==> CSS bestand downloaden van GitHub...${NC}"
curl -s -o public/craftnode.css $RAW_CSS_URL

if [ $? -ne 0 ]; then
    echo -e "${RED}Fout tijdens het downloaden van de CSS.${NC}"
    exit 1
fi

# Controleren of de link al in app.blade.php staat, zo niet toevoegen
LAYOUT_FILE="resources/views/layouts/app.blade.php"

if [ -f "$LAYOUT_FILE" ]; then
    if ! grep -q "craftnode.css" "$LAYOUT_FILE"; then
        echo -e "${GREEN}==> Thema toevoegen aan app.blade.php layout...${NC}"
        sed -i '/<\/head>/i \    <link rel="stylesheet" href="{{ asset('\''craftnode.css'\'') }}">' "$LAYOUT_FILE"
    else
        echo -e "${GREEN}==> Thema link stond al in de layout.${NC}"
    fi
else
    echo -e "${RED}Let op: $LAYOUT_FILE niet gevonden. Voeg handmatig '<link rel="stylesheet" href="{{ asset('\''craftnode.css'\'') }}">' toe aan je head tag.${NC}"
fi

# Rechten herstellen
echo -e "${GREEN}==> Rechten van bestanden instellen...${NC}"
chown -R www-data:www-data $PAYMENTER_DIR/public/craftnode.css

# Laravel cache leegmaken
echo -e "${GREEN}==> Paymenter cache opschonen...${NC}"
php artisan view:clear
php artisan cache:clear

echo -e "${GREEN}==> Installatie voltooid! Ververs je browser met Ctrl+F5.${NC}"
