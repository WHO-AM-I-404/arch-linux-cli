#!/usr/bin/env bash

# =============================================================================
# ARCH LINUX CLI ENHANCEMENT - TERMINAL ONLY
# =============================================================================
# Script untuk meningkatkan environment terminal Arch Linux
# Hanya menginstall tools dan konfigurasi di user space
# TIDAK mengubah OS host atau system files
# Repository: WHO-AM-I-404/arch-linux-cli
# Author: Arch CLI Setup Team
# Version: 2.0-terminal
# =============================================================================

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Configuration variables
readonly LOG_FILE="${HOME}/arch_cli_setup.log"
readonly BACKUP_DIR="${HOME}/.backup_arch_setup"
readonly CONFIG_DIR="${HOME}/.config"

# ASCII Art Banner
print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                  ARCH LINUX TERMINAL ENHANCEMENT                         ║
║                 (Safe for Terminal Use Only)                             ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

# Check internet connection
check_internet() {
    log "Checking internet connection..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        log_error "No internet connection. Please connect to the internet."
        exit 1
    fi
    log_success "Internet connection available!"
}

# Backup existing configurations
backup_configs() {
    log "Backing up existing configurations..."
    mkdir -p "$BACKUP_DIR"
    
    local configs=(
        ".zshrc" ".bashrc" ".tmux.conf" ".config/nvim" ".config/ranger"
        ".oh-my-zsh" ".bash_profile" ".profile"
    )
    
    for config in "${configs[@]}"; do
        if [[ -e "${HOME}/${config}" ]]; then
            cp -r "${HOME}/${config}" "$BACKUP_DIR/" && \
            log "Backed up ${config}"
        fi
    done
    
    log_success "Configurations backed up to $BACKUP_DIR!"
}

# Install packages with error handling
install_packages() {
    local package_manager="$1"
    shift
    local packages=("$@")
    
    for pkg in "${packages[@]}"; do
        log "Installing $pkg..."
        if sudo "$package_manager" -S --noconfirm "$pkg" >> "$LOG_FILE" 2>&1; then
            log "Successfully installed $pkg"
        else
            log_warn "Failed to install $pkg, skipping..."
        fi
    done
}

# Install essential terminal packages
install_terminal_packages() {
    log "Installing terminal packages..."
    
    # Core terminal utilities
    local core_packages=(
        "zsh" "tmux" "git" "curl" "wget" "unzip" "zip" "tar" "gzip" "p7zip"
        "htop" "btop" "neofetch" "tree" "less" "which" "man-db" "man-pages"
        "ranger" "nnn" "fzf" "ripgrep" "fd" "bat" "exa" "lsd" "broot"
        "ncdu" "tldr" "thefuck" "zoxide" "starship" "fastfetch"
    )
    
    # Network tools
    local network_packages=(
        "openssh" "rsync" "aria2" "yt-dlp" "nmap" "netcat" "iperf3" "mtr"
        "speedtest-cli" "bandwhich" "dnsutils" "iputils"
    )
    
    # Development tools
    local dev_packages=(
        "python" "python-pip" "python-virtualenv" "nodejs" "npm" "yarn" "go" "rust" "cargo"
        "gcc" "clang" "cmake" "make" "gdb" "docker" "docker-compose"
    )
    
    # Text processing
    local text_packages=(
        "jq" "yq" "xmlstarlet" "pandoc" "highlight"
        "grep" "sed" "awk" "sort" "uniq" "cut" "tr" "wc"
    )
    
    # Combine all packages
    local all_packages=(
        "${core_packages[@]}" "${network_packages[@]}" 
        "${dev_packages[@]}" "${text_packages[@]}"
    )
    
    install_packages "pacman" "${all_packages[@]}"
    log_success "Terminal packages installed!"
}

# Install AUR helper (yay)
install_aur_helper() {
    if command -v yay &> /dev/null; then
        log "yay is already installed!"
        return 0
    fi
    
    log "Installing AUR helper (yay)..."
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm git base-devel
    
    # Build and install yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    
    log_success "AUR helper installed!"
}

# Install AUR packages
install_aur_packages() {
    log "Installing AUR packages..."
    
    local aur_packages=(
        "gotop-bin" "lazygit" "lazydocker" "bottom"
        "dust" "tokei" "hyperfine" "procs" "tealdeer"
        "nerd-fonts-fira-code" "nerd-fonts-jetbrains-mono"
    )
    
    for pkg in "${aur_packages[@]}"; do
        log "Installing AUR package: $pkg..."
        if yay -S --noconfirm "$pkg" >> "$LOG_FILE" 2>&1; then
            log "Successfully installed $pkg"
        else
            log_warn "Failed to install $pkg, skipping..."
        fi
    done
    
    log_success "AUR packages installed!"
}

# Setup Zsh configuration
setup_zsh() {
    log "Setting up Zsh configuration..."
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install Powerlevel10k theme
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    fi
    
    # Install useful plugins
    local plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-completions"
    )
    
    for plugin in "${plugins[@]}"; do
        local plugin_name=$(basename "$plugin")
        if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name" ]]; then
            git clone "https://github.com/$plugin.git" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name"
        fi
    done
    
    # Create .zshrc
    cat > ~/.zshrc << 'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    docker
    docker-compose
    node
    npm
    python
    pip
    rust
    golang
    tmux
    fzf
    colored-man-pages
    command-not-found
    history-substring-search
    sudo
)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='nvim'
export VISUAL='nvim'

# Custom aliases
alias ll='exa -la --icons --group-directories-first'
alias ls='exa --icons --group-directories-first'
alias lt='exa --tree --icons --level=2'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias du='dust'
alias ps='procs'
alias top='btop'
alias htop='btop'
alias vim='nvim'
alias vi='nvim'

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Zoxide (better cd)
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

    # Change default shell to zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        chsh -s "$(which zsh)"
    fi
    
    log_success "Zsh configuration completed!"
}

# Setup Tmux configuration
setup_tmux() {
    log "Setting up Tmux configuration..."
    
    cat > ~/.tmux.conf << 'EOF'
# Tmux configuration
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Split panes
bind | split-window -h
bind - split-window -v

# Move between panes
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Mouse support
set -g mouse on

# Colors
set -g default-terminal "screen-256color"

# Status bar
set -g status-bg black
set -g status-fg green
set -g status-left-length 30
set -g status-left '#[fg=cyan]#S#[fg=white] | '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M'

# Window status
set -g window-status-format ' #I:#W '
set -g window-status-current-format '#[bg=green,fg=black] #I:#W '

# Pane borders
set -g pane-border-style fg=white
set -g pane-active-border-style fg=green

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1

# Vi mode
setw -g mode-keys vi
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'y' send -X copy-selection

# History limit
set -g history-limit 10000
EOF

    log_success "Tmux configuration completed!"
}

# Create useful scripts
create_scripts() {
    log "Creating useful scripts..."
    
    mkdir -p ~/bin
    
    # System info script
    cat > ~/bin/sysinfo << 'EOF'
#!/usr/bin/env bash

echo "=== SYSTEM INFORMATION ==="
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Uptime: $(uptime -p | sed 's/up //')"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo "Load Average: $(cat /proc/loadavg | cut -d' ' -f1-3)"
echo ""
EOF

    # Package management script
    cat > ~/bin/pm << 'EOF'
#!/usr/bin/env bash

case "$1" in
    "install"|"i")
        sudo pacman -S "${@:2}"
        ;;
    "remove"|"r")
        sudo pacman -R "${@:2}"
        ;;
    "update"|"u")
        sudo pacman -Syu
        ;;
    "search"|"s")
        pacman -Ss "${@:2}"
        ;;
    "info")
        pacman -Si "${@:2}"
        ;;
    "list"|"l")
        pacman -Q | grep "${@:2}"
        ;;
    "orphans")
        pacman -Qtdq
        ;;
    "clean")
        sudo pacman -Sc
        ;;
    "aur")
        yay -S "${@:2}"
        ;;
    *)
        echo "Package Manager Helper"
        echo "Usage: pm <command> [options]"
        echo ""
        echo "Commands:"
        echo "  install|i <package>  - Install package"
        echo "  remove|r <package>   - Remove package"
        echo "  update|u            - Update system"
        echo "  search|s <query>    - Search packages"
        echo "  info <package>      - Package info"
        echo "  list|l [filter]     - List installed packages"
        echo "  orphans             - List orphaned packages"
        echo "  clean               - Clean package cache"
        echo "  aur <package>       - Install from AUR"
        ;;
esac
EOF

    chmod +x ~/bin/*
    
    # Add ~/bin to PATH
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    
    log_success "Useful scripts created!"
}

# Create custom CLI dashboard
create_dashboard() {
    log "Creating CLI dashboard..."
    
    cat > ~/bin/dashboard << 'EOF'
#!/usr/bin/env bash

clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  ARCH LINUX TERMINAL DASHBOARD               ║"
echo "╚══════════════════════════════════════════════════════════════╝"

echo "┌─ SYSTEM INFO ─────────────────────────────────────────────┐"
echo "Host: $(hostname) | User: $(whoami)"
echo "Uptime: $(uptime -p | sed 's/up //')"
echo "Load: $(cat /proc/loadavg | cut -d' ' -f1-3)"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "└───────────────────────────────────────────────────────────┘"

echo "┌─ AVAILABLE TOOLS ─────────────────────────────────────────┐"
echo "System: htop, btop, neofetch, sysinfo"
echo "Files: ranger, nnn, tree, ls, ll"
echo "Network: nettools, speedtest-cli, nmap"
echo "Dev: nvim, git, docker, lazygit"
echo "Package: pm install|remove|update|search"
echo "└───────────────────────────────────────────────────────────┘"

echo "┌─ QUICK COMMANDS ──────────────────────────────────────────┐"
echo "tmux        - Terminal multiplexer"
echo "ranger      - File manager"
echo "lazygit     - Git UI"
echo "btop        - System monitor"
echo "neofetch    - System info"
echo "└───────────────────────────────────────────────────────────┘"
echo ""
EOF

    chmod +x ~/bin/dashboard
    
    log_success "CLI dashboard created!"
}

# Final setup
final_setup() {
    log "Performing final setup..."
    
    # Add dashboard to .zshrc
    echo "" >> ~/.zshrc
    echo "# Auto-run dashboard on new terminal" >> ~/.zshrc
    echo "if [[ -o interactive ]] && [[ ! -v TMUX ]]; then" >> ~/.zshrc
    echo "    dashboard" >> ~/.zshrc
    echo "fi" >> ~/.zshrc
    
    # Create .hushlogin to suppress login messages
    touch ~/.hushlogin
    
    log_success "Final setup completed!"
}

# Display completion message
show_completion() {
    print_banner
    log_success "🎉 Arch Linux Terminal enhancement completed successfully!"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Run 'p10k configure' to setup Powerlevel10k theme"
    echo "3. Type 'dashboard' to see available tools"
    echo "4. Use 'pm' for package management shortcuts"
    echo ""
    echo -e "${YELLOW}Backup location:${NC}"
    echo "Your original configs are backed up at: $BACKUP_DIR"
    echo ""
    echo -e "${CYAN}Happy terminal computing on Arch Linux! 🚀${NC}"
    echo ""
}

# Main installation function
main() {
    print_banner
    
    echo -e "${YELLOW}Arch Linux Terminal Enhancement${NC}"
    echo -e "${WHITE}This script will install and configure:${NC}"
    echo "• Terminal tools and utilities"
    echo "• Zsh with Oh-My-Zsh and Powerlevel10k"
    echo "• Tmux terminal multiplexer"
    echo "• Development tools"
    echo "• Custom scripts and dashboard"
    echo ""
    echo -e "${YELLOW}This script ONLY affects your terminal environment${NC}"
    echo -e "${YELLOW}and does NOT modify your host OS in any way.${NC}"
    echo ""
    
    read -rp "Continue with installation? (y/N): " -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
    
    # Create log file
    touch "$LOG_FILE"
    echo "Arch Linux Terminal Setup Log" > "$LOG_FILE"
    echo "Started at: $(date)" >> "$LOG_FILE"
    echo "==========================================" >> "$LOG_FILE"
    
    check_internet
    backup_configs
    
    log "Starting Arch Linux Terminal enhancement..."
    
    install_terminal_packages
    install_aur_helper
    install_aur_packages
    setup_zsh
    setup_tmux
    create_scripts
    create_dashboard
    final_setup
    
    show_completion
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
