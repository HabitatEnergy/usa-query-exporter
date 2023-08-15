#!/usr/bin/env bash

set -e
set -x

# Make sure permissions are secure.
chmod 700 ~/.ssh infrastructure/ssh
chmod 600 ~/.ssh/* infrastructure/ssh/*
