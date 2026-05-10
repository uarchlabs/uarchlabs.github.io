#!/usr/bin/env bash
# blog_convert.sh — convert raw blog markdown to Jekyll post format
# Usage: blog_convert.sh <raw_blog.md> <YYYY-MM-DD> <"Post Title"> <repo_root>

set -e

usage() {
  echo "Usage: $0 <raw_blog.md> <YYYY-MM-DD> <\"Post Title\"> <repo_root>"
  echo "  raw_blog.md  — path to source markdown file"
  echo "  YYYY-MM-DD   — post date"
  echo "  Post Title   — title string (quote if it contains spaces)"
  echo "  repo_root    — path to uarchlabs.github.io repo root"
  exit 1
}

# ── Args ──────────────────────────────────────────────────────────────────────
[[ $# -lt 4 ]] && usage

RAW="$1"
DATE="$2"
TITLE="$3"
REPO="$4"

# ── Validate source file ──────────────────────────────────────────────────────
if [[ ! -f "$RAW" ]]; then
  echo "ERROR: source file not found: $RAW"
  exit 1
fi

# ── Validate date format ──────────────────────────────────────────────────────
if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "ERROR: date must be YYYY-MM-DD format, got: $DATE"
  exit 1
fi

# ── Derive output filename from title ────────────────────────────────────────
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
POSTS_DIR="$REPO/_posts"
OUTFILE="$POSTS_DIR/${DATE}-${SLUG}.md"

# ── Check _posts directory exists ────────────────────────────────────────────
if [[ ! -d "$POSTS_DIR" ]]; then
  echo "ERROR: _posts directory not found at: $POSTS_DIR"
  exit 1
fi

# ── Check for existing output file ───────────────────────────────────────────
if [[ -f "$OUTFILE" ]]; then
  echo "WARNING: output file already exists: $OUTFILE"
  read -p "Overwrite? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# ── Check assets/diagrams directory ──────────────────────────────────────────
DIAGRAMS_DIR="$REPO/assets/diagrams"
if [[ ! -d "$DIAGRAMS_DIR" ]]; then
  echo "WARNING: assets/diagrams directory not found at: $DIAGRAMS_DIR"
  echo "         Image references will be updated but diagrams will not render until"
  echo "         the directory is created and SVG files are copied there."
fi

# ── Build output ──────────────────────────────────────────────────────────────
{
  # Front matter
  cat << FRONTMATTER
---
layout: post
title: "$TITLE"
author: Jeff Nye
date: $DATE
copyright: "Copyright $(echo $DATE | cut -d- -f1) Jeff Nye"
---
FRONTMATTER

  # Process content: comment out file header block, update image paths
  python3 - "$RAW" << 'PYEOF'
import sys
import re

with open(sys.argv[1], 'r') as f:
    content = f.read()

# Comment out the file header block (``` FILE: ... ``` block at top)
content = re.sub(
    r'^(```\n FILE:.*?```)',
    lambda m: '\n'.join(['[//]: # (header: ' + line + ')' for line in m.group(1).split('\n')]),
    content,
    flags=re.DOTALL | re.MULTILINE
)

# Update image paths from diagrams/ to /assets/diagrams/
content = re.sub(
    r'!\[([^\]]*)\]\(diagrams/([^)]+)\)',
    r'![\1](/assets/diagrams/\2)',
    content
)

print(content)
PYEOF

} > "$OUTFILE"

echo "Done: $OUTFILE"

# ── Report any image references found ────────────────────────────────────────
IMAGES=$(grep -o '/assets/diagrams/[^)]*' "$OUTFILE" || true)
if [[ -n "$IMAGES" ]]; then
  echo ""
  echo "Image references in post:"
  echo "$IMAGES" | while read img; do
    IMGFILE="$REPO$img"
    if [[ -f "$IMGFILE" ]]; then
      echo "  ✓ $img"
    else
      echo "  ✗ $img  (file not found)"
    fi
  done
fi

