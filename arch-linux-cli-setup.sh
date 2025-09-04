#!/usr/bin/env bash

# =============================================================================
# ARCH LINUX CLI COMPLETE SETUP - ENHANCED EDITION
# =============================================================================
# Script lengkap untuk setup Arch Linux CLI dengan semua tools dan konfigurasi
# Repository: WHO-AM-I-404/arch-linux-cli
# Author: Arch CLI Setup Team
# Version: 2.0
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
readonly LOG_FILE="/tmp/arch-cli-setup.log"
readonly BACKUP_DIR="${HOME}/.backup_arch_setup"
readonly CONFIG_DIR="${HOME}/.config"

# ASCII Art Banner
print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║                                                                          ║
    ║     █████╗ ██████╗  ██████╗██╗  ██╗     ██████╗██╗     ██╗              ║
    ║    ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔════╝██║     ██║              ║
    ║    ███████║██████╔╝██║     ███████║    ██║     ██║     ██║              ║
    ║    ██╔══██║██╔══██╗██║     ██╔══██║    ██║     ██║     ██║              ║
    ║    ██║  ██║██║  ██║╚██████╗██║  ██║    ╚██████╗███████╗██║              ║
    ║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝╚══════╝╚═╝              ║
    ║                                                                          ║
    ║              ARCH LINUX CLI COMPLETE SETUP - ENHANCED EDITION            ║
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

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Jangan jalankan script ini sebagai root!"
        exit 1
    fi
}

# Check internet connection
check_internet() {
    log "Checking internet connection..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        log_error "Tidak ada koneksi internet. Pastikan Anda terhubung ke internet."
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

# Update system
update_system() {
    log "Updating system packages..."
    sudo pacman -Syu --noconfirm >> "$LOG_FILE" 2>&1
    log_success "System updated successfully!"
}

# Install AUR helper (yay or paru)
install_aur_helper() {
    log "Installing AUR helper..."
    
    # Check if yay or paru already installed
    if command -v yay &> /dev/null; then
        log "yay is already installed!"
        return 0
    fi
    
    if command -v paru &> /dev/null; then
        log "paru is already installed!"
        return 0
    fi
    
    # Let user choose which AUR helper to install
    echo -e "${YELLOW}Choose AUR helper to install:${NC}"
    echo "1) yay (Recommended)"
    echo "2) paru"
    echo "3) Skip AUR helper installation"
    
    read -rp "Enter your choice [1-3]: " choice
    case $choice in
        1)
            log "Installing yay..."
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay
            makepkg -si --noconfirm
            cd ~
            rm -rf /tmp/yay
            log_success "yay installed successfully!"
            ;;
        2)
            log "Installing paru..."
            git clone https://aur.archlinux.org/paru.git /tmp/paru
            cd /tmp/paru
            makepkg -si --noconfirm
            cd ~
            rm -rf /tmp/paru
            log_success "paru installed successfully!"
            ;;
        3)
            log_warn "Skipping AUR helper installation."
            ;;
        *)
            log "Invalid choice, installing yay by default..."
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay
            makepkg -si --noconfirm
            cd ~
            rm -rf /tmp/yay
            log_success "yay installed successfully!"
            ;;
    esac
}

# Function to install packages with error handling
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

# Install essential packages
install_essential_packages() {
    log "Installing essential packages..."
    
    # Core system packages
    local core_packages=(
        "base-devel" "git" "curl" "wget" "unzip" "zip" "tar" "gzip" "p7zip"
        "htop" "btop" "neofetch" "tree" "less" "which" "man-db" "man-pages"
        "zsh" "tmux" "screen" "vim" "neovim" "emacs" "nano" "micro"
        "ranger" "nnn" "fzf" "ripgrep" "fd" "bat" "exa" "lsd" "broot"
        "ncdu" "tldr" "thefuck" "zoxide" "starship" "fastfetch"
    )
    
    # Network tools
    local network_packages=(
        "openssh" "rsync" "aria2" "youtube-dl" "yt-dlp" "wget2"
        "nmap" "netcat" "wireshark-cli" "tcpdump" "iperf3" "mtr"
        "speedtest-cli" "bandwhich" "inetutils" "dnsutils" "iputils"
    )
    
    # Development tools
    local dev_packages=(
        "python" "python-pip" "python-virtualenv" "nodejs" "npm" "yarn" "go" "rust" "cargo"
        "gcc" "clang" "cmake" "make" "gdb" "strace" "ltrace" "valgrind" "binutils"
        "docker" "docker-compose" "podman" "buildah" "kubectl" "helm"
        "jdk-openjdk" "jre-openjdk" "maven" "gradle" "php" "ruby" "lua"
    )
    
    # Media tools
    local media_packages=(
        "ffmpeg" "imagemagick" "cmus" "mpv" "vlc" "feh" "imv"
        "gimp" "blender" "obs-studio" "inkscape" "gthumb"
    )
    
    # System monitoring
    local monitor_packages=(
        "iotop" "nethogs" "powertop" "lsof" "pstree" "htop"
        "dstat" "glances" "iftop" "atop" "sysstat" "lm_sensors"
    )
    
    # Text processing
    local text_packages=(
        "jq" "yq" "xmlstarlet" "pandoc" "markdown" "highlight"
        "grep" "sed" "awk" "sort" "uniq" "cut" "tr" "wc"
    )
    
    # Security tools
    local security_packages=(
        "gnupg" "pass" "openssl" "nmap" "nethogs" "wireshark-cli"
        "clamav" "rkhunter" "chkrootkit" "fail2ban" "ufw"
    )
    
    # Combine all packages
    local all_packages=(
        "${core_packages[@]}" "${network_packages[@]}" 
        "${dev_packages[@]}" "${media_packages[@]}" 
        "${monitor_packages[@]}" "${text_packages[@]}"
        "${security_packages[@]}"
    )
    
    install_packages "pacman" "${all_packages[@]}"
    log_success "Essential packages installed!"
}

# Install AUR packages
install_aur_packages() {
    log "Installing AUR packages..."
    
    # Determine which AUR helper to use
    local aur_helper=""
    if command -v yay &> /dev/null; then
        aur_helper="yay"
    elif command -v paru &> /dev/null; then
        aur_helper="paru"
    else
        log_warn "No AUR helper found, skipping AUR packages!"
        return 1
    fi
    
    local aur_packages=(
        "gotop-bin" "lazygit" "lazydocker" "bottom"
        "dust" "tokei" "hyperfine" "procs" "bandwhich"
        "broot" "lf" "fff" "navi" "tealdeer" "delta"
        "chezmoi" "antibody" "starship-bin" "nerd-fonts-fira-code"
        "nerd-fonts-jetbrains-mono" "visual-studio-code-bin"
        "google-chrome" "brave-bin" "spotify" "discord"
        "timeshift" "stacer-bin" "peek" "mongodb-compass"
    )
    
    for pkg in "${aur_packages[@]}"; do
        log "Installing AUR package: $pkg..."
        if "$aur_helper" -S --noconfirm "$pkg" >> "$LOG_FILE" 2>&1; then
            log "Successfully installed $pkg"
        else
            log_warn "Failed to install $pkg, skipping..."
        fi
    done
    
    log_success "AUR packages installed!"
}

# Install programming languages and version managers
install_programming_tools() {
    log "Installing programming tools and version managers..."
    
    # Install version managers
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    curl -fsSL https://pyenv.run | bash
    curl -fsSL https://rbenv.org/install.sh | bash
    
    # Add version managers to shell configuration
    cat >> ~/.zshrc << 'EOF'

# Version managers
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export RBENV_ROOT="$HOME/.rbenv"
command -v rbenv >/dev/null || export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init - zsh)"
EOF
    
    log_success "Programming tools installed!"
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
        "Aloxaf/fzf-tab"
        "hlissner/zsh-autopair"
        "MichaelAquilina/zsh-you-should-use"
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
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="false"
DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=7
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fzf-tab
    zsh-autopair
    you-should-use
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
    extract
    cp
)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export MANPAGER='less -R'

# Custom aliases
alias ll='exa -la --icons --group-directories-first'
alias ls='exa --icons --group-directories-first'
alias lt='exa --tree --icons --level=2'
alias l='exa -l --icons --group-directories-first'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias du='dust'
alias ps='procs'
alias top='btop'
alias htop='btop'
alias vim='nvim'
alias vi='nvim'
alias view='nvim -R'
alias diff='delta'
alias ip='ip -color=auto'
alias pacman='sudo pacman'
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias ssh='TERM=xterm-256color ssh'

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
            *.deb)       ar x "$1"        ;;
            *.tar.xz)    tar xf "$1"      ;;
            *.tar.zst)   tar xf "$1"      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Browser launcher function
browser() {
    case "$1" in
        "firefox"|"ff")
            firefox > /dev/null 2>&1 &
            ;;
        "chrome"|"google")
            google-chrome-stable > /dev/null 2>&1 &
            ;;
        "chromium")
            chromium > /dev/null 2>&1 &
            ;;
        "brave")
            brave > /dev/null 2>&1 &
            ;;
        "links")
            links "$2"
            ;;
        "lynx")
            lynx "$2"
            ;;
        "w3m")
            w3m "$2"
            ;;
        *)
            echo "Available browsers:"
            echo "  GUI: firefox|ff, chrome|google, chromium, brave"
            echo "  CLI: links, lynx, w3m"
            echo "Usage: browser <browser_name> [url]"
            ;;
    esac
}

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers {} 2>/dev/null || ls -la {}"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"

# Zoxide (better cd)
eval "$(zoxide init zsh)"

# Starship prompt (alternative to powerlevel10k)
# eval "$(starship init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load local configurations
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
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
    
    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    
    cat > ~/.tmux.conf << 'EOF'
# Tmux configuration
# Prefix key
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Split panes
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Move between panes
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Mouse support
set -g mouse on

# Colors
set -g default-terminal "screen-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Status bar
set -g status-style bg=black,fg=green
set -g status-left-length 30
set -g status-left '#[fg=cyan]#S#[fg=white] | '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M #[fg=magenta]#(whoami)@#h'

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
bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle

# History limit
set -g history-limit 10000

# Set easier window split keys
bind-key v split-window -h
bind-key h split-window -v

# Easy config reload
bind-key R source-file ~/.tmux.conf \; display-message "tmux.conf reloaded"

# Plugin setup
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'catppuccin/tmux'

# Continuum and Resurrect settings
set -g @resurrect-capture-pane-contents 'on'
set -g @continuum-restore 'on'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF

    log_success "Tmux configuration completed!"
}

# Setup Neovim configuration
setup_neovim() {
    log "Setting up Neovim configuration..."
    
    # Create config directory
    mkdir -p ~/.config/nvim
    
    # Install packer.nvim (plugin manager)
    if [[ ! -d "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]]; then
        git clone --depth 1 https://github.com/wbthomason/packer.nvim \
            ~/.local/share/nvim/site/pack/packer/start/packer.nvim
    fi
    
    # Create basic init.lua
    cat > ~/.config/nvim/init.lua << 'EOF'
-- Neovim configuration using Lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable line numbers and relative numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.wrap = false

-- Backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Other settings
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.completeopt = "menuone,noselect"

-- Key mappings
local keymap = vim.keymap.set

-- Leader key mappings
keymap("n", "<leader>pv", vim.cmd.Ex)
keymap("n", "<leader><CR>", ":so ~/.config/nvim/init.lua<CR>")

-- Window navigation
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

-- Resize windows
keymap("n", "<C-Left>", ":vertical resize -2<CR>")
keymap("n", "<C-Right>", ":vertical resize +2<CR>")
keymap("n", "<C-Up>", ":resize -2<CR>")
keymap("n", "<C-Down>", ":resize +2<CR>")

-- Tab management
keymap("n", "<leader>to", ":tabnew<CR>")
keymap("n", "<leader>tx", ":tabclose<CR>")
keymap("n", "<leader>tn", ":tabn<CR>")
keymap("n", "<leader>tp", ":tabp<CR>")

-- Plugin management with packer
require('packer').startup(function(use)
    -- Package manager
    use 'wbthomason/packer.nvim'
    
    -- Colorschemes
    use 'navarasu/onedark.nvim'
    use 'folke/tokyonight.nvim'
    use 'catppuccin/nvim'
    use 'ellisonleao/gruvbox.nvim'
    
    -- File explorer
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        tag = 'nightly' -- optional, updated every week. (see issue #1193)
    }
    
    -- Status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    
    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    
    -- Treesitter (syntax highlighting)
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    
    -- LSP configuration
    use {
        'neovim/nvim-lspconfig',
        requires = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            
            -- Useful status updates for LSP
            'j-hui/fidget.nvim',
            
            -- Additional lua configuration, makes nvim stuff amazing
            'folke/neodev.nvim',
        },
    }
    
    -- Autocompletion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip',
            'rafamadriz/friendly-snippets',
        },
    }
    
    -- Git integration
    use 'lewis6991/gitsigns.nvim'
    use 'tpope/vim-fugitive'
    
    -- Comments
    use 'tpope/vim-commentary'
    
    -- Surround
    use 'tpope/vim-surround'
    
    -- Auto pairs
    use 'windwp/nvim-autopairs'
    
    -- Which-key
    use 'folke/which-key.nvim'
end)

-- Setup plugins after installation
-- After changing plugin config run :PackerCompile
-- Then restart neovim and run :PackerInstall

-- Set colorscheme
vim.cmd[[colorscheme onedark]]

-- Enable treesitter
require('nvim-treesitter.configs').setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript", "html", "css", "rust", "go" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

-- Setup lualine
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'onedark',
    },
}

-- Setup nvim-tree
require("nvim-tree").setup()

-- Setup telescope
require('telescope').setup{
    defaults = {
        mappings = {
            i = {
                ["<C-u>"] = false,
                ["<C-d>"] = false,
            },
        },
    },
}

-- Add key mapping for telescope
keymap('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[F]ind [F]iles' })
keymap('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = '[F]ind by [G]rep' })
keymap('n', '<leader>fb', require('telescope.builtin').buffers, { desc = '[F]ind [B]uffers' })
keymap('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[F]ind [H]elp' })

-- Enable which-key
require("which-key").setup {}

-- Enable gitsigns
require('gitsigns').setup()

-- Enable autopairs
require('nvim-autopairs').setup()

-- LSP setup
local lspconfig = require('lspconfig')

-- Setup mason
require('mason').setup()
require('mason-lspconfig').setup()

-- Setup language servers
local servers = { 'pyright', 'tsserver', 'gopls', 'rust_analyzer', 'html', 'cssls', 'clangd' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

-- Global mappings.
keymap('n', '<space>e', vim.diagnostic.open_float)
keymap('n', '[d', vim.diagnostic.goto_prev)
keymap('n', ']d', vim.diagnostic.goto_next)
keymap('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        local opts = { buffer = ev.buf }
        keymap('n', 'gD', vim.lsp.buf.declaration, opts)
        keymap('n', 'gd', vim.lsp.buf.definition, opts)
        keymap('n', 'K', vim.lsp.buf.hover, opts)
        keymap('n', 'gi', vim.lsp.buf.implementation, opts)
        keymap('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        keymap('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        keymap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        keymap('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        keymap('n', '<space>D', vim.lsp.buf.type_definition, opts)
        keymap('n', '<space>rn', vim.lsp.buf.rename, opts)
        keymap({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        keymap('n', 'gr', vim.lsp.buf.references, opts)
        keymap('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
EOF

    log_success "Neovim configuration completed!"
}

# Setup file manager (Ranger) configuration
setup_ranger() {
    log "Setting up Ranger configuration..."
    
    mkdir -p ~/.config/ranger
    
    # Generate default config
    ranger --copy-config=all 2>/dev/null || true
    
    # Customize rc.conf
    cat > ~/.config/ranger/rc.conf << 'EOF'
# ===================================================================
# == Ranger Options
# ===================================================================

set preview_images true
set preview_images_method ueberzug
set use_preview_script true
set preview_files true
set preview_directories true
set collapse_preview true
set show_hidden false
set colorscheme default
set column_ratios 1,3,4
set hidden_filter ^\.|\.(?:pyc|pyo|bak|swp)$|^lost\+found$|^__(py)?cache__$
set show_hidden false
set preview_max_size 0
set open_all_images true

# ===================================================================
# == Key Bindings
# ===================================================================

# Basic
map DD shell mv %s ~/.local/share/Trash/files/
map <C-f> fzf_select
map <C-l> redraw_window

# Navigation
map J  move down=0.5
map K  move up=0.5
map H history_go -1
map L history_go 1

# Tabs
map <C-n>     tab_new
map <C-w>     tab_close
map <TAB>     tab_move 1
map <S-TAB>   tab_move -1
map <A-Right> tab_move 1
map <A-Left>  tab_move -1

# Sorting
map or set sort_reverse!
map oz set sort=random
map os chain set sort=size;      set sort_reverse=False
map ob chain set sort=basename;  set sort_reverse=False
map om chain set sort=mtime;     set sort_reverse=False
map oc chain set sort=ctime;     set sort_reverse=False
map oa chain set sort=atime;     set sort_reverse=False

# ===================================================================
# == Commands
# ===================================================================

# Define the 'extract' command
shell /usr/bin/bash
cmd extract %${
    if [ -f "$1" ]; then
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
            *.deb)       ar x "$1"        ;;
            *.tar.xz)    tar xf "$1"      ;;
            *.tar.zst)   tar xf "$1"      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Define the 'compress' command
cmd compress %${ 
    if [ -n "$1" ]; then
        FILE="$1"
        case "$FILE" in
            *.tar.bz2)   tar cjf "$FILE" "${@:2}" ;;
            *.tar.gz)    tar czf "$FILE" "${@:2}" ;;
            *.tgz)       tar czf "$FILE" "${@:2}" ;;
            *.zip)       zip -r "$FILE" "${@:2}" ;;
            *.rar)       rar a "$FILE" "${@:2}" ;;
            *.7z)        7z a "$FILE" "${@:2}" ;;
            *)           echo "'$FILE' cannot be compressed via compress()" ;;
        esac
    else
        echo "Usage: compress <foo.tar.gz> ./foo/"
    fi
}
EOF

    # Create plugin directory and install plugins
    mkdir -p ~/.config/ranger/plugins
    git clone https://github.com/laggardkernel/ranger-fzf-marks.git ~/.config/ranger/plugins/fzf-marks 2>/dev/null || true
    
    log_success "Ranger configuration completed!"
}

# Setup development environment
setup_dev_environment() {
    log "Setting up development environment..."
    
    # Create development directories
    mkdir -p ~/Development/{python,js,go,rust,cpp,web,scripts,misc}
    
    # Create virtual environments
    python -m venv ~/Development/python/venv
    
    # Create global .gitignore
    cat > ~/.gitignore_global << 'EOF'
# Compiled source #
###################
*.com
*.class
*.dll
*.exe
*.o
*.so
*.pyc
__pycache__/
*.egg-info/
*.egg

# Packages #
############
# it's better to unpack these files and commit the raw source
# git has its own built in compression methods
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Logs and databases #
######################
*.log
*.sql
*.sqlite

# OS generated files #
######################
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor directories and files #
################################
.vscode/
.idea/
*.swp
*.swo
*~
EOF
    
    # Configure git
    git config --global core.excludesfile ~/.gitignore_global
    git config --global user.name "$(whoami)"
    git config --global user.email "$(whoami)@$(hostname)"
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global color.ui auto
    
    log_success "Development environment setup completed!"
}

# Create useful scripts
create_scripts() {
    log "Creating useful scripts..."
    
    mkdir -p ~/bin
    
    # System info script
    cat > ~/bin/sysinfo << 'EOF'
#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== SYSTEM INFORMATION ===${NC}"
echo -e "${GREEN}Hostname:${NC} $(hostname)"
echo -e "${GREEN}User:${NC} $(whoami)"
echo -e "${GREEN}Uptime:${NC} $(uptime -p | sed 's/up //')"
echo -e "${GREEN}Kernel:${NC} $(uname -r)"
echo -e "${GREEN}Architecture:${NC} $(uname -m)"
echo -e "${GREEN}CPU:${NC} $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo -e "${GREEN}CPU Cores:${NC} $(nproc)"
echo -e "${GREEN}Memory:${NC} $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo -e "${GREEN}Disk:${NC} $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo -e "${GREEN}Load Average:${NC} $(cat /proc/loadavg | cut -d' ' -f1-3)"
echo -e "${GREEN}Processes:${NC} $(ps -e | wc -l)"
echo -e "${GREEN}Temperature:${NC} $(sensors 2>/dev/null | grep 'Package id' | awk '{print $4}' || echo 'N/A')"

# Show distribution info
if command -v lsb_release &> /dev/null; then
    echo -e "${GREEN}Distribution:${NC} $(lsb_release -d | cut -f2)"
fi

# Show shell info
echo -e "${GREEN}Shell:${NC} $SHELL"
echo -e "${GREEN}Terminal:${NC} $TERM"

# Show public IP if available
if command -v curl &> /dev/null; then
    public_ip=$(curl -s https://ipinfo.io/ip || echo "N/A")
    echo -e "${GREEN}Public IP:${NC} $public_ip"
fi

echo ""
EOF

    # Package management script
    cat > ~/bin/pm << 'EOF'
#!/usr/bin/env bash

# Package Manager Helper Script

# Determine AUR helper
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
fi

case "$1" in
    "install"|"i")
        if [[ "$2" == "--aur" ]] && [[ -n "$AUR_HELPER" ]]; then
            shift 2
            $AUR_HELPER -S "$@"
        else
            sudo pacman -S "${@:2}"
        fi
        ;;
    "remove"|"r")
        sudo pacman -R "${@:2}"
        ;;
    "update"|"u")
        if [[ "$2" == "--aur" ]] && [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -Syu
        else
            sudo pacman -Syu
        fi
        ;;
    "search"|"s")
        if [[ "$2" == "--aur" ]] && [[ -n "$AUR_HELPER" ]]; then
            shift 2
            $AUR_HELPER -Ss "$@"
        else
            pacman -Ss "${@:2}"
        fi
        ;;
    "info")
        pacman -Si "${@:2}"
        ;;
    "list"|"l")
        if [[ "$2" == "--orphans" ]]; then
            pacman -Qtdq
        elif [[ "$2" == "--explicit" ]]; then
            pacman -Qe
        elif [[ "$2" == "--aur" ]] && [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -Qm
        else
            pacman -Q "${@:2}"
        fi
        ;;
    "orphans")
        pacman -Qtdq
        ;;
    "clean")
        if [[ "$2" == "--all" ]]; then
            sudo pacman -Scc
        else
            sudo pacman -Sc
        fi
        ;;
    "stats")
        echo "Installed packages: $(pacman -Q | wc -l)"
        if [[ -n "$AUR_HELPER" ]]; then
            echo "AUR packages: $($AUR_HELPER -Qm | wc -l)"
        fi
        echo "Orphaned packages: $(pacman -Qtdq | wc -l)"
        ;;
    "aur")
        if [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -S "${@:2}"
        else
            echo "No AUR helper installed. Install yay or paru first."
        fi
        ;;
    *)
        echo "Package Manager Helper"
        echo "Usage: pm <command> [options]"
        echo ""
        echo "Commands:"
        echo "  install|i [--aur] <package>  - Install package (from AUR with --aur)"
        echo "  remove|r <package>           - Remove package"
        echo "  update|u [--aur]             - Update system (AUR packages with --aur)"
        echo "  search|s [--aur] <query>     - Search packages (AUR with --aur)"
        echo "  info <package>               - Package info"
        echo "  list|l [options]             - List installed packages"
        echo "          --orphans            - List orphaned packages"
        echo "          --explicit           - List explicitly installed packages"
        echo "          --aur                - List AUR packages"
        echo "  orphans                      - List orphaned packages"
        echo "  clean [--all]                - Clean package cache (--all for full clean)"
        echo "  stats                        - Show package statistics"
        echo "  aur <package>                - Install from AUR (if AUR helper available)"
        ;;
esac
EOF

    # Network tools script
    cat > ~/bin/nettools << 'EOF'
#!/usr/bin/env bash

case "$1" in
    "scan")
        if command -v nmap &> /dev/null; then
            nmap -sn 192.168.1.0/24
        else
            echo "nmap is not installed. Install it with: pm install nmap"
        fi
        ;;
    "ports")
        sudo netstat -tulpn
        ;;
    "speed")
        if command -v speedtest-cli &> /dev/null; then
            speedtest-cli
        else
            echo "speedtest-cli is not installed. Install it with: pm install speedtest-cli"
        fi
        ;;
    "ip")
        echo "Local IP: $(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')"
        if command -v curl &> /dev/null; then
            echo "Public IP: $(curl -s https://ipinfo.io/ip)"
        else
            echo "Public IP: curl not installed"
        fi
        ;;
    "wifi")
        if command -v nmcli &> /dev/null; then
            nmcli dev wifi list
        else
            echo "nmcli is not installed. Install it with: pm install networkmanager"
        fi
        ;;
    "dns")
        if command -v dig &> /dev/null; then
            dig "$2"
        else
            echo "dig is not installed. Install it with: pm install dnsutils"
        fi
        ;;
    "ping")
        ping -c 4 "$2"
        ;;
    "traceroute")
        if command -v traceroute &> /dev/null; then
            traceroute "$2"
        else
            echo "traceroute is not installed. Install it with: pm install traceroute"
        fi
        ;;
    *)
        echo "Network Tools"
        echo "Usage: nettools <command> [options]"
        echo ""
        echo "Commands:"
        echo "  scan         - Scan local network"
        echo "  ports        - Show open ports"
        echo "  speed        - Internet speed test"
        echo "  ip           - Show IP addresses"
        echo "  wifi         - Show WiFi networks"
        echo "  dns <domain> - DNS lookup"
        echo "  ping <host>  - Ping host"
        echo "  traceroute <host> - Trace route to host"
        ;;
esac
EOF

    # System maintenance script
    cat > ~/bin/sysmaintenance << 'EOF'
#!/usr/bin/env bash

case "$1" in
    "clean")
        echo "Cleaning package cache..."
        sudo pacman -Sc --noconfirm
        
        echo "Cleaning temporary files..."
        sudo rm -rf /tmp/*
        rm -rf ~/.cache/*
        
        echo "Cleaning browser caches..."
        for browser in ~/.cache/*; do
            if [[ -d "$browser" ]]; then
                rm -rf "$browser/Cache"
                rm -rf "$browser/Code Cache"
            fi
        done
        
        echo "Cleaning completed!"
        ;;
    "update")
        echo "Updating system..."
        sudo pacman -Syu --noconfirm
        
        if command -v yay &> /dev/null; then
            echo "Updating AUR packages..."
            yay -Syu --noconfirm
        elif command -v paru &> /dev/null; then
            echo "Updating AUR packages..."
            paru -Syu --noconfirm
        fi
        
        echo "System updated successfully!"
        ;;
    "orphans")
        echo "Removing orphaned packages..."
        orphans=$(pacman -Qtdq)
        if [[ -n "$orphans" ]]; then
            sudo pacman -Rns --noconfirm $(pacman -Qtdq)
        else
            echo "No orphaned packages found."
        fi
        ;;
    "logs")
        echo "Viewing system logs..."
        journalctl -xe
        ;;
    "backup")
        echo "Creating backup of important files..."
        backup_dir="$HOME/backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        
        # Backup important directories
        important_dirs=(
            "$HOME/.config"
            "$HOME/.ssh"
            "$HOME/.local/bin"
            "$HOME/Documents"
            "$HOME/Development"
        )
        
        for dir in "${important_dirs[@]}"; do
            if [[ -d "$dir" ]]; then
                cp -r "$dir" "$backup_dir/"
            fi
        done
        
        # Backup important files
        important_files=(
            "$HOME/.zshrc"
            "$HOME/.bashrc"
            "$HOME/.tmux.conf"
            "$HOME/.gitconfig"
        )
        
        for file in "${important_files[@]}"; do
            if [[ -f "$file" ]]; then
                cp "$file" "$backup_dir/"
            fi
        done
        
        echo "Backup created at: $backup_dir"
        ;;
    *)
        echo "System Maintenance"
        echo "Usage: sysmaintenance <command>"
        echo ""
        echo "Commands:"
        echo "  clean     - Clean system cache and temporary files"
        echo "  update    - Update system and AUR packages"
        echo "  orphans   - Remove orphaned packages"
        echo "  logs      - View system logs"
        echo "  backup    - Create backup of important files"
        ;;
esac
EOF

    # Make scripts executable
    chmod +x ~/bin/*
    
    # Add ~/bin to PATH
    if ! grep -q "$HOME/bin" ~/.zshrc; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    fi
    
    log_success "Useful scripts created!"
}

# Create custom CLI dashboard
create_dashboard() {
    log "Creating CLI dashboard..."
    
    cat > ~/bin/dashboard << 'EOF'
#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Art
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                         ARCH CLI DASHBOARD                               ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# System info section
echo -e "${WHITE}┌─ SYSTEM INFO ─────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}Host:${NC} $(hostname) | ${GREEN}User:${NC} $(whoami)"
echo -e "${GREEN}Uptime:${NC} $(uptime -p | sed 's/up //')"
echo -e "${GREEN}Load:${NC} $(cat /proc/loadavg | cut -d' ' -f1-3)"
echo -e "${GREEN}Memory:${NC} $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo -e "${GREEN}Disk:${NC} $(df -h / | tail -1 | awk '{print $4 " free of " $2}')"
echo -e "${WHITE}└───────────────────────────────────────────────────────────┘${NC}"

# Available tools
echo -e "${WHITE}┌─ AVAILABLE TOOLS ─────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}System:${NC} htop, btop, neofetch, sysinfo, sysmaintenance"
echo -e "${YELLOW}Files:${NC} ranger, nnn, lf, tree, ls, ll"
echo -e "${YELLOW}Network:${NC} nettools, speedtest-cli, nmap, ping, traceroute"
echo -e "${YELLOW}Dev:${NC} nvim, git, docker, lazygit, lazydocker"
echo -e "${YELLOW}Browsers:${NC} browser firefox|chrome|brave|links|lynx"
echo -e "${YELLOW}Package:${NC} pm install|remove|update|search|stats"
echo -e "${WHITE}└───────────────────────────────────────────────────────────┘${NC}"

# Quick commands
echo -e "${WHITE}┌─ QUICK COMMANDS ──────────────────────────────────────────┐${NC}"
echo -e "${CYAN}tmux${NC}        - Terminal multiplexer"
echo -e "${CYAN}ranger${NC}      - File manager"
echo -e "${CYAN}lazygit${NC}     - Git UI"
echo -e "${CYAN}btop${NC}        - System monitor"
echo -e "${CYAN}neofetch${NC}    - System info"
echo -e "${CYAN}nvim${NC}        - Text editor"
echo -e "${CYAN}pm stats${NC}    - Package statistics"
echo -e "${WHITE}└───────────────────────────────────────────────────────────┘${NC}"

# Recent files
echo -e "${WHITE}┌─ RECENT FILES ────────────────────────────────────────────┐${NC}"
if command -z lsd &> /dev/null; then
    lsd -la --color=always ~/ | head -10
else
    ls -la ~/ | head -10
fi
echo -e "${WHITE}└───────────────────────────────────────────────────────────┘${NC}"

echo ""
EOF

    chmod +x ~/bin/dashboard
    
    log_success "CLI dashboard created!"
}

# Setup security enhancements
setup_security() {
    log "Setting up security enhancements..."
    
    # Setup firewall (UFW)
    if command -v ufw &> /dev/null; then
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw enable
    fi
    
    # Setup fail2ban
    if command -v fail2ban-server &> /dev/null; then
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
    fi
    
    # Create security check script
    cat > ~/bin/security-check << 'EOF'
#!/usr/bin/env bash

echo "=== SECURITY CHECK ==="
echo ""

# Check firewall status
echo "Firewall status:"
if command -v ufw &> /dev/null; then
    sudo ufw status
else
    echo "UFW not installed. Install with: pm install ufw"
fi
echo ""

# Check fail2ban status
echo "Fail2Ban status:"
if command -v fail2ban-client &> /dev/null; then
    sudo fail2ban-client status
else
    echo "Fail2Ban not installed. Install with: pm install fail2ban"
fi
echo ""

# Check for open ports
echo "Open ports:"
sudo netstat -tulpn | grep LISTEN
echo ""

# Check system updates
echo "System updates:"
if checkupdates &> /dev/null; then
    echo "Updates available!"
else
    echo "System is up to date."
fi
echo ""

# Check login history
echo "Recent logins:"
last -10
echo ""
EOF

    chmod +x ~/bin/security-check
    
    log_success "Security enhancements setup completed!"
}

# Final setup and cleanup
final_setup() {
    log "Performing final setup..."
    
    # Add dashboard to .zshrc
    if ! grep -q "dashboard" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Auto-run dashboard on new terminal" >> ~/.zshrc
        echo "if [[ -o interactive ]] && [[ ! -v TMUX ]]; then" >> ~/.zshrc
        echo "    dashboard" >> ~/.zshrc
        echo "fi" >> ~/.zshrc
    fi
    
    # Create .hushlogin to suppress login messages
    touch ~/.hushlogin
    
    # Update locate database
    sudo updatedb 2>/dev/null || true
    
    # Install Neovim plugins
    log "Installing Neovim plugins..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' 2>/dev/null || true
    
    # Install Tmux plugins
    log "Installing Tmux plugins..."
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
    fi
    
    # Set proper permissions
    chmod -R 700 ~/.ssh 2>/dev/null || true
    
    log_success "Final setup completed!"
}

# Display completion message
show_completion() {
    print_banner
    log_success "🎉 Arch Linux CLI setup completed successfully!"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Run 'p10k configure' to setup Powerlevel10k theme"
    echo "3. Type 'dashboard' to see available tools"
    echo "4. Use 'browser <name>' to launch browsers"
    echo "5. Use 'pm' for package management shortcuts"
    echo "6. Use 'sysmaintenance' for system maintenance tasks"
    echo "7. Use 'security-check' for security status"
    echo ""
    echo -e "${YELLOW}Important directories:${NC}"
    echo "~/.config - Configuration files"
    echo "~/bin - Custom scripts"
    echo "~/Development - Development projects"
    echo ""
    echo -e "${YELLOW}Backup location:${NC}"
    echo "Your original configs are backed up at: $BACKUP_DIR"
    echo ""
    echo -e "${CYAN}Happy CLI computing on Arch Linux! 🚀${NC}"
    echo ""
}

# Main installation function
main() {
    print_banner
    
    echo -e "${YELLOW}Arch Linux CLI Complete Setup - Enhanced Edition${NC}"
    echo -e "${WHITE}This script will install and configure:${NC}"
    echo "• Essential CLI tools and utilities"
    echo "• Zsh with Oh-My-Zsh and Powerlevel10k"
    echo "• Tmux terminal multiplexer with plugins"
    echo "• Neovim with modern Lua configuration"
    echo "• File managers (Ranger, nnn)"
    echo "• Development tools and environments"
    echo "• System monitoring tools"
    echo "• Web browsers (CLI and GUI)"
    echo "• Security enhancements"
    echo "• Custom scripts and dashboard"
    echo ""
    
    read -rp "Continue with installation? (y/N): " -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
    
    # Create log file
    touch "$LOG_FILE"
    echo "Arch Linux CLI Setup Log" > "$LOG_FILE"
    echo "Started at: $(date)" >> "$LOG_FILE"
    echo "==========================================" >> "$LOG_FILE"
    
    check_root
    check_internet
    backup_configs
    
    log "Starting Arch Linux CLI setup..."
    
    update_system
    install_aur_helper
    install_essential_packages
    install_aur_packages
    install_programming_tools
    setup_zsh
    setup_tmux
    setup_neovim
    setup_ranger
    setup_dev_environment
    create_scripts
    create_dashboard
    setup_security
    final_setup
    
    show_completion
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
