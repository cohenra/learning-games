# Audio Assets for Music Games

This directory contains audio files for the music games in the app.

## Required Files

### Notes (assets/audio/notes/)
Musical note sounds for the music composer and note learning games:
- `c.wav` or `c.ogg` - Do (C note)
- `d.wav` or `d.ogg` - Re (D note)
- `e.wav` or `e.ogg` - Mi (E note)
- `f.wav` or `f.ogg` - Fa (F note)
- `g.wav` or `g.ogg` - Sol (G note)
- `a.wav` or `a.ogg` - La (A note)
- `b.wav` or `b.ogg` - Si (B note)

### Instruments (assets/audio/instruments/)
Different instrument versions of the notes (optional, for instrument selection):
- Piano: `piano_c.wav`, `piano_d.wav`, `piano_e.wav`, `piano_f.wav`, `piano_g.wav`, `piano_a.wav`, `piano_b.wav`
- Guitar: `guitar_c.wav`, `guitar_d.wav`, etc.
- Flute: `flute_c.wav`, `flute_d.wav`, etc.
- Drum: `drum_hit.wav`

### Drums (assets/audio/drums/)
Drum sounds for the rhythm game:
- `drum_hit.wav` or `drum_hit.ogg` - Drum beat sound

## Where to Get Free Sound Files

### Option 1: Freesound.org (Best Quality, Free)
1. Go to https://freesound.org/
2. Search for "piano note C", "piano note D", etc.
3. Download WAV or OGG files
4. Rename them according to the naming convention above

### Option 2: Musical Note Generator Online
1. Go to https://www.szynalski.com/tone-generator/
2. Use these frequencies for notes:
   - C (Do): 261.63 Hz
   - D (Re): 293.66 Hz
   - E (Mi): 329.63 Hz
   - F (Fa): 349.23 Hz
   - G (Sol): 392.00 Hz
   - A (La): 440.00 Hz
   - B (Si): 493.88 Hz
3. Generate and download each tone
4. Save as c.wav, d.wav, etc.

### Option 3: Use Pre-made Sample Packs
- https://philharmonia.co.uk/resources/sound-samples/ (Free orchestral samples)
- https://musical-artifacts.com/ (Free instrument samples)
- https://freewavesamples.com/ (Free WAV samples)

### Option 4: Create with Audacity (Free Software)
1. Download Audacity: https://www.audacityteam.org/
2. Generate > Tone
3. Use frequencies listed above
4. Export as WAV or OGG
5. Save to appropriate directory

## File Format
- **Preferred**: OGG (smaller file size, good quality)
- **Alternative**: WAV (larger file size, best quality)
- **Also supported**: MP3

## Quick Setup (Minimal)
If you just want to get started quickly, download only these essential files:
1. `c.wav` through `b.wav` (7 note files)
2. `drum_hit.wav` (1 drum sound)

The app will work with just these 8 files!

## Note
The app will attempt to play sounds from these directories. If files are not found, it will fall back to TTS (text-to-speech) which doesn't sound as good for music.
