"""Generates the game's short sound effects as 16-bit PCM WAV files.

These are simple synthesized tones (no external assets / licensing needed) used
by lib/services/sound_service.dart. Re-run with:

    python3 tool/generate_sfx.py

Outputs to assets/sounds/.
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")


def _envelope(i, n, attack=0.01, release=0.25):
    """Simple attack/release amplitude envelope in [0, 1]."""
    t = i / n
    a = max(1, int(attack * n))
    r = max(1, int(release * n))
    if i < a:
        return i / a
    if i > n - r:
        return max(0.0, (n - i) / r)
    return 1.0


def _write(name, samples):
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            v = int(max(-1.0, min(1.0, s)) * 32767)
            frames += struct.pack("<h", v)
        w.writeframes(bytes(frames))
    print(f"wrote {path} ({len(samples)} samples)")


def tone(freq, dur, vol=0.6, attack=0.01, release=0.3, harmonics=(1.0,)):
    n = int(SAMPLE_RATE * dur)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        val = 0.0
        for k, amp in enumerate(harmonics, start=1):
            val += amp * math.sin(2 * math.pi * freq * k * t)
        val *= _envelope(i, n, attack, release) * vol
        out.append(val)
    return out


def sweep(f0, f1, dur, vol=0.6, release=0.3):
    n = int(SAMPLE_RATE * dur)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / n
        f = f0 + (f1 - f0) * t
        phase += 2 * math.pi * f / SAMPLE_RATE
        out.append(math.sin(phase) * _envelope(i, n, 0.01, release) * vol)
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    out = [0.0] * n
    for tr in tracks:
        for i, s in enumerate(tr):
            out[i] += s
    # soft clip
    return [max(-1.0, min(1.0, s)) for s in out]


def concat(*tracks):
    out = []
    for tr in tracks:
        out.extend(tr)
    return out


# Tap: tiny soft blip.
_write("tap.wav", tone(660, 0.07, vol=0.4, release=0.6, harmonics=(1.0, 0.2)))

# Connect: quick upward pop when a path segment links.
_write("connect.wav", sweep(520, 880, 0.12, vol=0.45, release=0.4))

# Error: short low descending buzz.
_write(
    "error.wav",
    sweep(300, 140, 0.28, vol=0.5, release=0.5),
)

# Win: cheerful C-E-G-C arpeggio.
notes = [523.25, 659.25, 783.99, 1046.50]
arp = []
for idx, f in enumerate(notes):
    rel = 0.6 if idx == len(notes) - 1 else 0.2
    arp = concat(arp, tone(f, 0.16, vol=0.45, release=rel, harmonics=(1.0, 0.35, 0.12)))
_write("win.wav", arp)
