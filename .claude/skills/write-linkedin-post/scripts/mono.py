#!/usr/bin/env python3
"""Convert ASCII letters and digits to Unicode Mathematical Monospace.

This is how inline code gets a code look on LinkedIn, which strips markdown.
Only [A-Za-z0-9] change. Punctuation, spaces and non-ASCII (æ, ø, å) pass
through untouched, which matches how rauchg writes 𝚗𝚙𝚡 𝚜𝚊𝚗𝚍𝚋𝚘𝚡@𝚕𝚊𝚝𝚎𝚜𝚝.

Usage:
  python3 mono.py 'vercel connect create notion'
  echo 'AGENTS.md' | python3 mono.py
  python3 mono.py --decode '𝚛𝚎𝚜𝚎𝚝'      # back to ASCII
"""
import sys

_UPPER, _LOWER, _DIGIT = 0x1D670, 0x1D68A, 0x1D7F6


def encode(s: str) -> str:
    out = []
    for ch in s:
        if "A" <= ch <= "Z":
            out.append(chr(_UPPER + ord(ch) - ord("A")))
        elif "a" <= ch <= "z":
            out.append(chr(_LOWER + ord(ch) - ord("a")))
        elif "0" <= ch <= "9":
            out.append(chr(_DIGIT + ord(ch) - ord("0")))
        else:
            out.append(ch)
    return "".join(out)


def decode(s: str) -> str:
    out = []
    for ch in s:
        cp = ord(ch)
        if _UPPER <= cp < _UPPER + 26:
            out.append(chr(ord("A") + cp - _UPPER))
        elif _LOWER <= cp < _LOWER + 26:
            out.append(chr(ord("a") + cp - _LOWER))
        elif _DIGIT <= cp < _DIGIT + 10:
            out.append(chr(ord("0") + cp - _DIGIT))
        else:
            out.append(ch)
    return "".join(out)


if __name__ == "__main__":
    args = sys.argv[1:]
    fn = encode
    if args and args[0] == "--decode":
        fn = decode
        args = args[1:]
    text = " ".join(args) if args else sys.stdin.read().rstrip("\n")
    print(fn(text))
