#!/bin/sh

set -eu

sh -c "/bin/gitea-secret-sync $*"
