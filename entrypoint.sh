#!/bin/bash

set -e

setupSSH() {
  local SSH_PATH="$HOME/.ssh"

  mkdir -p "$SSH_PATH"
  touch "$SSH_PATH/known_hosts"

  echo "$INPUT_KEY" > "$SSH_PATH/deploy_key"

  chmod 700 "$SSH_PATH"
  chmod 600 "$SSH_PATH/known_hosts"
  chmod 600 "$SSH_PATH/deploy_key"

  eval $(ssh-agent)
  ssh-add "$SSH_PATH/deploy_key"

  ssh-keyscan -t rsa $INPUT_PROXY_HOST >> "$SSH_PATH/known_hosts"
}

executeSSH() {
  if [ -z "$1" ];
  then
    return
  fi
  
  local LINES=$1
  
  local COMMAND=""	

  # holds all commands separated by semi-colon	
  local COMMANDS=""	

  # this while read each commands in line and	
  # evaluate each line agains all environment variables	
  while IFS= read -r LINE; do	
    LINE=$(eval 'echo "$LINE"')	
    LINE=$(eval echo "$LINE")	
    COMMAND=$(echo $LINE)	

    if [ -z "$COMMANDS" ]; then	
      COMMANDS="$COMMAND"	
    else	
      COMMANDS="$COMMANDS && $COMMAND"	
    fi	
  done <<< $LINES
  
  echo "ssh -o StrictHostKeyChecking=no -p ${INPUT_PROXY_PORT:-22} $INPUT_PROXY_USER@$INPUT_PROXY_HOST \"ssh -o StrictHostKeyChecking=no -p ${INPUT_DST_PORT:-22} $INPUT_DST_USER@$INPUT_DST_HOST ${COMMANDS%&&*}\""
  ssh -o StrictHostKeyChecking=no -p ${INPUT_PROXY_PORT:-22} $INPUT_PROXY_USER@$INPUT_PROXY_HOST "ssh -o StrictHostKeyChecking=no -p ${INPUT_DST_PORT:-22} $INPUT_DST_USER@$INPUT_DST_HOST ${COMMANDS%&&*}"
 }

executeRsync() {
  local LINES=$1
  local COMMAND=

  # this while read each commands in line and
  # evaluate each line agains all environment variables
  while IFS= read -r LINE; do
    LINE=$(eval 'echo "$LINE"')
    LINE=$(eval echo "$LINE")
    COMMAND=$(echo $LINE)

    #if [[ $COMMAND = *[!\ ]* ]]; then
      echo "rsync $INPUT_RSYNC_FLAGS -e \"ssh -o StrictHostKeyChecking=no -p ${INPUT_PROXY_PORT:-22}\" $INPUT_SRC_FILE $INPUT_PROXY_USER@$INPUT_PROXY_HOST:$INPUT_PROXY_FILE_PATH"
      # scp to board
      rsync $INPUT_RSYNC_FLAGS -e "ssh -o StrictHostKeyChecking=no -p ${INPUT_PROXY_PORT:-22}" $INPUT_SRC_FILE $INPUT_PROXY_USER@$INPUT_PROXY_HOST:$INPUT_PROXY_FILE_PATH
      # scp from board to dst
      ssh -o StrictHostKeyChecking=no -p ${INPUT_PROXY_PORT:-22} $INPUT_PROXY_USER@$INPUT_PROXY_HOST rsync $INPUT_PROXY_FILE_PATH/$INPUT_SRC_FILE $INPUT_DST_USER@$INPUT_DST_HOST:$INPUT_DST_FILE_PATH
    #fi
  done <<< $LINES
}

setupSSH
echo "------------ RUNNING BEFORE SSH ------------"
executeSSH "$INPUT_SSH_BEFORE"
echo "------------ RUNNING Rsync ------------"
executeRsync
echo "------------ RUNNING AFTER SSH ------------"
executeSSH "$INPUT_SSH_AFTER"
