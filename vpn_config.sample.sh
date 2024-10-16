#!/usr/bin/env bash

declare -A VPNS=(
    ["1"]="wg0:/etc/wireguard/wg0.conf"
    ["2"]="company-internal:/home/user/Documents/company-internal.conf"
    ["3"]="homelab:/etc/wireguard/homelab.conf"
    #["4"]="foo:/bar/foo.con"
)
