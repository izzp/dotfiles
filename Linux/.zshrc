# * Description: zsh configuration file / Oh-My-Zsh
# * Author: ZhaoZhipeng
# * Email: meetzzp@gmail.com
# * Date Created: 2022/12/6
# * Data Updated: 2023/03/08

# Powerlevel10k part begin
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Powerlevel10k part end


# oh-my-zsh installation path 
export ZSH=$HOME"/.oh-my-zsh"

# 获取系统类型
if [[ `uname -s` == "Linux" ]]; then
    os_type=$(cat /etc/os-release | grep -i '^NAME')

    # A. Debian
    if [[ $os_type == *"Debian"* ]]; then
        os_type="Debian"

    # B. RedHat
    elif [[ $os_type == *"Red Hat Enterprise Linux"* ]]; then
        os_type="RedHat"

    # C. Fedora
    elif [[ $os_type == *"Fedora"* ]]; then
        os_type="Fedora"

    # D. CentOS
    elif [[ $os_type == *"CentOS"* ]]; then
        os_type="CentOS"

    # E. Ubuntu
    else [[ $os_type == *"Ubuntu"* ]]
        os_type="Ubuntu"
    fi
elif [[ `uname -s` == "Darwin" ]]; then
    os_type="macOS"
else
    os_type="unknown"
fi

# zsh 主题，默认的是 robbyrussell
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# 自动补全大小写敏感设置为 false
CASE_SENSITIVE="false"

# 开启zsh自动更新
export UPDATE_ZSH_DAYS=1
DISABLE_AUTO_UPDATE="true"

# 开启自动纠正错误
ENABLE_CORRECTION="true"

# plugins part BEGIN
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
plugins=(
    git
    sudo
    tmux
    docker
    extract
    z
    zsh-syntax-highlighting
    zsh-autosuggestions
    colored-man-pages
)
# plugins part END

# 启用 oh-my-zsh 配置
source $ZSH/oh-my-zsh.sh


# alias
alias ll='ls -lFh'
alias la='ls -a'
alias l='ls -1A'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# Terminal Color BEGIN
LS_COLORS=$LS_COLORS:'di=0;36' ; export LS_COLORS
# Terminal Color  END



# UPDATE 设置 BEGIN
# 系统更新，不区分系统
function os-update () {
    # (1) 更新系统包管理器下的软件
    if [[ $os_type = "macOS" ]]; then
        echo "   Step brew update"
        brew update
        brew upgrade
    elif [[ $os_type == "Ubuntu" ]]; then
            echo '   Step  正在更新' $os_type
            sudo apt update
            apt list --upgradable
            sudo apt upgrade
    elif [[ $os_type == "Debian" ]]; then
            echo '   Step 正在更新' $os_type
            sudo apt update
            apt list --upgradable
            sudo apt upgrade
    elif [[ $os_type == "RedHat" || $os_type == "CentOS" || $os_type == "Fedora" ]]; then
            echo '   Step 3/3 正在更新' $os_type
            sudo yum update
    elif [[ $os_type == "TrueNAS_SCALE" ]]; then
            echo '   Step 3/3 TrueNAS 请手动更新'
    else
        echo "系统类型无法识别，无法更新系统软件."
    fi
    echo "更新完成！"
}
# UPDATE 设置 END


# Powerlevel10k part begin
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# Powerlevel10k part end

# Jenv part begin
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
# Jenv part end

# nvm part end
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  
# nvm part begin
