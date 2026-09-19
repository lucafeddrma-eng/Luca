#!/bin/bash

# Kleuren voor terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PAYMENTER_DIR="/var/www/paymenter"
RAW_CSS_URL="https://raw.githubusercontent.com/lucafeddrma-eng/Luca/main/theme.css"

echo -e "${GREEN}==> Starten van de CraftNode theme installatie...${NC}"

# 1. Controleer of Paymenter aanwezig is
if [ ! -d "$PAYMENTER_DIR" ]; then
    echo -e "${RED}Fout: Paymenter map niet gevonden op $PAYMENTER_DIR!${NC}"
    exit 1
fi

cd $PAYMENTER_DIR || exit

# 2. Download CSS van de repository
echo -e "${GREEN}==> Theme CSS downloaden van GitHub...${NC}"
curl -s -o public/craftnode.css $RAW_CSS_URL

if [ $? -ne 0 ]; then
    echo -e "${RED}Fout tijdens het downloaden van theme.css.${NC}"
    exit 1
fi

LAYOUT_FILE="resources/views/layouts/app.blade.php"

# 3. Voeg de CSS toe aan de head van de layout
if [ -f "$LAYOUT_FILE" ]; then
    if ! grep -q "craftnode.css" "$LAYOUT_FILE"; then
        echo -e "${GREEN}==> CSS koppelen in app.blade.php...${NC}"
        sed -i '/<\/head>/i \    <link rel="stylesheet" href="{{ asset('\''craftnode.css'\'') }}">' "$LAYOUT_FILE"
    fi

    # 4. Voeg de Floating Discount Banner toe voor </body>
    if ! grep -q "promo-banner" "$LAYOUT_FILE"; then
        echo -e "${GREEN}==> Floating discount banner toevoegen...${NC}"
        BANNER_HTML='<div class="discount-banner" id="promo-banner"><div class="flex items-center space-x-3"><span class="text-2xl">🎁<\/span><div><div class="text-[#ff6b2b] text-xs font-bold uppercase">Welcome discount<\/div><div class="text-white text-sm font-semibold">Use code <span class="text-[#ff6b2b]">CRAFT10<\/span><\/div><\/div><\/div><div class="flex items-center space-x-2"><button onclick="navigator.clipboard.writeText('\''CRAFT10'\'')" class="btn-copy">Copy<\/button><button onclick="document.getElementById('\''promo-banner'\'').style.display='\''none'\''" class="text-gray-400 hover:text-white px-1">✕<\/button><\/div><\/div>'
        sed -i "/<\/body>/i \\    $BANNER_HTML" "$LAYOUT_FILE"
    fi
else
    echo -e "${RED}Let op: $LAYOUT_FILE niet gevonden.${NC}"
fi

# 5. Eigendomsrechten instellen en cache opschonen
echo -e "${GREEN}==> Rechten herstellen en cache wissen...${NC}"
chown -R www-data:www-data $PAYMENTER_DIR/public/craftnode.css
php artisan view:clear
php artisan cache:clear

echo -e "${GREEN}==> Thema succesvol geïnstalleerd!${NC}"
