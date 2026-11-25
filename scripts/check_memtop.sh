#!/bin/sh

watch -n 1 -d "ps -eo rss=,comm= | awk '{rss=\$1; \$1=\"\"; sub(/^ /,\"\"); mem[\$0]+=rss} END {for (p in mem) printf \"%8.1f MiB  %s\n\", mem[p]/1024, p}' | sort -rn | head -n \"${1:-16}\""

