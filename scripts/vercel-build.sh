#!/usr/bin/env bash

set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.4}"
FLUTTER_ROOT="${HOME}/flutter"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"

if [ ! -x "${FLUTTER_ROOT}/bin/flutter" ]; then
  echo "Installing Flutter ${FLUTTER_VERSION} for Vercel build..."
  rm -rf "${FLUTTER_ROOT}"
  curl -L "${FLUTTER_URL}" -o "/tmp/${FLUTTER_ARCHIVE}"
  tar -xf "/tmp/${FLUTTER_ARCHIVE}" -C "${HOME}"
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"

cd bookshelfly_app
flutter config --enable-web
flutter pub get
flutter build web --release
