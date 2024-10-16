#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/vpn_config.sh"

if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run this script with sudo or as root"
    exit 1
fi

RES=$(ip a)

if [ "$#" -eq 0 ]; then
    STATUS=0

    for key in "${!VPNS[@]}"; do
        NAME="${VPNS[$key]%%:*}"
        if echo "$RES" | grep -q "$NAME"; then
            echo "[+] VPN ON"
            STATUS=1
            VPN="$NAME"
            echo "[+] Currently connected to $VPN"
            break
        fi
    done

    if [ "$STATUS" -eq 1 ]; then
        read -p "[>] Do you want to disconnect? [y/N]: " DISCONNECT
        if [[ "$DISCONNECT" == "y" || "$DISCONNECT" == "Y" ]]; then
            for key in "${!VPNS[@]}"; do
                if [[ "${VPNS[$key]%%:*}" == "$VPN" ]]; then
                    CONFIG_PATH="${VPNS[$key]##*:}"
                    break
                fi
            done
            wg-quick down "$CONFIG_PATH"
            echo "[+] VPN disconnected"
        else
            echo "[+] VPN still connected"
        fi
    else
        echo "[-] VPN OFF"
        echo "[-] Not connected to a VPN"
        read -p "[>] Do you wish to connect to a VPN? [y/N]: " CONNECT
        if [[ "$CONNECT" == "y" || "$CONNECT" == "Y" ]]; then
            echo "[~] Available VPNs:"
            for key in "${!VPNS[@]}"; do
                echo "  [$key] ${VPNS[$key]%%:*}"
            done

            OPTIONS=$(printf "%s " "${!VPNS[@]}")
            read -p "[>] Which VPN do you wish to connect to? (int): " VPN_CHOICE

            if [[ ${VPNS[$VPN_CHOICE]+_} ]]; then
                CONFIG_FILE="${VPNS[$VPN_CHOICE]##*:}"
                wg-quick up "$CONFIG_FILE"
                echo "[+] ${VPNS[$VPN_CHOICE]%%:*} connected"
            else
                echo "[-] Invalid VPN choice"
            fi
        fi
    fi
fi
