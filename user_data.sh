#!/bin/bash
# Runs once on first boot. Output goes to /var/log/cloud-init-output.log
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y postgresql postgresql-contrib

systemctl enable --now postgresql
