#!/bin/bash

# =============================================================================
# ARCH LINUX CLI COMPLETE SETUP
# =============================================================================
# Script lengkap untuk setup Arch Linux CLI dengan semua tools dan konfigurasi
# Author: Arch CLI Setup
# Version: 1.0
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Art Banner
print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
     █████╗ ██████╗  ██████╗██╗  ██╗     ██████╗██╗     ██╗
    ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔════╝██║     ██║
    ███████║██████╔╝██║     ███████║    ██║     ██║     ██║
    ██╔══██║██╔══██╗██║     ██╔══██║    ██║     ██║     ██║
    ██║  ██║██║  ██║╚██████╗██║  ██║    ╚██████╗███████╗██║
    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝╚══════╝╚═╝
    
    ═══════════════════════════════════════════════════════════
                 ARCH LINUX CLI COMPLETE SETUP
    ═══════════════════════════════════════════════════════════
EOF
    echo -e "${NC}"
}

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Jangan jalankan script ini sebagai root!"
        exit 1
    fi
}

# Update system
update_system() {
    log "Updating system packages..."
    sudo pacman -Syu --noconfirm
    log_success "System updated successfully!"
}

# Install AUR helper (yay)
install_aur_helper() {
    if ! command -v yay &> /dev/null; then
        log "Installing AUR helper (yay)..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd ~
        rm -rf /tmp/yay
        log_success "AUR helper installed!"
    else
        log "AUR helper already installed!"
    fi
}

# Install essential packages
install_essential_packages() {
    log "Installing essential packages..."
    
    # Core system packages
    local core_packages=(
        "base-devel" "git" "curl" "wget" "unzip" "zip" "tar" "gzip"
        "htop" "btop" "neofetch" "tree" "less" "which" "man-db"
        "zsh" "tmux" "screen" "vim" "neovim" "emacs" "nano"
        "ranger" "nnn" "fzf" "ripgrep" "fd" "bat" "exa" "lsd"
        "ncdu" "tldr" "thefuck" "zoxide" "starship"
    )
    
    # Network tools
    local network_packages=(
        "openssh" "rsync" "aria2" "youtube-dl" "yt-dlp"
        "nmap" "netcat" "wireshark-cli" "tcpdump" "iperf3"
        "speedtest-cli" "bandwhich"
    )
    
    # Development tools
    local dev_packages=(
        "python" "python-pip" "nodejs" "npm" "go" "rust"
        "gcc" "clang" "cmake" "make" "gdb" "strace"
        "docker" "docker-compose" "podman"
    )
    
    # Media tools
    local media_packages=(
        "ffmpeg" "imagemagick" "cmus" "mpv" "vlc"
        "gimp" "blender" "obs-studio"
    )
    
    # System monitoring
    local monitor_packages=(
        "iotop" "nethogs" "powertop" "lsof" "pstree"
        "dstat" "glances" "iftop" "atop"
    )
    
    # Text processing
    local text_packages=(
        "jq" "yq" "xmlstarlet" "pandoc" "markdown"
        "grep" "sed" "awk" "sort" "uniq" "cut"
    )
    
    # Combine all packages
    local all_packages=("${core_packages[@]}" "${network_packages[@]}" 
                       "${dev_packages[@]}" "${media_packages[@]}" 
                       "${monitor_packages[@]}" "${text_packages[@]}")
    
    sudo pacman -S --noconfirm "${all_packages[@]}"
    log_success "Essential packages installed!"
}

# Install AUR packages
install_aur_packages() {
    log "Installing AUR packages..."
    
    local aur_packages=(
        "gotop-bin" "lazygit" "lazydocker" "bottom"
        "dust" "tokei" "hyperfine" "procs" "bandwhich"
        "broot" "lf" "fff" "navi" "tealdeer"
        "chezmoi" "antibody" "starship-bin"
    )
    
    yay -S --noconfirm "${aur_packages[@]}"
    log_success "AUR packages installed!"
}

# Install browsers
install_browsers() {
    log "Installing browsers..."
    
    # CLI browsers
    sudo pacman -S --noconfirm links lynx w3m
    
    # GUI browsers
    local browsers=(
        "firefox" "chromium" "google-chrome" "brave-bin"
    )
    
    for browser in "${browsers[@]}"; do
        if [[ "$browser" == "google-chrome" ]] || [[ "$browser" == "brave-bin" ]]; then
            yay -S --noconfirm "$browser"
        else
            sudo pacman -S --noconfirm "$browser"
        fi
    done
    
    log_success "Browsers installed!"
}

# Setup Zsh configuration
setup_zsh() {
    log "Setting up Zsh configuration..."
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # Install useful plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
    
    # Create .zshrc
    cat > ~/.zshrc << 'EOF'
# Powerlevel10k instant prompt
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

# Custom aliases
alias ll='exa -la --icons'
alias ls='exa --icons'
alias lt='exa --tree --icons'
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
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
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
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Zoxide (better cd)
eval "$(zoxide init zsh)"

# Starship prompt (alternative to powerlevel10k)
# eval "$(starship init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

    # Change default shell to zsh
    chsh -s $(which zsh)
    
    log_success "Zsh configuration completed!"
}

# Setup Tmux configuration
setup_tmux() {
    log "Setting up Tmux configuration..."
    
    cat > ~/.tmux.conf << 'EOF'
# Tmux configuration
# Prefix key
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

# Resize panes
bind H resize-pane -L 5
bind J resize-pane -D 5
bind K resize-pane -U 5
bind L resize-pane -R 5

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

# Setup Neovim configuration
setup_neovim() {
    log "Setting up Neovim configuration..."
    
    mkdir -p ~/.config/nvim
    
    cat > ~/.config/nvim/init.vim << 'EOF'
" Neovim configuration
set number
set relativenumber
set expandtab
set shiftwidth=4
set tabstop=4
set smartindent
set wrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set scrolloff=8
set noshowmode
set completeopt=menuone,noinsert,noselect
set colorcolumn=80
set signcolumn=yes
set cmdheight=2
set updatetime=50
set shortmess+=c

" Key mappings
let mapleader = " "
nnoremap <leader>pv :Vex<CR>
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <C-p> :Files<CR>
nnoremap <leader>pf :Files<CR>
nnoremap <C-j> :cnext<CR>
nnoremap <C-k> :cprev<CR>
nnoremap <leader>j :lprev<CR>
nnoremap <leader>k :lnext<CR>

" Window navigation
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" Terminal mode
tnoremap <Esc> <C-\><C-n>
nnoremap <leader>t :terminal<CR>

" Basic autocommands
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 40})
augroup END

" File type specific settings
autocmd FileType html,css,javascript,typescript,json setlocal shiftwidth=2 tabstop=2
autocmd FileType python setlocal shiftwidth=4 tabstop=4
autocmd FileType go setlocal shiftwidth=4 tabstop=4 noexpandtab

" Color scheme
colorscheme desert
EOF

    log_success "Neovim configuration completed!"
}

# Create useful scripts
create_scripts() {
    log "Creating useful scripts..."
    
    mkdir -p ~/bin
    
    # System info script
    cat > ~/bin/sysinfo << 'EOF'
#!/bin/bash
echo -e "\033[1;36m=== SYSTEM INFORMATION ===\033[0m"
echo -e "\033[1;32mHostname:\033[0m $(hostname)"
echo -e "\033[1;32mUptime:\033[0m $(uptime -p)"
echo -e "\033[1;32mKernel:\033[0m $(uname -r)"
echo -e "\033[1;32mArchitecture:\033[0m $(uname -m)"
echo -e "\033[1;32mCPU:\033[0m $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo -e "\033[1;32mMemory:\033[0m $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo -e "\033[1;32mDisk:\033[0m $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo -e "\033[1;32mLoad Average:\033[0m $(cat /proc/loadavg | cut -d' ' -f1-3)"
echo ""
neofetch
EOF

    # Package management script
    cat > ~/bin/pm << 'EOF'
#!/bin/bash
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

    # Network tools script
    cat > ~/bin/nettools << 'EOF'
#!/bin/bash
case "$1" in
    "scan")
        nmap -sn 192.168.1.0/24
        ;;
    "ports")
        sudo netstat -tulpn
        ;;
    "speed")
        speedtest-cli
        ;;
    "ip")
        echo "Local IP: $(ip route get 1.1.1.1 | awk '{print $7; exit}')"
        echo "Public IP: $(curl -s ipinfo.io/ip)"
        ;;
    "wifi")
        nmcli dev wifi list
        ;;
    *)
        echo "Network Tools"
        echo "Usage: nettools <command>"
        echo ""
        echo "Commands:"
        echo "  scan    - Scan local network"
        echo "  ports   - Show open ports"
        echo "  speed   - Internet speed test"
        echo "  ip      - Show IP addresses"
        echo "  wifi    - Show WiFi networks"
        ;;
esac
EOF

    chmod +x ~/bin/*
    
    # Add ~/bin to PATH
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    
    log_success "Useful scripts created!"
}

# Setup file manager (Ranger) configuration
setup_ranger() {
    log "Setting up Ranger configuration..."
    
    mkdir -p ~/.config/ranger
    
    # Generate default config
    ranger --copy-config=all
    
    # Customize rc.conf
    cat >> ~/.config/ranger/rc.conf << 'EOF'

# Custom settings
set preview_images true
set use_preview_script true
set preview_files true
set preview_directories true
set collapse_preview true
set show_hidden false
set colorscheme default

# Custom key bindings
map DD shell mv %s ~/.local/share/Trash/files/
map <C-f> fzf_select
map <C-l> redraw_window

# Image preview
set preview_images_method ueberzug
EOF

    log_success "Ranger configuration completed!"
}

# Create custom CLI dashboard
create_dashboard() {
    log "Creating CLI dashboard..."
    
    cat > ~/bin/dashboard << 'EOF'
#!/bin/bash
clear

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ASCII Art
echo -e "${CYAN}"
cat << "EOF"
    ╔══════════════════════════════════════════════════════════╗
    ║                    ARCH CLI DASHBOARD                    ║
    ╚══════════════════════════════════════════════════════════╝
EOF

# System info section
echo -e "${WHITE}┌─ SYSTEM INFO ─────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}Host:${NC} $(hostname) | ${GREEN}User:${NC} $(whoami)"
echo -e "${GREEN}Uptime:${NC} $(uptime -p)"
echo -e "${GREEN}Load:${NC} $(cat /proc/loadavg | cut -d' ' -f1-3)"
echo -e "${GREEN}Memory:${NC} $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo -e "${WHITE}└───────────────────────────────────────────────────────────┘${NC}"

# Available tools
echo -e "${WHITE}┌─ AVAILABLE TOOLS ─────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}System:${NC} htop, btop, neofetch, sysinfo"
echo -e "${YELLOW}Files:${NC} ranger, nnn, lf, tree, ls, ll"
echo -e "${YELLOW}Network:${NC} nettools, speedtest-cli, nmap"
echo -e "${YELLOW}Dev:${NC} nvim, git, docker, lazygit, lazydocker"
echo -e "${YELLOW}Browsers:${NC} browser firefox|chrome|brave|links|lynx"
echo -e "${YELLOW}Package:${NC} pm install|remove|update|search"
echo -e "${WHITE}└───────────────────────────────────────────────────────────┘${NC}"

# Quick commands
echo -e "${WHITE}┌─ QUICK COMMANDS ──────────────────────────────────────────┐${NC}"
echo -e "${CYAN}tmux${NC}        - Terminal multiplexer"
echo -e "${CYAN}ranger${NC}      - File manager"
echo -e "${CYAN}lazygit${NC}     - Git UI"
echo -e "${CYAN}btop${NC}        - System monitor"
echo -e "${CYAN}neofetch${NC}    - System info"
echo -e "${WHITE}└───────────────────────────────────────────────────────────┘${NC}"

echo ""
EOF

    chmod +x ~/bin/dashboard
    
    log_success "CLI dashboard created!"
}

# Final setup and cleanup
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
    
    # Update locate database
    sudo updatedb 2>/dev/null || true
    
    log_success "Final setup completed!"
}

# Main installation function
main() {
    print_banner
    
    echo -e "${YELLOW}Arch Linux CLI Complete Setup${NC}"
    echo -e "${WHITE}This script will install and configure:${NC}"
    echo "• Essential CLI tools and utilities"
    echo "• Zsh with Oh-My-Zsh and Powerlevel10k"
    echo "• Tmux terminal multiplexer"
    echo "• Neovim text editor"
    echo "• File managers (Ranger, nnn)"
    echo "• Development tools"
    echo "• System monitoring tools"
    echo "• Web browsers (CLI and GUI)"
    echo "• Custom scripts and dashboard"
    echo ""
    
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
    
    check_root
    
    log "Starting Arch Linux CLI setup..."
    
    update_system
    install_aur_helper
    install_essential_packages
    install_aur_packages
    install_browsers
    setup_zsh
    setup_tmux
    setup_neovim
    setup_ranger
    create_scripts
    create_dashboard
    final_setup
    
    print_banner
    log_success "🎉 Arch Linux CLI setup completed successfully!"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Run 'p10k configure' to setup Powerlevel10k theme"
    echo "3. Type 'dashboard' to see available tools"
    echo "4. Use 'browser <name>' to launch browsers"
    echo "5. Use 'pm' for package management shortcuts"
    echo ""
    echo -e "${CYAN}Happy CLI computing on Arch Linux! 🚀${NC}"
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
