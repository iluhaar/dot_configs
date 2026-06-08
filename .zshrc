# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=01;34:ow=01;34:st=01;34:ex=01;32'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$(npm config get prefix)/bin:$PATH"

# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Function to convert a video file (e.g., MP4) to a GIF using ffmpeg
# The GIF will be saved in a subdirectory within './gif/' named after today's date (yyyy-MM-dd).
#
# Usage:
#   convert2gif <inputFileName> [-c|--copy]
#
# Arguments:
#   inputFileName: The path to the input video file (e.g., myvideo.mp4).
#   -c, --copy:    Optional flag. If present, the path to the generated GIF
#                  will be copied to the clipboar:d. Requires 'xclip' to be installed.
function convert2gif() {
    local inputFileName=""
    local copyToClipboard=false
    local customName=""
    local outputFileName
    local todayFolder
    local dateFolderPath
    local outputFilePath

    # Check if ffmpeg is installed
    if ! command -v ffmpeg &> /dev/null; then
        echo "Error: ffmpeg is not installed. Please install it to use this function."
        return 1
    fi

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--copy)
                copyToClipboard=true
                shift
                ;;
            -n|--name)
                customName="$2"
                if [[ -z "$customName" ]]; then
                    echo "Error: --name requires a value."
                    return 1
                fi
                shift 2
                ;;
            -*)
                echo "Unknown option: $1"
                return 1
                ;;
            *)
                if [[ -z "$inputFileName" ]]; then
                    inputFileName="$1"
                    shift
                else
                    echo "Error: Multiple input files not supported."
                    return 1
                fi
                ;;
        esac
    done

    if [[ -z "$inputFileName" ]]; then
        echo "Usage: convert2gif <inputFileName> [-c|--copy] [-n|--name <customName>]"
        return 1
    fi

    # Check if the input file exists
    if [[ ! -f "$inputFileName" ]]; then
        echo "Error: File '$inputFileName' not found."
        return 1
    fi

    # Define the output GIF file name
    if [[ -n "$customName" ]]; then
        outputFileName="${customName}.gif"
    else
        outputFileName="${inputFileName:t:r}.gif"
    fi

    # Get today's date in yyyy-MM-dd format
    todayFolder=$(date +%Y-%m-%d)
    dateFolderPath="./gif/$todayFolder"
    mkdir -p "$dateFolderPath"
    outputFilePath="$dateFolderPath/$outputFileName"

    echo "Converting '$inputFileName' to GIF..."
    echo "Output will be saved to: '$outputFilePath'"

    ffmpeg -i "$inputFileName" -vf "fps=10,scale=1200:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$outputFilePath"

    if [[ $? -eq 0 ]]; then
        echo "Conversion complete: '$outputFilePath'"
    else
        echo "Error: FFmpeg conversion failed."
        return 1
    fi
}


cht() {
  curl -s "cheat.sh/$1" | less -R
}

dev() {
  if [ -f "pnpm-lock.yaml" ]; then
    pnpm run dev "$@"
  elif [ -f "yarn.lock" ]; then
    yarn dev "$@"
  elif [ -f "package-lock.json" ]; then
    npm run dev "$@"
  else
    echo "No lockfile found (pnpm, yarn, or npm)."
    return 1
  fi
}

install() {
  if [ -f "pnpm-lock.yaml" ]; then
    pnpm install "$@"
  elif [ -f "yarn.lock" ]; then
    yarn install "$@"
  elif [ -f "package-lock.json" ]; then
    npm install "$@"
  else
    echo "No lockfile found (pnpm, yarn, or npm)."
    return 1
  fi
}

build() {
    if [ -f "pnpm-lock.yaml" ]; then
        pnpm build "$@"
    elif [ -f "yarn.lock" ]; then
        yarn build "$@"
    elif [ -f "package-lock.json" ]; then
        npm run build "$@"
    else
        echo "No lockfile found (pnpm, yarn, or npm)."
        return 1
    fi
}

# === SSH Agent Setup ===
# Start the SSH agent if it's not already running and add SSH keys
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/work
fi
# === End SSH Agent Setup ===
alias c='cursor'
alias work='/home/illia/ilya/work/composable'
alias ccp='pwd | tr -d "\n" | xclip -selection clipboard'
alias gt='git'
alias startVpn='sudo openvpn --config ~/Downloads/ilya.rudyi.ovpn'
alias clearDocker='sudo docker system prune -a --volumes -f'
alias ca='cursor-agent'
alias lz='lazygit'
alias oc='opencode'
alias j='z'
alias cc='claude'

# bun completions
[ -s "/home/illia/.bun/_bun" ] && source "/home/illia/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/home/illia/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# zoxide
eval "$(zoxide init zsh)"

# opencode
export PATH=/home/illia/.opencode/bin:$PATH

killPort() {
    local port=$1
    if [ -z "$port" ]; then
        echo "Usage: killPort <port>"
        return 1
    fi
    kill -9 $(lsof -t -i:$port)
}

# Update Cursor from the newest downloaded .deb (version-aware)
update-cursor() {
  local DEB_DIR="$HOME/Downloads"
  local DEB_FILE

  DEB_FILE=$(ls "$DEB_DIR"/cursor_*.deb 2>/dev/null | sort -V | tail -n 1)

  if [[ -z "$DEB_FILE" ]]; then
    echo "❌ No cursor-*.deb found in $DEB_DIR"
    return 1
  fi

  echo "📦 Latest package detected:"
  echo "   $DEB_FILE"

  if dpkg -l cursor &>/dev/null; then
    echo "🧹 Removing old Cursor version..."
    sudo apt remove -y cursor || return 1
  fi

  echo "⬆️ Installing Cursor..."
  sudo apt install -y "$DEB_FILE" || return 1

  echo "🛠 Fixing dependencies..."
  sudo apt -f install -y

  echo "✅ Cursor updated successfully"
}

compress-video() {
  if [[ -z "$1" ]]; then
    echo "usage: compress-video <file>" >&2
    return 1
  fi
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "compress-video: not a file: $f" >&2
    return 1
  fi
  local dir="${f:h}"
  local base="${f:t:r}"
  local ext="${f:e}"
  [[ -n "$ext" ]] || ext="mp4"
  local out="${dir}/${base}-compressed.${ext}"
  ffmpeg -i "$f" -c:v libx265 -crf 28 "$out"
}
