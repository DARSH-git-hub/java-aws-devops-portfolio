#!/usr/bin/env bash
set -euo pipefail
dnf install -y docker
systemctl enable --now docker
# No app image or secret is downloaded here. Deploy separately after reviewing costs.
