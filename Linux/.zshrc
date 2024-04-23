# * Description: zsh configuration file / Oh-My-Zsh
# * Author: ZhaoZhipeng
# * Email: meetzzp@gmail.com
# * Date Created: 2022-12-06
# * Data Updated: 2024-04-23

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
