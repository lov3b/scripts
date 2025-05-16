#!/usr/bin/env python3

import re
import fileinput


DASH = r"[–—-]"

PATTERN = re.compile(
    rf"""
    ^\s*
    (?P<track>\d+)                  # track number
    (?:\s*\.|\s*{DASH}\s*|\s+)      # 1.  | 1 -  | 1<space>
    (?P<artist>.+?)                 # artist (non-greedy)
    \s*{DASH}\s*                    # separator between artist and title
    (?P<title>.+?)                  # title
    \s*$
    """,
    re.UNICODE | re.VERBOSE,
)

def convert_line(line: str) -> str:
    m = PATTERN.match(line)
    if not m:
        return line.rstrip("\n")

    track = m.group("track").strip()
    artist = " ".join(m.group("artist").split()).strip(" .-–—")
    title = " ".join(m.group("title").split()).strip(" .-–—")

    end = "" if title.endswith((".", "!", "?")) else "."
    return f"{track}. {title} - {artist}{end}"

def main():
    lines = []
    for raw in fileinput.input():
        if raw.strip() == "":
            continue
        lines.append(convert_line(raw))
    print("# Converted:", *lines, sep="\n")

if __name__ == "__main__":
    main()

