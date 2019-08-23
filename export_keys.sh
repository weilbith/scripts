#!/bin/bash

GPG_KEY_FOLDER="$1/gpg"
GPG_KEY_LIST=(
  'D5D1694701ACA02D7299BE1A4F4F2CC0DBEFB434'
  'D53C38FA78DFF2B4279F91B052FCDAA1483DA28D'
)

SSH_KEY_FOLDER="$1/ssh"
SSH_KEY_FOLDER_SOURCE="$HOME/.ssh"
SSH_KEY_LIST=(
  'kautz'
  'cubietruck'
  'github'
  'trustlines_validator'
)

# Export functions

function export_gpg_keys() {
  if ! command -v gpg >/dev/null; then
    echo "Can not export GuPG keys, since the command gpg is not available!"
    return
  fi

  mkdir -p "$GPG_KEY_FOLDER"

  for key in "${GPG_KEY_LIST[@]}"; do
    echo "Export GPG key '$key' ..."
    gpg --output "$GPG_KEY_FOLDER/${key}_pub.gpg" --armor --export "$key"
    gpg --output "$GPG_KEY_FOLDER/${key}_sec.gpg" --armor --export-secret-key "$key"
  done
}

function export_ssh_keys() {
  if [[ ! -d "$SSH_KEY_FOLDER_SOURCE" ]]; then
    echo "Can not export SSH keys, since the folder '$SSH_KEY_FOLDER_SOURCE' does not exist!"
    return
  fi

  mkdir -p "$SSH_KEY_FOLDER"

  for key in "${SSH_KEY_LIST[@]}"; do
    echo "Export SSH key '$key' ..."
    local private_key_source="$SSH_KEY_FOLDER_SOURCE/$key"
    local private_key_destination="$SSH_KEY_FOLDER/$key"
    local public_key_source="$SSH_KEY_FOLDER_SOURCE/${key}.pub"
    local public_key_destination="$SSH_KEY_FOLDER/${key}.pub"

    if [[ ! -f "$private_key_source" ]] || [[ ! -f "$public_key_source" ]]; then
      echo "Was not able to find public and private key for '$key'!"
      continue
    fi

    cp -f "$private_key_source" "$private_key_destination"
    cp -f "$public_key_source" "$public_key_destination"
  done
}

# Getting started

if [[ ! -d "$1" ]]; then
  echo "The given argument is not an existing folder!"
  exit 1
fi

export_gpg_keys
export_ssh_keys
