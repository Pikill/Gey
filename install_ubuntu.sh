#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y \
  curl ca-certificates gnupg git unzip rsync \
  xvfb xauth dbus-x11 \
  libnss3 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdrm2 libxkbcommon0 \
  libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2t64 \
  libpangocairo-1.0-0 libpango-1.0-0 libcairo2 libgtk-3-0 libxshmfence1 \
  fonts-liberation fonts-noto-color-emoji

if ! command -v node >/dev/null 2>&1 || [ "$(node -v | sed 's/v//' | cut -d. -f1)" -lt 20 ]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

npm install
node scripts/setup_profiles.mjs

echo "AWS Ubuntu setup complete."
echo "Hidden mode: npm start"
echo "Interactive visible/VNC mode: npm run local"
echo "Quest browser mode: npm run quest"
