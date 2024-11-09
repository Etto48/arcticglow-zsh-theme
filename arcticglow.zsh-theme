# Disclaimer: This theme is a modified version of the agnoster theme (https://gist.github.com/3712874)

# Palette
BASE_COLOR='#ffffff'
TEXT_COLOR='#000000'
ACCENT_COLOR='#7764d8'
VCS_UNTRACKED_COLOR='#ff908f'
VCS_DIRTY_COLOR='#ffd666'
VCS_CLEAN_COLOR='#91ffb2'
ERROR_COLOR='#ff5940'
ROOT_COLOR=$VCS_DIRTY_COLOR
BACKGROUND_JOBS_COLOR='#5ec4ff'



# Symbols
SEGMENT_SEPARATOR="\ue0b0" # 
PROMPT_START="\ue0b6" # 
UBUNTU_SYMBOL="\ue73a" # 
FEDORA_SYMBOL="\uef46" # 
CENTOS_SYMBOL="\uef3d" # 
ARCH_SYMBOL="\uf303" # 
OPENSUSE_SYMBOL="\uf314" # 
DEBIAN_SYMBOL="\ue77d" # 
GENTOO_SYMBOL="\uf30d" # 
ALPINE_SYMBOL="\uf300" # 
MACOS_SYMBOL="\uf179" # 
LINUX_SYMBOL="\uf17c" # 
WINDOWS_SYMBOL="\uf17a" # 
BRANCH_SYMBOL="\ue0a0" # 
BRANCH_AHEAD_AND_BEHIND_SYMBOL="\u21c5" # ⇅
BRANCH_AHEAD_SYMBOL="\u21b1" # ↱
BRANCH_BEHIND_SYMBOL="\u21b0" # ↰
BISECT_SYMBOL="\uf002" # 
MERGE_SYMBOL="\uebab" # 
REBASE_SYMBOL="\uf17f" # 
COMMIT_HASH_SYMBOL="\uf412" # 
TAG_SYMBOL="\uf02b" # 
STAGED_SYMBOL="\u271a" # ✚
UNSTAGED_SYMBOL="\uf444" # 
PYTHON_SYMBOL="\ue73c" # 
ERROR_SYMBOL="\uf06a" # 
ROOT_SYMBOL="\uf0e7" # 
BACKGROUND_JOBS_SYMBOL="\uf013" # 
MERCURIAL_SYMBOL="\uf223" # 


CURRENT_BG='NONE'
CURRENT_FG=$ACCENT_COLOR
EVEN_SEGMENT=1

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
}

skip_segment() {
  (( EVEN_SEGMENT = 1 - EVEN_SEGMENT ))
  return 0
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  if [[ $EVEN_SEGMENT == 0 ]]; then
    bg_inner=$ACCENT_COLOR
    fg_inner=$BASE_COLOR
  else
    fg_inner=$ACCENT_COLOR
    bg_inner=$BASE_COLOR
  fi
  skip_segment

  if [[ -n $2 && $2 != 'NONE' ]]; then
    bg_inner=$2
  fi
  if [[ -n $3 && $3 != 'NONE' ]]; then
    fg_inner=$3
  fi
  bg="%K{$bg_inner}"
  fg="%F{$fg_inner}"

  if [[ $CURRENT_BG != 'NONE' && $CURRENT_BG != $bg_inner ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    if [[ $CURRENT_BG == 'NONE' ]]; then
      fg="%F{$bg_inner}"
      fg_2="%F{$fg_inner}"
      echo -n "%{%k$fg%}$PROMPT_START%{$fg_2$bg%}"
    else
      echo -n " %{$fg%}"
    fi
  fi
  CURRENT_BG=$bg_inner
  CURRENT_FG=$fg_inner
  [[ -n $1 ]] && echo -n $1
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    if [[ -n "$SSH_CLIENT" ]]; then
      hostname="@%m"
    else
      hostname=""
    fi
    prompt_segment "%(!.%{%F{yellow}%}.)%n$hostname"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$BRANCH_SYMBOL
  }
  local ref dirty mode repo_path

   if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(command git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref="$TAG_SYMBOL $(command git describe --exact-match --tags HEAD 2> /dev/null)" || \
    ref="$COMMIT_HASH_SYMBOL $(command git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      bg=$VCS_DIRTY_COLOR
      fg=$TEXT_COLOR
    else
      bg=$VCS_CLEAN_COLOR
      fg=$TEXT_COLOR
    fi

    local ahead behind
    ahead=$(command git log --oneline @{upstream}.. 2>/dev/null)
    behind=$(command git log --oneline ..@{upstream} 2>/dev/null)
    if [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$BRANCH_AHEAD_AND_BEHIND_SYMBOL
    elif [[ -n "$ahead" ]]; then
      PL_BRANCH_CHAR=$BRANCH_AHEAD_SYMBOL
    elif [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$BRANCH_BEHIND_SYMBOL
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" $BISECT_SYMBOL"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" $MERGE_SYMBOL"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" $REBASE_SYMBOL"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr $STAGED_SYMBOL
    zstyle ':vcs_info:*' unstagedstr $UNSTAGED_SYMBOL
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    prompt_segment "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}" $bg $fg
  fi
}

prompt_bzr() {
  (( $+commands[bzr] )) || return

  # Test if bzr repository in directory hierarchy
  local dir="$PWD"
  while [[ ! -d "$dir/.bzr" ]]; do
    [[ "$dir" = "/" ]] && return
    dir="${dir:h}"
  done

  local bzr_status status_mod status_all revision
  if bzr_status=$(command bzr status 2>&1); then
    status_mod=$(echo -n "$bzr_status" | head -n1 | grep "modified" | wc -m)
    status_all=$(echo -n "$bzr_status" | head -n1 | wc -m)
    revision=${$(command bzr log -r-1 --log-format line | cut -d: -f1):gs/%/%%}
    if [[ $status_mod -gt 0 ]] ; then
      prompt_segment "bzr@$revision $STAGED_SYMBOL" $VCS_DIRTY_COLOR $TEXT_COLOR
    else
      if [[ $status_all -gt 0 ]] ; then
        prompt_segment "bzr@$revision" $VCS_DIRTY_COLOR $TEXT_COLOR
      else
        prompt_segment "bzr@$revision" $VCS_CLEAN_COLOR $TEXT_COLOR
      fi
    fi
  fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(command hg id >/dev/null 2>&1); then
    if $(command hg prompt >/dev/null 2>&1); then
      if [[ $(command hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        bg=$VCS_UNTRACKED_COLOR
        fg=$TEXT_COLOR
        st='±'
      elif [[ -n $(command hg prompt "{status|modified}") ]]; then
        # if any modification
        bg=$VCS_DIRTY_COLOR
        fg=$TEXT_COLOR
        st='±'
      else
        # if working copy is clean
        bg=$VCS_CLEAN_COLOR
        fg=$TEXT_COLOR
      fi
      echo -n ${$(command hg prompt "☿ {rev}@{branch}"):gs/%/%%} $st
    else
      st=""
      rev=$(command hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(command hg id -b 2>/dev/null)
      if command hg st | command grep -q "^\?"; then
        bg=$VCS_UNTRACKED_COLOR
        fg=$TEXT_COLOR
        st=$UNSTAGED_SYMBOL
      elif command hg st | command grep -q "^[MA]"; then
        bg=$VCS_DIRTY_COLOR
        fg=$TEXT_COLOR
        st=$UNSTAGED_SYMBOL
      else
        bg=$VCS_CLEAN_COLOR
        fg=$TEXT_COLOR
      fi
      prompt_segment "$MERCURIAL_SYMBOL ${rev:gs/%/%%}@${branch:gs/%/%%} $st" $bg $fg
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment '%1~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
    prompt_segment "$PYTHON_SYMBOL ${VIRTUAL_ENV:t:gs/%/%%}"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$ERROR_COLOR}%}$ERROR_SYMBOL "
  [[ $UID -eq 0 ]] && symbols+="%{%F{$ROOT_COLOR}%}$ROOT_SYMBOL "
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$BACKGROUND_JOBS_COLOR}%}$BACKGROUND_JOBS_SYMBOL "

  [[ -n "$symbols" ]] && prompt_segment "$symbols" && skip_segment
}

#AWS Profile:
# - display current AWS_PROFILE name
# - displays yellow on red if profile name contains 'production' or
#   ends in '-prod'
# - displays black on green otherwise
prompt_aws() {
  [[ -z "$AWS_PROFILE" || "$SHOW_AWS_PROMPT" = false ]] && return
  case "$AWS_PROFILE" in
    *-prod|*production*) prompt_segment "AWS: ${AWS_PROFILE:gs/%/%%}" $VSC_DIRTY $TEXT_COLOR;;
    *) prompt_segment "AWS: ${AWS_PROFILE:gs/%/%%}" $VCS_CLEAN_COLOR $TEXT_COLOR;;
  esac
}

prompt_os() {
  # Prompt symbol for OS
  # The next line will be replaced by the install script, don't edit it
  prompt_segment ###PROMPT_OS###
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_os
  prompt_virtualenv
  prompt_aws
  prompt_context
  prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
