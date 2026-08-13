---
name: compress-videos
description: Batch-compress screen recordings (.mp4/.mkv) with ffmpeg/libx264, backing up originals before deleting them. Use when the user wants to shrink video files, compress a Videos folder, or reclaim disk space from screen recordings.
---

# compress-videos

Compress screen recordings with `ffmpeg` + `libx264`, safely, in batch.

## Single file

```bash
ffmpeg -y -i INPUT.ext \
  -c:v libx264 -crf 27 -preset veryfast -pix_fmt yuv420p \
  -c:a aac -b:a 128k \
  -movflags +faststart \
  OUTPUT-compressed.mp4
```

- `-crf 27`: quality target. Lower = larger/better. 23–28 is a good range for screen recordings (static UI, little motion compresses very well). Use ~20-23 for content with real motion/detail you want to preserve more of.
- `-preset veryfast`: good speed/size tradeoff for batch jobs. Use `medium`/`slow` for better compression if time isn't a concern.
- `-pix_fmt yuv420p`: ensures compatibility (some source recordings use 4:4:4 or odd pixel formats).
- `-movflags +faststart`: makes the mp4 web/streaming friendly.
- Always re-encode to a **new file**, never overwrite the source in place.

## Batch workflow (never delete originals blindly)

1. Create a backup dir inside the target folder, e.g. `_originals_backup/`.
2. For each candidate file (skip files already named `*-compressed*`):
   - Encode to `<name>-compressed.mp4` (or `<name>-compressed-mkv.mp4` if the source is `.mkv`, to avoid name collisions when both `.mp4` and `.mkv` versions of the same recording exist).
   - Verify the output exists, is non-empty, and is smaller than the source.
   - If it checks out: `mv` the **original** into the backup dir. If not: delete the bad output and leave the original alone.
3. Log every step (skip/ok/fail/warn) to a file so progress can be checked while it runs in the background — batch encodes of 100+ files take a while.
4. Run the batch as a detached background process (`nohup script.sh & `) since it can run for 10+ minutes.
5. **Wait for explicit user approval** before deleting `_originals_backup/`. Only then `rm -rf` it to actually reclaim disk space — until that point nothing is destroyed, just duplicated.

See `scripts/compress_videos.sh` for a ready-to-run implementation of this workflow over a directory of `.mp4`/`.mkv` files.

## Notes from prior runs

- Typical result on real screen-recording folders: ~50-80% size reduction per file, e.g. a 1.2G folder of screen recordings compressed down to ~400-700M before backup cleanup.
- If you find files with an existing `-compressed` sibling already sitting next to the original (leftover from a manual prior compression), just move the original straight to backup — no need to re-encode.
- Clean up `ffmpeg2pass-*.log*` temp files if present; they're two-pass encoding leftovers, not media, and are always safe to delete outright (no backup needed).
