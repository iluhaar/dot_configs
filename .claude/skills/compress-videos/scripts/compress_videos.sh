#!/bin/bash
# Batch-compress .mp4/.mkv files in a directory with ffmpeg/libx264.
# Originals are moved (not deleted) into <dir>/_originals_backup/ after a
# successful, smaller re-encode. Nothing is permanently deleted by this script.
#
# Usage: compress_videos.sh [DIR] [CRF]
#   DIR  - directory containing videos (default: current directory)
#   CRF  - libx264 CRF quality (default: 27; lower = larger/better)
set -uo pipefail

VIDDIR="${1:-.}"
CRF="${2:-27}"
BACKUP="$VIDDIR/_originals_backup"
LOG="$VIDDIR/_compression_log.txt"

cd "$VIDDIR" || exit 1
mkdir -p "$BACKUP"
: > "$LOG"

shopt -s nullglob
files=(*.mp4 *.mkv)
total=${#files[@]}
i=0
saved_total=0

for f in "${files[@]}"; do
  i=$((i+1))
  case "$f" in
    *-compressed.mp4|*-compressed-mkv.mp4) continue ;;
  esac
  [ -f "$f" ] || continue

  base="${f%.*}"
  ext="${f##*.}"
  if [ "$ext" = "mkv" ]; then
    out="${base}-compressed-mkv.mp4"
  else
    out="${base}-compressed.mp4"
  fi

  if [ -f "$out" ]; then
    echo "[$i/$total] SKIP (output exists): $f" | tee -a "$LOG"
    continue
  fi

  echo "[$i/$total] Encoding: $f -> $out" | tee -a "$LOG"

  if ffmpeg -y -i "$f" -c:v libx264 -crf "$CRF" -preset veryfast -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart "$out" >> "$LOG" 2>&1; then
    if [ -s "$out" ]; then
      osize=$(stat -c%s "$f")
      csize=$(stat -c%s "$out")
      if [ "$csize" -gt 0 ] && [ "$csize" -lt "$osize" ]; then
        saved=$((osize - csize))
        saved_total=$((saved_total + saved))
        mv "$f" "$BACKUP/"
        echo "[$i/$total] OK: $f moved to backup. Saved $((saved/1024/1024))MB" | tee -a "$LOG"
      else
        echo "[$i/$total] WARN: compressed not smaller for $f, keeping original, discarding output" | tee -a "$LOG"
        rm -f "$out"
      fi
    else
      echo "[$i/$total] FAIL: empty output for $f" | tee -a "$LOG"
      rm -f "$out"
    fi
  else
    echo "[$i/$total] FAIL: ffmpeg error on $f" | tee -a "$LOG"
    rm -f "$out"
  fi
done

echo "DONE. Total saved: $((saved_total/1024/1024)) MB. Review compressed files, then rm -rf $BACKUP to reclaim space." | tee -a "$LOG"
