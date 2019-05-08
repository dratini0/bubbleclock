# -*- coding: utf-8 -*-

A = 1 << 2
B = 1 << 6
C = 1 << 0
D = 1 << 4
E = 1 << 3
F = 1 << 7
G = 1 << 5
DP = 1 << 1

alphabet = {
    ' ': 0,
    '0': A | B | C | D | E | F,
    '1': B | C,
    '2': A | B | D | E | G,
    '3': A | B | C | D | G,
    '4': B | C | F | G,
    '5': A | C | D | F | G,
    '6': A | C | D | E | F | G,
    '7': A | B | C,
    '8': A | B | C | D | E | F | G,
    '9': A | B | C | D | F | G,
    'A': A | B | C | E | F | G,
    'B': C | D | E | F | G,
    'C': A | D | E | F,
    'D': B | C | D | E | G,
    'E': A | D | E | F | G,
    'F': A | E | F | G,
    'G': A | C | D | E | F,
    'H': B | C | E | F | G,
    'I': E | F,
    'J': B | C | D,
    'K': E | F | G,
    'L': D | E | F,
    'M': A | C | E,
    'N': A | B | C | E | F,
    'O': A | B | C | D | E | F,
    'P': A | B | E | F | G,
    'Q': A | B | C | F | G,
    'R': A | E | F,
    'S': A | C | D | F | G,
    'T': D | E | F | F | G,
    'U': B | C | D | E | F,
    'V': C | D | E,
    'W': B | D | F,
    'X': B | C | E | F,
    'Y': B | E | F | G,
    'Z': A | B | D | E | G,
    '_': D,
    '\'': B,
    '-': G,
    '.': DP,
    '!': B | C | DP,
    '"': B | F,
    "(": A | D | E | F,
    ")": A | B | C | D,
    "[": A | D | E | F,
    "]": A | B | C | D,
    "{": A | D | E | F | G,
    "}": A | B | C | D | G,
    "<": D | E | G,
    ">": C | D | G,
    "/": B | E | G,
    "\\": C | F | G,
    "|": B | C,
}