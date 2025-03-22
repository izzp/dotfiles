#!/bin/bash

# * Description: 初始化服务器的脚本，包括系统更新、安装软件、设置主机名、配置 SSH 和 fail2ban 等操作。
# * Author: ZhaoZhipeng
# * Email: meetzzp@gmail.com
# * Date Created: 2024-04-22
# * Date Updated: 2024-04-23

# 检查是否以 root 用户身份运行
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# 全局变量，用于存储用户名
global_username=""

# 设置颜色
GREEN='\033[0;32m' # 绿色
YELLOW='\033[1;33m' # 黄色
RED='\033[0;31m' # 红色
NC='\033[0m' # 恢复默认颜色

# 打印消息的函数
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}\n##############################################"
    echo -e "# ${message}"
    echo -e "##############################################\n${NC}"
}

# 更新系统的函数
update_system() {
    print_message $YELLOW "开始更新系统"
    apt update && apt full-upgrade -y && apt autoremove -y
    print_message $GREEN "更新系统完成"
}

# 安装必备软件的函数
install_software() {
    print_message $YELLOW "开始安装必备软件"
    
    # 安装基础开发工具
    print_message $YELLOW "安装基础开发工具..."
    apt install -y build-essential git curl wget net-tools
    print_message $GREEN "基础开发工具安装完成"
    
    # 安装系统监控软件
    print_message $YELLOW "安装系统监控软件..."
    apt install -y neofetch glances htop iftop iotop bmon
    print_message $GREEN "系统监控软件安装完成"
    
    # 安装常用文本工具
    print_message $YELLOW "安装常用文本工具..."
    apt install -y vim jq
    print_message $GREEN "常用文本工具安装完成"
    
    # 安装常用终端复用工具
    print_message $YELLOW "安装常用终端复用工具..."
    apt install -y tmux
    print_message $GREEN "常用终端复用工具安装完成"
    
    # 安装必备软件
    print_message $YELLOW "安装其他必备软件..."
    apt install sudo ncdu zsh ufw fail2ban rsyslog -y
    print_message $GREEN "其他必备软件安装完成"
    print_message $GREEN "安装必备软件完成"
}

# 设置主机名的函数
set_hostname() {
    print_message $YELLOW "开始设置主机名"
    read -e -p "输入主机名: " hostname
    hostnamectl set-hostname $hostname
    print_message $GREEN "设置主机名完成"
}

# 添加新用户并赋予 sudo 权限的函数
add_user() {
    print_message $YELLOW "开始添加新用户并赋予 sudo 权限"
    read -e -p "输入用户名: " username
    global_username="$username"
    adduser $username
    echo "$username  ALL=(ALL)    ALL" >> /etc/sudoers
    print_message $GREEN "添加新用户并赋予 sudo 权限完成"
}

# 检查用户是否存在的函数
check_user_exists() {
    local username=$1
    if [ ! -d "/home/$username" ]; then
        print_message $RED "错误：用户 $username 不存在"
        return 1
    fi
    return 0
}

# 获取用户名的函数
get_username() {
    if [ -z "$global_username" ]; then
        read -e -p "输入用户名: " username
        global_username="$username"
    else
        username="$global_username"
        echo "使用存储的用户名: $username"
    fi
    echo $username
}

# 为新用户添加登录公钥的函数
add_ssh_key() {
    print_message $YELLOW "开始为新用户添加登录公钥"
    username=$(get_username)
    read -e -p "输入 SSH 公钥内容: " ssh_key_content
    mkdir -p /home/$username/.ssh
    echo "$ssh_key_content" >> /home/$username/.ssh/authorized_keys
    chown -R $username:$username /home/$username/.ssh
    chmod 700 /home/$username/.ssh
    chmod 600 /home/$username/.ssh/authorized_keys
    print_message $GREEN "为新用户添加登录公钥完成"
}

# 配置 SSH 以提高安全性的函数
configure_ssh() {
    print_message $YELLOW "开始配置 SSH 以提高安全性"
    read -e -p "输入要使用的 SSH 端口号 (默认为 2233): " ssh_port
    ssh_port=${ssh_port:-2233}  # 如果未提供端口号，默认为 2233
    sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
    sed -i "s/#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
    sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
    systemctl restart sshd
    print_message $GREEN "配置 SSH 完成"
}

# 配置 Oh-my-zsh 的函数
configure_ohmyzsh() {
    print_message $YELLOW "开始配置 Oh-my-zsh"
    username=$(get_username)
    check_user_exists $username || return 1
    # 检查是否已经存在 .oh-my-zsh 文件夹
    if [ -d "/home/$username/.oh-my-zsh" ]; then
        # 如果存在，则删除
        sudo -u $username rm -rf /home/$username/.oh-my-zsh
        print_message $YELLOW "已删除已存在的 .oh-my-zsh 文件夹"
    fi
    # 克隆 Oh My Zsh 仓库
    sudo -u $username git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /home/$username/oh-my-zsh

    # 执行 Oh My Zsh 安装脚本
    sudo -u $username sh /home/$username/oh-my-zsh/tools/install.sh --unattended
    # 检查用户的 .zshrc 文件是否存在，如果不存在，则创建一个新的
    if [ ! -f "/home/$username/.zshrc" ]; then
        sudo -u $username touch /home/$username/.zshrc
    fi
    # 检查是否已经存在 zsh-autosuggestions 文件夹
    if [ ! -d "/home/$username/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        # 安装 zsh-autosuggestions 插件
        sudo -u $username git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /home/$username/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    else
        print_message $YELLOW "警告：zsh-autosuggestions 文件夹已存在，将跳过克隆步骤"
    fi
    # 检查是否已经存在 zsh-syntax-highlighting 文件夹
    if [ ! -d "/home/$username/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        # 安装 zsh-syntax-highlighting 插件
        sudo -u $username git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$username/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    else
        print_message $YELLOW "警告：zsh-syntax-highlighting 文件夹已存在，将跳过克隆步骤"
    fi
    # 配置 Zshrc 文件，启用插件
    sudo -u $username sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /home/$username/.zshrc
    # 设置 zsh 为默认 shell
    chsh -s $(which zsh) $username
    # 重新加载用户的 .zshrc 文件
    sudo -u $username zsh -c ". /home/$username/.zshrc"
    print_message $GREEN "配置 Oh-my-zsh完成"
}

# 配置 Powerlevel10k 的函数
configure_powerlevel10k() {
    print_message $YELLOW "开始配置 Powerlevel10k"
    username=$(get_username)
    check_user_exists $username || return 1
    # 检查是否已经存在 .oh-my-zsh 文件夹
    if [ -d "/home/$username/.oh-my-zsh" ]; then
        # 如果存在，则继续
        # 克隆 powerlevel10k 仓库
        print_message $YELLOW "克隆 powerlevel10k 仓库..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$username/.oh-my-zsh/custom/themes/powerlevel10k
        print_message $YELLOW "配置 .zshrc ..."
        sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/zhao/.zshrc
        # 重新加载用户的 .zshrc 文件
        sudo -u $username zsh -c ". /home/$username/.zshrc"
        print_message $GREEN "配置powerlevel10k完成"
    else
        print_message $RED "无法配置，不存在 oh-my-zsh"
    fi
}

# 主函数，执行所有步骤
main() {
    echo -e "${YELLOW}请选择要执行的操作：${NC}"
    echo -e "  ${YELLOW}1.${NC} 执行所有步骤"
    echo -e "  ${YELLOW}2.${NC} 更新系统"
    echo -e "  ${YELLOW}3.${NC} 安装必备软件"
    echo -e "  ${YELLOW}4.${NC} 设置主机名"
    echo -e "  ${YELLOW}5.${NC} 添加新用户并赋予 sudo 权限"
    echo -e "  ${YELLOW}6.${NC} 配置 SSH"
    echo -e "  ${YELLOW}7.${NC} 为新用户添加登录公钥"
    echo -e "  ${YELLOW}8.${NC} 配置 Oh-my-zsh"
    echo -e "  ${YELLOW}9.${NC} 配置 Powerlevel10k"
    echo -e "  ${YELLOW}10.${NC} 退出"

    read -p "请输入选项编号: " choice

    case $choice in
        1) 
            # 执行所有步骤
            update_system
            install_software
            if ask "是否要设置主机名？"; then
                set_hostname
            fi
            if ask "是否要添加新用户并赋予 sudo 权限？"; then
                add_user
            fi
            if ask "是否要配置 SSH？"; then
                configure_ssh
            fi
            if ask "是否要为新用户添加登录公钥？"; then
                add_ssh_key
            fi
            if ask "是否要配置 Oh-my-zsh？"; then
                configure_ohmyzsh
            fi
            if ask "是否要配置 Powerlevel10k？"; then
                configure_powerlevel10k
            fi
            print_message $GREEN "初始化完成！"
            ;;
        2) update_system;;
        3) install_software;;
        4) set_hostname;;
        5) add_user;;
        6) configure_ssh;;
        7) add_ssh_key;;
        8) configure_ohmyzsh;;
        9) configure_powerlevel10k;;
        10) exit;;
        *) echo -e "${RED}无效的选项，请重新输入${NC}";;
    esac
}

# 提示用户是否要执行当前函数
ask() {
    local prompt=$1
    echo -e "${YELLOW}"
    echo -e "##############################################"
    echo -e "# ${prompt} (y/n)"
    echo -e "##############################################"
    echo -e "${NC}"
    read -p "" answer
    case $answer in
        [yY]*) return 0 ;;
        *) return 1 ;;
    esac
}

# 执行主函数
main
