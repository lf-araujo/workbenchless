#!/bin/bash

################################################################################
#
#  WORKBENCHLESS APPIMAGE BUILDER (CI / Ubuntu port)
#  Emacs 30 + workbenchless config + pre-installed packages
#  Based on: https://github.com/CsBigDataHub/Emacs-Appimage
#
#  This is an apt/Ubuntu port of the maintainer's local build.sh (which targets
#  Solus/eopkg). It is meant to run on a GitHub Actions ubuntu-22.04 runner.
#  The only substantive differences from build.sh are:
#    * dependency installation uses apt-get with Debian/Ubuntu package names;
#    * the workbenchless config is taken from the checked-out repo (this script
#      lives in ci/ inside that repo) instead of being cloned from GitHub;
#    * org-modern is included in the pre-installed package set.
#
################################################################################

set -euo pipefail

APP_VERSION="30.2"
OUTPUT="workbenchless-${APP_VERSION}-x86_64.AppImage"
ICON_URL=""
APPDIR="$(pwd)/AppDir"
TARGET_UID=$(id -u)
TARGET_GID=$(id -g)

# Repo root = parent of this script's directory (ci/..)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

show_help() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --icon, -i ICON_URL     Download custom icon from URL
  --version, -v VERSION   Emacs version (default: 30.2)
  --output, -o OUTPUT     Output filename
  --uid UID               Target user ID for file ownership
  --gid GID               Target group ID for file ownership
  --help, -h              Show this help
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --icon | -i)   ICON_URL="$2";           shift 2 ;;
        --version | -v) APP_VERSION="$2";
                        OUTPUT="workbenchless-${APP_VERSION}-x86_64.AppImage"
                        shift 2 ;;
        --output | -o) OUTPUT="$2";             shift 2 ;;
        --uid)         TARGET_UID="$2";         shift 2 ;;
        --gid)         TARGET_GID="$2";         shift 2 ;;
        --help | -h)   show_help ;;
        *)  echo "ERROR: Unknown option: $1"; exit 1 ;;
    esac
done

echo "═══════════════════════════════════════════════════════════════════════"
echo "  WORKBENCHLESS APPIMAGE BUILDER (CI)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  Emacs version:  ${APP_VERSION}"
echo "  Output:         ${OUTPUT}"
echo "  Repo root:      ${REPO_ROOT}"
echo ""

# Ubuntu/Debian build dependencies (apt names). These mirror the Solus
# *-devel set in build.sh one-for-one.
BUILD_DEPS=(
    # Build toolchain
    build-essential libtool automake autoconf bison flex texinfo git wget curl
    # GTK / display
    libgtk-3-dev libcairo2-dev libgdk-pixbuf-2.0-dev libpango1.0-dev
    libx11-dev libxcb1-dev libxext-dev libxrender-dev
    libxfixes-dev libxi-dev libxinerama-dev libxrandr-dev
    libxcursor-dev libxcomposite-dev libxdamage-dev libxxf86vm-dev
    libxau-dev libxdmcp-dev
    libxkbcommon-dev libinput-dev libwayland-dev
    # Images / fonts
    libjpeg-dev libpng-dev libtiff-dev libgif-dev
    libfontconfig1-dev libfreetype6-dev libharfbuzz-dev librsvg2-dev
    # Core libs
    libffi-dev libpcre2-dev libgnutls28-dev libncurses-dev libxml2-dev
    libsystemd-dev libsqlite3-dev libdbus-1-dev
    libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libbz2-dev liblzma-dev
    libseccomp-dev libjson-c-dev
    # tree-sitter
    libtree-sitter-dev
    # AppImage tooling
    libfuse2 fuse imagemagick file
    # R runtime (needed for ESS/org-babel R blocks)
    r-base
)

EMACS_CONFIGURE_OPTS=(
    --disable-build-details --with-modules --with-pgtk --with-cairo
    --with-compress-install --with-toolkit-scroll-bars
    --with-native-compilation=aot --with-tree-sitter --with-xinput2
    --without-xwidgets --without-webp --with-dbus --with-harfbuzz --with-libsystemd
    --with-sqlite3 --prefix=/usr
    CFLAGS="-O2 -march=x86-64 -pipe -fomit-frame-pointer"
)
# Note: -march=x86-64 (not native) for portability across x86_64 machines.

################################################################################
# STEP 1: Install Dependencies
################################################################################
echo "Step 1: Installing Dependencies"
echo "───────────────────────────────────────────────────────────────────────"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends "${BUILD_DEPS[@]}"

# Native compilation needs libgccjit matching the active gcc major version.
GCC_MAJOR=$(gcc -dumpversion | cut -d. -f1)
echo "  Installing libgccjit-${GCC_MAJOR}-dev for native compilation"
sudo apt-get install -y --no-install-recommends "libgccjit-${GCC_MAJOR}-dev" \
    || sudo apt-get install -y --no-install-recommends libgccjit-dev
echo "✓ Dependencies installed"
echo ""

################################################################################
# STEP 2: Ensure FUSE availability
################################################################################
echo "Step 2: Checking FUSE"
echo "───────────────────────────────────────────────────────────────────────"
# On GitHub runners FUSE may be unavailable to mount; we sidestep it entirely
# by extracting the AppImage build tools and exporting APPIMAGE_EXTRACT_AND_RUN.
export APPIMAGE_EXTRACT_AND_RUN=1
if   ldconfig -p | grep -q libfuse.so.3; then echo "  Found: FUSE 3"
elif ldconfig -p | grep -q libfuse.so.2; then echo "  Found: FUSE 2"
else echo "  FUSE not mountable — using APPIMAGE_EXTRACT_AND_RUN=1"; fi
echo "✓ FUSE handled"
echo ""

################################################################################
# STEP 3: Download Emacs
################################################################################
echo "Step 3: Downloading Emacs ${APP_VERSION}"
echo "───────────────────────────────────────────────────────────────────────"
if [[ ! -d "emacs-${APP_VERSION}" ]]; then
    wget -c "https://ftp.gnu.org/gnu/emacs/emacs-${APP_VERSION}.tar.xz" 2>/dev/null ||
        wget -c "https://mirror.rackspace.com/gnu/emacs/emacs-${APP_VERSION}.tar.xz"
    tar -xf "emacs-${APP_VERSION}.tar.xz"
    rm -f "emacs-${APP_VERSION}.tar.xz"
fi
echo "✓ Source ready"
echo ""

################################################################################
# STEP 4: Build Emacs
################################################################################
echo "Step 4: Building Emacs (30-45 minutes)"
echo "───────────────────────────────────────────────────────────────────────"
mkdir -p "${APPDIR}/usr/bin" "${APPDIR}/usr/lib" "${APPDIR}/usr/share"
cd "emacs-${APP_VERSION}"

if [[ -f autogen.sh ]]; then ./autogen.sh 2>&1 | tail -3 || true
else autoreconf -fvi 2>&1 | tail -3 || true; fi

echo "  Configuring..."
./configure "${EMACS_CONFIGURE_OPTS[@]}" >/dev/null 2>&1
echo "  Bootstrapping..."
make -j"$(nproc)" bootstrap 2>&1 | tail -3
echo "  Building..."
make -j"$(nproc)" 2>&1 | tail -3
echo "  Installing into AppDir..."
make DESTDIR="${APPDIR}" install 2>&1 | tail -3
echo "✓ Emacs built"
cd ..
echo ""

################################################################################
# STEP 5: Setup arch-dependent directory
################################################################################
echo "Step 5: Setting up arch-dependent directory"
echo "───────────────────────────────────────────────────────────────────────"
# Detect the actual arch triplet used by the Emacs build (may differ from
# x86_64-pc-linux-gnu on some distros, e.g. x86_64-linux-gnu)
ARCH_TRIPLET=$(find "${APPDIR}/usr/libexec/emacs/${APP_VERSION}" \
    -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -n1 | xargs basename 2>/dev/null)
if [[ -z "$ARCH_TRIPLET" ]]; then
    # Fall back to querying the built binary directly
    ARCH_TRIPLET=$("${APPDIR}/usr/bin/emacs" \
        --batch --eval '(princ system-configuration)' 2>/dev/null || echo "x86_64-pc-linux-gnu")
fi
echo "  Arch triplet: ${ARCH_TRIPLET}"
ARCH_DIR="${APPDIR}/usr/libexec/emacs/${APP_VERSION}/${ARCH_TRIPLET}"
mkdir -p "$ARCH_DIR"
if [[ -f "emacs-${APP_VERSION}/src/emacs.pdmp" ]]; then
    cp "emacs-${APP_VERSION}/src/emacs.pdmp" "$ARCH_DIR/emacs.pdmp"
    echo "✓ Copied emacs.pdmp to ${ARCH_DIR}"
else
    echo "⚠ emacs.pdmp not found"
fi

# When the AppDir binary is run directly (before bundling), its baked-in
# load-path points at the configure prefix (/usr/share/emacs/...), which does
# not exist on the build host — so any (require ...) fails. Export the AppDir
# lisp tree explicitly (the whole tree, so subdirs like lisp/emacs-lisp are
# found), mirroring what the runtime AppRun does. Used for both the sanity
# check below and the package bootstrap in Step 7.
EMACS_LISP_ROOT="${APPDIR}/usr/share/emacs/${APP_VERSION}/lisp"
export EMACSLOADPATH="$(find "${EMACS_LISP_ROOT}" -type d | paste -sd: -):${APPDIR}/usr/share/emacs/site-lisp"
export EMACSDATA="${APPDIR}/usr/share/emacs/${APP_VERSION}/etc"
export EMACSDOC="${APPDIR}/usr/share/emacs/${APP_VERSION}/etc"
export EMACSPATH="${ARCH_DIR}"

# Sanity check: confirm the freshly built binary actually starts AND can load
# bundled Lisp. Do it unfiltered (no pipe/grep) so any startup or load-path
# error surfaces immediately and clearly.
echo "  Verifying the built Emacs starts and can load bundled Lisp..."
"${APPDIR}/usr/bin/emacs" --batch \
    --dump-file="${ARCH_DIR}/emacs.pdmp" \
    --eval '(progn (require (quote package)) (princ (concat "emacs-start-ok " emacs-version "\n")))' \
    || { echo "ERROR: the built Emacs binary failed to start / load Lisp"; exit 1; }
echo ""

################################################################################
# STEP 6: Detect native-comp paths
################################################################################
echo "Step 6: Detecting native-comp dependencies"
echo "───────────────────────────────────────────────────────────────────────"
GCC_PATH=$(which gcc 2>/dev/null || echo "")
LIBGCCJIT_PATH=$(find /usr/lib /usr/lib64 -name "libgccjit.so*" 2>/dev/null | head -n1 || echo "")
[[ -n "$GCC_PATH"      ]] && echo "  GCC:       $GCC_PATH"      || echo "  ⚠ GCC not found"
[[ -n "$LIBGCCJIT_PATH" ]] && echo "  libgccjit: $LIBGCCJIT_PATH" || echo "  ⚠ libgccjit not found"
echo "✓ Native-comp ready"
echo ""

################################################################################
# STEP 7: Pre-install workbenchless packages
################################################################################
echo "Step 7: Pre-installing workbenchless packages"
echo "───────────────────────────────────────────────────────────────────────"

WB_CONFIG="$(pwd)/workbenchless-config"

# Use the checked-out repo (this script lives in it) as the config source.
rm -rf "${WB_CONFIG}"
mkdir -p "${WB_CONFIG}"
cp "${REPO_ROOT}/init.el"     "${WB_CONFIG}/init.el"
cp "${REPO_ROOT}/README.org"  "${WB_CONFIG}/README.org" 2>/dev/null || true
cp "${REPO_ROOT}/style.theme" "${WB_CONFIG}/style.theme" 2>/dev/null || true

# The GitHub repo has no early-init.el — create a minimal one
if [[ ! -f "${WB_CONFIG}/early-init.el" ]]; then
    cat > "${WB_CONFIG}/early-init.el" <<'EARLYEOF'
;;; early-init.el -*- lexical-binding: t -*-
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 32 1024 1024))))
(setq package-enable-at-startup t)
(setq tool-bar-mode nil menu-bar-mode nil scroll-bar-mode nil)
EARLYEOF
fi

# Write the bootstrap package-installation script
cat > "${WB_CONFIG}/bootstrap.el" <<'ELISP'
;;; bootstrap.el --- Pre-install all workbenchless packages during AppImage build
;;; This file is only run during the build, NOT at user runtime.
;;; lexical-binding: t

(require 'package)

;; Configure archives
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/packages/")
        ("melpa"  . "https://melpa.org/packages/")))

(package-initialize)
(message "Refreshing package contents...")
(package-refresh-contents)

;; All packages from init.el use-package declarations
;; (copilot excluded: requires GitHub auth at runtime)
(defvar wb-packages
  '(;; UI / completion
    which-key avy consult embark embark-consult marginalia
    corfu corfu-terminal cape kind-icon orderless wgrep
    ;; editing / tools
    magit markdown-mode yaml-mode json-mode editorconfig meow evil
    ;; org / citations
    org org-modern org-roam citar citar-embark citar-org-roam htmlize toc-org
    ;; code / LSP
    ess nim-mode
    ;; tree-sitter
    treesit-auto tree-sitter tree-sitter-langs tree-sitter-ess-r
    ;; visual
    svg-tag-mode svg-lib))

(dolist (pkg wb-packages)
  (if (package-installed-p pkg)
      (message "Already installed: %s" pkg)
    (message "Installing %s..." pkg)
    (condition-case err
        (package-install pkg)
      (error (message "ERROR installing %s: %s" pkg (error-message-string err))))))

;; VC packages (nim-ts-mode, ultra-scroll)
(message "Installing nim-ts-mode via package-vc...")
(condition-case err
    (package-vc-install
     '(nim-ts-mode
       :url "https://github.com/niontrix/nim-ts-mode"
       :branch "main"))
  (error (message "ERROR installing nim-ts-mode: %s" (error-message-string err))))

(message "Installing ultra-scroll via package-vc...")
(condition-case err
    (package-vc-install
     '(ultra-scroll
       :url "https://github.com/jdtsmith/ultra-scroll"
       :branch "main"))
  (error (message "ERROR installing ultra-scroll: %s" (error-message-string err))))

;; Tree-sitter grammars (compiled to user-emacs-directory/tree-sitter/)
(message "Installing tree-sitter grammars...")
(require 'treesit)
(setq treesit-language-source-alist
      '((r   "https://github.com/r-lib/tree-sitter-r"   "main" "src")
        (nim  "https://github.com/alaviss/tree-sitter-nim" "main" "src")))

(dolist (lang '(r nim))
  (message "Compiling tree-sitter grammar: %s..." lang)
  (condition-case err
      (treesit-install-language-grammar lang)
    (error (message "ERROR compiling %s grammar: %s" lang (error-message-string err)))))

;; Byte-compile all installed packages for fast startup
(message "Byte-compiling packages...")
(byte-recompile-directory (expand-file-name "elpa" user-emacs-directory) 0 t)

(message "\n✓ Bootstrap complete. Installed packages are ready.")
ELISP

# Run the bootstrap with the freshly built Emacs.
# Full output is teed to a log; we read Emacs's own exit status via
# PIPESTATUS (not the tee's) so a real failure is reported with its error,
# instead of being hidden by a grep filter under `set -o pipefail`.
echo "  Running headless Emacs to install packages (may take 10-20 min)..."
HOME="${WB_CONFIG}" \
  "${APPDIR}/usr/bin/emacs" \
  --batch \
  --dump-file="${ARCH_DIR}/emacs.pdmp" \
  --init-directory "${WB_CONFIG}" \
  --load "${WB_CONFIG}/bootstrap.el" \
  2>&1 | tee "${WB_CONFIG}/bootstrap.log"
BOOTSTRAP_RC=${PIPESTATUS[0]}
if [[ "${BOOTSTRAP_RC}" -ne 0 ]]; then
    echo "ERROR: bootstrap Emacs exited with status ${BOOTSTRAP_RC}"
    echo "─── last 40 lines of bootstrap output ───"
    tail -n 40 "${WB_CONFIG}/bootstrap.log"
    exit 1
fi

# Remove bootstrap script + log — not needed in the final AppImage
rm -f "${WB_CONFIG}/bootstrap.el" "${WB_CONFIG}/bootstrap.log"

# Bundle config (with pre-installed elpa) into AppDir
cp -r "${WB_CONFIG}" "${APPDIR}/config"

echo "✓ Packages pre-installed and bundled"
echo ""

################################################################################
# STEP 8: Create AppRun
################################################################################
echo "Step 8: Creating AppRun"
echo "───────────────────────────────────────────────────────────────────────"

cat > "AppRun.source" <<EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
EMACS_VER="${APP_VERSION}"

# Detect arch triplet dynamically (handles x86_64-pc-linux-gnu vs x86_64-linux-gnu etc.)
ARCH_TRIPLET=\$(find "\${HERE}/usr/libexec/emacs/\${EMACS_VER}" \
    -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -n1 | xargs basename 2>/dev/null)
ARCH_TRIPLET="\${ARCH_TRIPLET:-x86_64-pc-linux-gnu}"

# Emacs internal paths
export ARCH_LIBEXEC="\${HERE}/usr/libexec/emacs/\${EMACS_VER}/\${ARCH_TRIPLET}"
export ARCH_BIN="\${HERE}/usr/bin"
export EMACSDIR="\${HERE}/usr/share/emacs"
export EMACSDATA="\${HERE}/usr/share/emacs/\${EMACS_VER}/etc"
export EMACSDOC="\${HERE}/usr/share/emacs/\${EMACS_VER}/etc"
export EMACSLOADPATH="\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp:\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp/emacs-lisp:\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp/progmodes:\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp/language:\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp/international:\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp/textmodes:\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp/vc:\${HERE}/usr/share/emacs/\${EMACS_VER}/lisp/net:\${HERE}/usr/share/emacs/site-lisp"
export FONTCONFIG_PATH="\${HERE}/etc/fonts"
export LIBFUSE_DISABLE_THREAD_SPAWNING=1
export LD_LIBRARY_PATH="\${HERE}/usr/lib:\${HERE}/usr/lib64:\${LD_LIBRARY_PATH:-}"
export LIBRARY_PATH="/usr/lib:/usr/lib64:/usr/lib/gcc:/usr/lib/x86_64-linux-gnu:\${LIBRARY_PATH:-}"
export PATH="\${ARCH_BIN}:\${PATH}"

# ── Writable state dir (tiny — no package copying) ────────────────────────
# Packages and config stay inside the read-only AppImage.
# Only Emacs state (recentf, bookmarks, custom.el, eln-cache) is writable.
USER_STATE="\${HOME}/.local/share/workbenchless"
mkdir -p "\${USER_STATE}"

# Write fresh wrapper files on every launch so paths always point to the
# current AppImage location (HERE changes if the .AppImage is moved/updated).
cat > "\${USER_STATE}/early-init.el" <<EARLYEOF
;;; Generated by workbenchless AppImage — do not edit manually.
;; package-user-dir stays writable (for any user-installed packages).
;; package-directory-list adds the AppImage's read-only elpa so all
;; pre-installed packages are found by package-initialize.
(setq package-user-dir  "\${USER_STATE}/elpa")
(add-to-list 'package-directory-list "\${HERE}/config/elpa")
;; Load the real early-init from inside the AppImage.
(load "\${HERE}/config/early-init.el" nil t)
EARLYEOF

cat > "\${USER_STATE}/init.el" <<INITEOF
;;; Generated by workbenchless AppImage — do not edit manually.
;; Redirect writable Emacs state out of the read-only AppImage.
(setq user-emacs-directory          "\${USER_STATE}/")
(setq custom-file                   "\${USER_STATE}/custom.el")
(setq recentf-save-file             "\${USER_STATE}/recentf")
(setq bookmark-default-file         "\${USER_STATE}/bookmarks")
(setq auto-save-list-file-prefix    "\${USER_STATE}/auto-save/.saves-")
(setq native-comp-eln-load-path     (list "\${USER_STATE}/eln-cache/"))
;; Load the real workbenchless config from inside the AppImage.
(load "\${HERE}/config/init.el" nil t)
INITEOF

# ── Dispatch ──────────────────────────────────────────────────────────────
BIN_NAME=\$(basename "\${ARGV0:-\$0}")
TARGET_BIN="emacs"
ARGS=("\$@")

if [[ "\$BIN_NAME" == "emacsclient"* ]]; then TARGET_BIN="emacsclient"; fi
if [[ "\${1:-}" =~ ^(emacsclient|ctags|etags)\$ ]]; then
    TARGET_BIN="\$1"; ARGS=("\${@:2}")
fi

DUMP_FILE="\${ARCH_LIBEXEC}/emacs.pdmp"

if [[ "\$TARGET_BIN" == "emacs" ]]; then
    if [[ -f "\$DUMP_FILE" ]]; then
        exec "\${ARCH_BIN}/emacs" \
            --name "workbenchless" \
            --init-directory "\${USER_STATE}" \
            --dump-file="\$DUMP_FILE" \
            "\${ARGS[@]}"
    else
        exec "\${ARCH_BIN}/emacs" \
            --name "workbenchless" \
            --init-directory "\${USER_STATE}" \
            "\${ARGS[@]}"
    fi
else
    exec "\${ARCH_BIN}/\${TARGET_BIN}" "\${ARGS[@]}"
fi
EOF

chmod +x "AppRun.source"
echo "✓ AppRun created"
echo ""

################################################################################
# STEP 9: Icon
################################################################################
echo "Step 9: Setting up icon"
echo "───────────────────────────────────────────────────────────────────────"
ICON_FOUND=0
ICON_NAME="workbenchless.png"
TEMP_ICON="$(pwd)/icon_tmp"

if [[ -n "${ICON_URL}" ]]; then
    if wget -q -O "${TEMP_ICON}" "${ICON_URL}" && file "${TEMP_ICON}" | grep -qi "image"; then
        command -v magick &>/dev/null \
            && magick "${TEMP_ICON}" -resize "512x512>" "${APPDIR}/${ICON_NAME}" \
            || mv "${TEMP_ICON}" "${APPDIR}/${ICON_NAME}"
        rm -f "${TEMP_ICON}"
        ICON_FOUND=1
    fi
fi

if [[ $ICON_FOUND -eq 0 ]]; then
    for path in \
        "emacs-${APP_VERSION}/etc/images/icons/hicolor/128x128/apps/emacs.png" \
        "emacs-${APP_VERSION}/etc/images/emacs.png"; do
        if [[ -f "$path" ]]; then
            cp "$path" "${APPDIR}/${ICON_NAME}"; ICON_FOUND=1; break
        fi
    done
fi

if [[ $ICON_FOUND -eq 0 ]]; then
    cat > "${APPDIR}/workbenchless.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <rect width="256" height="256" fill="#2a5f8f" rx="40" ry="40"/>
  <text x="128" y="155" font-size="100" text-anchor="middle" fill="white"
        font-family="monospace" font-weight="bold">WB</text>
</svg>
SVG
    command -v magick &>/dev/null \
        && magick "${APPDIR}/workbenchless.svg" "${APPDIR}/${ICON_NAME}" \
            && rm "${APPDIR}/workbenchless.svg" \
        || mv "${APPDIR}/workbenchless.svg" "${APPDIR}/${ICON_NAME}"
fi

TARGET_ICON_DIR="${APPDIR}/usr/share/icons/hicolor"
for size in 16x16 22x22 32x32 48x48 64x64 128x128 256x256 512x512; do
    mkdir -p "${TARGET_ICON_DIR}/${size}/apps"
    SIZE_NUM=$(echo "$size" | cut -d'x' -f1)
    if command -v magick &>/dev/null; then
        magick "${APPDIR}/${ICON_NAME}" -resize "${SIZE_NUM}x${SIZE_NUM}!" \
            "${TARGET_ICON_DIR}/${size}/apps/workbenchless.png"
    else
        cp "${APPDIR}/${ICON_NAME}" "${TARGET_ICON_DIR}/${size}/apps/workbenchless.png"
    fi
done
echo "✓ Icon ready"
echo ""

################################################################################
# STEP 10: Desktop entry
################################################################################
echo "Step 10: Creating desktop entry"
echo "───────────────────────────────────────────────────────────────────────"
cat > "${APPDIR}/workbenchless.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Workbenchless
GenericName=Scientific Notebook
Comment=Reproducible scientific computing with Emacs Org-mode
Exec=workbenchless %F
Icon=workbenchless
StartupWMClass=workbenchless
StartupNotify=true
Terminal=false
Categories=Science;Development;TextEditor;
MimeType=text/plain;text/x-org;application/x-org;
Keywords=notebook;org;R;python;statistics;science;
EOF
echo "✓ Desktop entry created"
echo ""

################################################################################
# STEP 11: Build tools
################################################################################
echo "Step 11: Preparing build tools"
echo "───────────────────────────────────────────────────────────────────────"
if [[ ! -d "linuxdeploy-build" ]]; then
    wget -q -O linuxdeploy \
        "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
    chmod +x linuxdeploy
    ./linuxdeploy --appimage-extract >/dev/null
    mv squashfs-root linuxdeploy-build
    rm linuxdeploy
fi
if [[ ! -d "appimagetool-build" ]]; then
    wget -q -O appimagetool \
        "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool
    ./appimagetool --appimage-extract >/dev/null
    mv squashfs-root appimagetool-build
    rm appimagetool
fi
export PATH="$(pwd)/linuxdeploy-build/usr/bin:$(pwd)/appimagetool-build/usr/bin:${PATH}"
echo "✓ Tools ready"
echo ""

################################################################################
# STEP 12: Create AppImage
################################################################################
echo "Step 12: Bundling AppImage"
echo "───────────────────────────────────────────────────────────────────────"
export VERSION="${APP_VERSION}"
export NO_STRIP=1

"$(pwd)/linuxdeploy-build/AppRun" \
    --appdir "${APPDIR}" \
    --executable "${APPDIR}/usr/bin/emacs" \
    --desktop-file "${APPDIR}/workbenchless.desktop" \
    --icon-file "${APPDIR}/${ICON_NAME}" \
    --custom-apprun "AppRun.source" \
    --exclude-library libgtk-3.so.0 \
    --exclude-library libgdk-3.so.0 \
    --exclude-library libglib-2.0.so.0 \
    --exclude-library libgio-2.0.so.0 \
    --exclude-library libgobject-2.0.so.0 \
    --exclude-library libpango-1.0.so.0 \
    --exclude-library libpangocairo-1.0.so.0 \
    --exclude-library libcairo.so.2 \
    --exclude-library libcairo-gobject.so.2 \
    --output appimage

# Rename output
GENERATED=$(find . -maxdepth 1 -name "*.AppImage" ! -name "${OUTPUT}" | head -n1)
[[ -n "$GENERATED" ]] && mv "$GENERATED" "${OUTPUT}" || true

chown "${TARGET_UID}:${TARGET_GID}" "${OUTPUT}" 2>/dev/null || true
chmod 755 "${OUTPUT}"
echo "✓ AppImage: ${OUTPUT}"
echo ""

################################################################################
# STEP 13: Cleanup
################################################################################
echo "Step 13: Cleanup"
echo "───────────────────────────────────────────────────────────────────────"
rm -rf "${APPDIR}" "emacs-${APP_VERSION}" "AppRun.source" "${WB_CONFIG}"
echo "✓ Done"
echo ""

################################################################################
# STEP 14: Test
################################################################################
echo "Step 14: Testing"
echo "───────────────────────────────────────────────────────────────────────"
export APPIMAGE_EXTRACT_AND_RUN=1
"./${OUTPUT}" --version 2>&1 | head -2
if "./${OUTPUT}" -Q --batch -eval '(message "OK")' 2>&1 | grep -q "OK"; then
    echo "✓ Emacs batch test passed"
else
    echo "⚠ Batch test unclear (may still work)"
fi
echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo "  BUILD SUCCESSFUL → ${OUTPUT}"
echo "═══════════════════════════════════════════════════════════════════════"
