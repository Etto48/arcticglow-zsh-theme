#!/bin/bash

get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

get_os_name() {
    local os os_name
    os=$(uname)
    os_name="LINUX"
    case $os in
        "Darwin")
            os_name="MAC"
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
                        os_name="LINUX"
                        ;;
                esac
            fi
            ;;
        *)
            os_name="UNKNOWN"
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
    echo "Error: $THEME_PATH not found."
    echo "Please make sure you have cloned the repository correctly."
    exit 1
fi

if [ ! -f $ZSHRC_PATH ]; then
    echo "Error: $ZSHRC_PATH not found."
    echo "Please make sure you have installed zsh correctly."
    exit 1
fi

if [ ! -d $TARGET_DIR ]; then
    echo "Error: $TARGET_DIR not found."
    echo "Please make sure you have installed oh-my-zsh correctly."
    exit 1
fi

echo "Copying theme to $TARGET_DIR"
cp $THEME_PATH $TARGET_DIR

echo "Setting theme in $ZSHRC_PATH"
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="arcticglow"/' $ZSHRC_PATH

echo "Configuring theme in $ZSHRC_PATH"
OS_NAME=$(get_os_name)
if [ $OS_NAME == "UNKNOWN" ]; then
    echo "Warning: Unknown OS detected."
    exit 1
fi

if grep -q "export VIRTUAL_ENV_DISABLE_PROMPT" $ZSHRC_PATH; then
    echo "Detected VIRTUAL_ENV_DISABLE_PROMPT in $ZSHRC_PATH"
else
    echo "Setting VIRTUAL_ENV_DISABLE_PROMPT in $ZSHRC_PATH"
    echo "# Override the default python virtualenv prompt" >> $ZSHRC_PATH
    echo "export VIRTUAL_ENV_DISABLE_PROMPT=1" >> $ZSHRC_PATH
fi

echo Detected OS: $OS_NAME

sed -i "s/###PROMPT_OS###/\$ARCTICGLOW_${OS_NAME}_SYMBOL/" $TARGET_FILE

echo "Successfullly installed $THEME_NAME."
echo "Please restart your terminal to see the changes."