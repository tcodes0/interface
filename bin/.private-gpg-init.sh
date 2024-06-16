#! /usr/bin/env bash

set -e
gpg --pinentry-mode=loopback --passphrase 2JCWCvUZycjdt7NPfQiDVqZ --sign --default-key thomazella9@gmail.com "$(mktemp)"
