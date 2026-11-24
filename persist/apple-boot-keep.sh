#!/usr/bin/env bash
# Re-select the "apple" Plymouth theme if something (an Omarchy theme change,
# `omarchy plymouth reset`, a plymouth package upgrade) switched it back.
# Run by apple-boot-keep.service, as root.
set -euo pipefail

THEME=apple
[[ -d /usr/share/plymouth/themes/$THEME ]] || exit 0
[[ $(plymouth-set-default-theme) == "$THEME" ]] && exit 0

# The tool that switched the theme rebuilds the boot image right after it does;
# wait for that to finish so two rebuilds never overlap.
sleep 5
while pgrep -f 'mkinitcpio|dracut' >/dev/null; do sleep 3; done

[[ $(plymouth-set-default-theme) == "$THEME" ]] && exit 0
plymouth-set-default-theme "$THEME"
if command -v limine-mkinitcpio >/dev/null; then limine-mkinitcpio
elif command -v mkinitcpio >/dev/null; then mkinitcpio -P
elif command -v dracut >/dev/null; then dracut --force --regenerate-all
fi
