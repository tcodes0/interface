#! /usr/bin/env bash
# Copyright 2024 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.

### options, imports, mocks ###

set -euo pipefail
shopt -s globstar

### vars and functions ###

targetPath=linux/Mackup/.config/Code/User/settings.json
sourcePath="linux/Mackup/.config/Code - OSS/User/settings.json"

### validation, input handling ###

### script ###

\rm -f "$targetPath"

while read -r line; do
  # strip comments, not valid json
  if [[ ! $line =~ // ]]; then
    echo -n "$line" >>"$targetPath"
  fi
done <"$sourcePath"

yq --inplace eval '."shellformat.path" = "/opt/homebrew/bin/shfmt"' $targetPath
yq --inplace eval '."editor.lineHeight" = 20.3' $targetPath
yq --inplace eval '."editor.fontSize" = 12.5' $targetPath
yq --inplace eval '."terminal.integrated.defaultProfile.osx" = "bash"' $targetPath
yq --inplace eval '."window.zoomLevel" = -1' $targetPath
