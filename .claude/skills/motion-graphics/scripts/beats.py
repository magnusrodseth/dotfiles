"""beats.py: measure a supplied music track into beats.json (the animation reads this file).

    uv run --with librosa --with numpy python beats.py song.wav > audio/beats.json

State changes go on beats, big moments on downbeats, SFX on hits (onset peaks).
Downbeats assume 4/4 starting on the first detected beat; check the first bar by ear.
"""
import json
import sys

import librosa
import numpy as np

y, sr = librosa.load(sys.argv[1], sr=None, mono=True)
tempo, frames = librosa.beat.beat_track(y=y, sr=sr, units="frames")
beats = librosa.frames_to_time(frames, sr=sr).round(3).tolist()
onset = librosa.onset.onset_strength(y=y, sr=sr)
peaks = librosa.util.peak_pick(onset, pre_max=3, post_max=3, pre_avg=3, post_avg=5, delta=0.5, wait=10)
json.dump(
    {
        "bpm": float(np.atleast_1d(tempo)[0]),
        "dur": round(len(y) / sr, 3),
        "beats": beats,
        "downbeats": beats[::4],
        "hits": librosa.frames_to_time(peaks, sr=sr).round(3).tolist(),
        "sections": [],
    },
    sys.stdout,
    indent=1,
)
