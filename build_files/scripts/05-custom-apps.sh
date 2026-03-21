#!/bin/bash

set -ouex pipefail

#mkdir -p /opt/
rsync -a ctx/files/opt/ /opt/