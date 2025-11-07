#!/usr/bin/env python3
"""
Generate musical note WAV files for the learning app.
Creates 7 notes (C, D, E, F, G, A, B) and a drum sound.
"""

import wave
import struct
import math

def generate_tone(frequency, duration=1.0, sample_rate=44100, amplitude=0.5):
    """Generate a pure tone at the given frequency."""
    num_samples = int(sample_rate * duration)
    samples = []

    for i in range(num_samples):
        # Generate sine wave
        t = i / sample_rate
        sample = amplitude * math.sin(2 * math.pi * frequency * t)

        # Add slight envelope (fade in/out) to avoid clicks
        envelope = 1.0
        fade_samples = int(sample_rate * 0.01)  # 10ms fade
        if i < fade_samples:
            envelope = i / fade_samples
        elif i > num_samples - fade_samples:
            envelope = (num_samples - i) / fade_samples

        sample *= envelope

        # Convert to 16-bit integer
        sample = int(sample * 32767)
        samples.append(sample)

    return samples

def save_wav(filename, samples, sample_rate=44100):
    """Save samples to a WAV file."""
    with wave.open(filename, 'w') as wav_file:
        # Set parameters: 1 channel (mono), 2 bytes per sample, sample rate
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)

        # Write samples
        for sample in samples:
            wav_file.writeframes(struct.pack('<h', sample))

def generate_drum_hit(duration=0.2, sample_rate=44100):
    """Generate a drum hit sound (low frequency with quick decay)."""
    num_samples = int(sample_rate * duration)
    samples = []

    for i in range(num_samples):
        t = i / sample_rate

        # Combine low frequency (60Hz bass) with noise
        frequency = 60 + (150 * (1 - t/duration))  # Pitch drops

        # Exponential decay envelope
        envelope = math.exp(-10 * t / duration)

        # Bass component
        bass = 0.7 * math.sin(2 * math.pi * frequency * t)

        # Noise component for "snap"
        noise = 0.3 * (2 * (hash(i) % 1000) / 1000 - 1)

        sample = (bass + noise) * envelope
        sample = int(sample * 32767)
        sample = max(-32768, min(32767, sample))  # Clamp

        samples.append(sample)

    return samples

# Musical note frequencies (middle octave)
notes = {
    'c': 261.63,  # C4 (Do)
    'd': 293.66,  # D4 (Re)
    'e': 329.63,  # E4 (Mi)
    'f': 349.23,  # F4 (Fa)
    'g': 392.00,  # G4 (Sol)
    'a': 440.00,  # A4 (La)
    'b': 493.88,  # B4 (Si)
}

print("Generating musical note WAV files...")

# Generate note files
for note, frequency in notes.items():
    filename = f'assets/audio/notes/{note}.wav'
    print(f"  Generating {note.upper()} ({frequency:.2f} Hz) -> {filename}")
    samples = generate_tone(frequency, duration=0.8)
    save_wav(filename, samples)

# Generate drum hit
print("  Generating drum hit -> assets/audio/drums/drum_hit.wav")
drum_samples = generate_drum_hit()
save_wav('assets/audio/drums/drum_hit.wav', drum_samples)

print("\n✓ All audio files generated successfully!")
print("  - 7 musical notes (C-D-E-F-G-A-B)")
print("  - 1 drum hit sound")
