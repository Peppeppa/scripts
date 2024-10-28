#!/usr/bin/env bash

mkdir -p /boot/efi/EFI/Linux

while read -r line; do
	if [[ "$line" == 'usr/lib/modules/'+([^/])'/pkgbase' ]]; then
		kver="${line#'usr/lib/modules/'}"
		kver="${kver%'/pkgbase'}"

		dracut --force --uefi --kver "$kver" /boot/efi/EFI/Linux/arch-linux.efi
	fi
done
