#!/usr/bin/env bash
set -euo pipefail

# Genesis Installer
# Installs Genesis from source (bridgeia-chile/Genesis)
# Usage: curl -fsSL https://raw.githubusercontent.com/bridgeia-chile/Genesis/main/install.sh | bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check for required commands
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install pnpm if not present
ensure_pnpm() {
    if command_exists pnpm; then
        log_info "pnpm already installed ($(pnpm --version))"
        return 0
    fi
    log_warn "pnpm not found, installing..."
    if command_exists npm; then
        npm install -g pnpm
    elif command_exists curl; then
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    elif command_exists wget; then
        wget -qO- https://get.pnpm.io/install.sh | sh -
    else
        log_error "Cannot install pnpm (need npm, curl, or wget). Please install pnpm manually: https://pnpm.io/installation"
        exit 1
    fi
    # Refresh shell (if installed via script)
    export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
    export PATH="$PNPM_HOME:$PATH"
    log_info "pnpm installed ($(pnpm --version))"
}

# Install system build dependencies for native modules
install_build_deps() {
    log_info "Checking system build dependencies..."
    if command_exists apt-get; then
        log_info "Detected Debian/Ubuntu, installing build-essential and python3..."
        sudo apt-get update
        sudo apt-get install -y build-essential python3 pkg-config
    elif command_exists dnf; then
        log_info "Detected Fedora/RHEL, installing development tools..."
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y python3 pkgconfig
    elif command_exists yum; then
        log_info "Detected CentOS/RHEL (old), installing development tools..."
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y python3 pkgconfig
    elif command_exists apk; then
        log_info "Detected Alpine, installing build dependencies..."
        sudo apk add --no-cache build-base python3 pkgconfig
    else
        log_warn "Unknown package manager. You may need to install build tools (gcc, g++, make, python3) manually."
    fi
}

# Setup swap for low-memory ARM devices (Raspberry Pi)
setup_swap_if_needed() {
    local total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local swap_size=$((2 * 1024 * 1024)) # 2GB in kB
    if [[ "$(uname -m)" == "arm"* || "$(uname -m)" == "aarch64" ]] && [[ $total_ram -lt $swap_size ]]; then
        log_warn "Low memory ARM device detected. Checking swap..."
        if ! swapon --show | grep -q '.'; then
            log_info "No swap found. Creating 2GB swap file..."
            sudo fallocate -l 2G /swapfile
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile
            echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
            log_info "Swap enabled."
        else
            log_info "Swap already configured."
        fi
    fi
}

# Clone repository if not already in a Genesis directory
clone_if_needed() {
    local target_dir="${1:-genesis}"
    if [[ -d ".git" ]] && [[ -f "package.json" ]] && grep -q '"name": "genesis"' package.json 2>/dev/null; then
        log_info "Already inside Genesis repository, skipping clone."
        return 0
    fi
    if [[ -d "$target_dir" ]]; then
        log_warn "Directory '$target_dir' already exists. Using existing directory."
        cd "$target_dir"
        return 0
    fi
    log_info "Cloning Genesis repository..."
    git clone https://github.com/bridgeia-chile/Genesis.git "$target_dir"
    cd "$target_dir"
}

main() {
    log_info "Starting Genesis installation..."
    
    # Ensure pnpm
    ensure_pnpm
    
    # Clone if needed
    clone_if_needed
    
    # Install system build dependencies
    install_build_deps
    setup_swap_if_needed

    # Install dependencies
    log_info "Installing dependencies (this may take a few minutes)..."
    pnpm install
    
    # Build UI
    log_info "Building UI..."
    pnpm ui:build
    
    # Build everything else
    log_info "Building project..."
    pnpm build
    
    # Run onboard (optional, can be skipped)
    if [[ "${GENESIS_SKIP_ONBOARD:-0}" != "1" ]]; then
        log_info "Running Genesis onboard setup..."
        pnpm genesis onboard --install-daemon
    else
        log_warn "Skipping onboard setup (GENESIS_SKIP_ONBOARD=1). Run 'pnpm genesis onboard' later."
    fi
    
    log_info "Installation complete!"
    echo ""
    echo "To start the gateway daemon:"
    echo "  pnpm gateway:watch   # development mode with auto‑reload"
    echo "  pnpm start           # production start"
    echo ""
    echo "To use the CLI:"
    echo "  pnpm genesis --help"
    echo ""
    echo "Documentation: https://docs.genesis.ai"
    echo "Need help? Join Discord: https://discord.gg/clawd"
}

# Run main
main "$@"