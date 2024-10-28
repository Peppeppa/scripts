#!/usr/bin/env bash

mkdir -p /boot/efi/EFI/BOOT

while read -r line; do
	if [[ "$line" == 'usr/lib/modules/'+([^/])'/pkgbase' ]]; then
		kver="${line#'usr/lib/modules/'}"
		kver="${kver%'/pkgbase'}"

		dracut --force --uefi --kver "$kver" /boot/efi/EFI/BOOT/bootx64.efi
	fi
done
