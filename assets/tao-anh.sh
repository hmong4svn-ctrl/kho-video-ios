#!/bin/bash
# Sinh lai icon + splash cho Kho Video tu kho-video-mark.svg
# Chay:  bash assets/tao-anh.sh     (dung tu goc du an ~/kho-video-ios)
set -e
cd "$(dirname "$0")"
rm -f icon-1024.svg.png splash-2732.svg.png
qlmanage -t -s 1024 -o . icon-1024.svg  >/dev/null 2>&1
qlmanage -t -s 2732 -o . splash-2732.svg >/dev/null 2>&1
python3 lam-phang.py
