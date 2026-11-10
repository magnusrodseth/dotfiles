# Mode: reference (take the grammar of a video, frame or image library)

Naming a style beats describing one; a reference beats both. Take the grammar, never the content, logos or characters.

## Steps
1. Put the reference in `refs/` (download a video with `yt-dlp` or use a file the user supplies).
2. Extract frames: `ffmpeg -i refs/ref.mp4 -vf fps=2 refs/frames/%04d.png`, plus a contact sheet: `bash $S/review.sh refs/ref.mp4`. LOOK at them.
3. Write `docs/style_guide.md`: palette (hex, sampled), type (family guess, weight, tracking, case), shot lengths (measured from cuts), transition types, camera moves, texture and grain, how text enters and exits, sound character.
4. Write the beat sheet for the user's subject in that grammar. Show both files and wait for OK before code.
5. **Save it as a style** when the user likes the result: copy the style guide into `styles/<kebab-name>.md` using the same sections as the other style files (Palette, Type, Texture, Motion, Sound, Banned, Brief fragment) and add trigger words. That is how the style library grows.

Let the model pick the technique (canvas, SVG paths, offscreen compositing) to match the look; specify the look and constraints, not a library.
