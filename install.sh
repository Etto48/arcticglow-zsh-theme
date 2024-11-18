#!/bin/bash

get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

echo_error() {
    echo -e "\033[0;31mError: $1\033[0m"
}

echo_warning() {
    echo -e "\033[0;33mWarning: $1\033[0m"
}

echo_info() {
    echo -e "\033[0;32mInfo: $1\033[0m"
}

sed_portable() {
    local os=$1
    if [[ $os == "MACOS" ]]; then
        sed -i '' "$2" $3
    else
        sed -i "$2" $3
    fi
}

get_os_name() {
    local os os_name
    os=$(uname)
    os_name="UNKNOWN($os)"
    case $os in
        "Darwin")
            os_name="MACOS"
            ;;
        "Linux")
            os_name="LINUX"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case $ID in
                    "ubuntu")
                        os_name="UBUNTU"
                        ;;
                    "fedora")
                        os_name="FEDORA"
                        ;;
                    "centos")
                        os_name="CENTOS"
                        ;;
                    "arch")
                        os_name="ARCH"
                        ;;
                    "opensuse")
                        os_name="OPENSUSE"
                        ;;
                    "debian")
                        os_name="DEBIAN"
                        ;;
                    "gentoo")
                        os_name="GENTOO"
                        ;;
                    "alpine")
                        os_name="ALPINE"
                        ;;
                    *)
                        ;;
                esac
            fi
            ;;
        *)
            ;;
    esac
    echo $os_name
}

THEME_NAME="arcticglow"

INSTALL_PATH=$(get_abs_filename $0)
THEME_PATH=$(dirname $INSTALL_PATH)/$THEME_NAME.zsh-theme

ZSHRC_PATH=$HOME/.zshrc
TARGET_DIR=$HOME/.oh-my-zsh/themes/
TARGET_FILE=$TARGET_DIR/$THEME_NAME.zsh-theme

if [ ! -f $THEME_PATH ]; then
    echo_error "$THEME_PATH not found."
    echo "Please make sure you have cloned the repository correctly."
    exit 1
fi

if [ ! -f $ZSHRC_PATH ]; then
    echo_error "$ZSHRC_PATH not found."
    echo "Please make sure you have installed zsh correctly."
    exit 1
fi

if [ ! -d $TARGET_DIR ]; then
    echo_error "$TARGET_DIR not found."
    echo "Please make sure you have installed oh-my-zsh correctly."
    exit 1
fi

echo "Copying theme to $TARGET_DIR"
cp $THEME_PATH $TARGET_DIR

OS_NAME=$(get_os_name)
if [[ $OS_NAME == "UNKNOWN"* ]]; then
    echo_warning "Unknown OS detected: $OS_NAME"
    echo "You can export the environment variable ARCTICGLOW_UNKNOWN_OS_SYMBOL to set the os symbol."
    OS_NAME="UNKNOWN"
else
    echo Detected OS: $OS_NAME
fi

echo "Setting theme in $ZSHRC_PATH"
sed_portable $OS_NAME 's/^ZSH_THEME=.*/ZSH_THEME="arcticglow"/' $ZSHRC_PATH

echo "Configuring theme in $ZSHRC_PATH"

if grep -q "export VIRTUAL_ENV_DISABLE_PROMPT" $ZSHRC_PATH; then
    echo "Detected VIRTUAL_ENV_DISABLE_PROMPT in $ZSHRC_PATH"
else
    echo "Setting VIRTUAL_ENV_DISABLE_PROMPT in $ZSHRC_PATH"
    echo "" >> $ZSHRC_PATH
    echo "# Override the default python virtualenv prompt" >> $ZSHRC_PATH
    echo "export VIRTUAL_ENV_DISABLE_PROMPT=1" >> $ZSHRC_PATH
fi

sed_portable $OS_NAME "s/###PROMPT_OS###/\$ARCTICGLOW_${OS_NAME}_SYMBOL/" $TARGET_FILE

echo "Successfullly installed $THEME_NAME."
echo_info "Please restart your terminal to see the changes."