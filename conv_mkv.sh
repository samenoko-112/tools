#!/bin/bash

# ==============================
#  MKV Conversion Script (v2)
#  Usage: ./conv_mkv.sh [input_folder] [output_folder]
# ==============================

# 1. 入力フォルダ取得
if [ -z "$1" ]; then
    echo "==========================================="
    echo " MKV Conversion Script"
    echo "==========================================="
    read -rp "Enter input folder path: " INPUT_DIR
else
    INPUT_DIR="$1"
fi

if [ -z "$INPUT_DIR" ]; then
    echo "Error: No input path entered."
    exit 1
fi

# 入力フォルダ存在確認
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input folder does not exist."
    echo "Entered path: $INPUT_DIR"
    exit 1
fi

# 2. 出力フォルダ取得
if [ -z "$2" ]; then
    read -rp "Enter output folder path (default = current directory): " OUTPUT_DIR
    OUTPUT_DIR="${OUTPUT_DIR:-$(pwd)}"
else
    OUTPUT_DIR="$2"
fi

# 出力フォルダ作成
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "[Info] Output folder does not exist. Creating..."
    mkdir -p "$OUTPUT_DIR"
fi

echo
echo "Input folder : $INPUT_DIR"
echo "Output folder: $OUTPUT_DIR"
echo

# 3. 変換処理
FOUND=0
shopt -s nullglob
for F in "$INPUT_DIR"/*.mkv; do
    FOUND=1
    echo
    echo "Processing: $(basename "$F")"
    ffmpeg -i "$F" -map 0:v -map 0:a -c:v hevc_nvenc -preset p4 -tune hq -cq 20 -profile:v main10 -pix_fmt p010le -maxrate 4M -bufsize 4M -f mp4 -c:a copy "$OUTPUT_DIR/$(basename "${F%.mkv}").mp4" -y
    if [ $? -ne 0 ]; then
        echo "Error: Failed to convert $(basename "$F")"
    else
        echo "Done: $(basename "${F%.mkv}").mp4"
    fi
done
shopt -u nullglob

# 4. 最終メッセージ
if [ $FOUND -eq 0 ]; then
    echo
    echo "Warning: No .mkv files found in the specified folder."
else
    echo
    echo "All conversions completed."
fi