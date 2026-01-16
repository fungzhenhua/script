#! /bin/sh
#
# seewo.sh
# Copyright (C) 2026 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#
# Seewo Board Synthesizer: Automated Teaching Whiteboard Content Compiler
OUTNAME=$(basename $PWD)
magick $(ls $PWD/*.png) ${OUTNAME}.pdf
