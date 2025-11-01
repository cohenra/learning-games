import { Howl } from 'howler';

/**
 * Audio Manager - Handles all sound effects and narration
 * Uses Howler.js for cross-browser audio support
 */
class AudioManager {
  private sounds: Map<string, Howl> = new Map();
  private isMuted: boolean = false;

  /**
   * Preload a sound file
   */
  preload(key: string, src: string): void {
    if (!this.sounds.has(key)) {
      const sound = new Howl({
        src: [src],
        preload: true,
      });
      this.sounds.set(key, sound);
    }
  }

  /**
   * Play a sound effect
   */
  play(key: string, volume: number = 1.0): void {
    if (this.isMuted) return;

    const sound = this.sounds.get(key);
    if (sound) {
      sound.volume(volume);
      sound.play();
    }
  }

  /**
   * Play a click sound (for buttons)
   */
  playClick(): void {
    // For now, use Web Audio API beep as placeholder
    if (this.isMuted) return;
    this.playBeep(800, 100, 0.1);
  }

  /**
   * Play a success sound
   */
  playSuccess(): void {
    if (this.isMuted) return;
    this.playBeep(1000, 200, 0.2);
    setTimeout(() => this.playBeep(1200, 200, 0.2), 150);
  }

  /**
   * Play an error sound
   */
  playError(): void {
    if (this.isMuted) return;
    this.playBeep(400, 300, 0.15);
  }

  /**
   * Play a simple beep using Web Audio API (fallback for when no sound files are available)
   */
  private playBeep(frequency: number, duration: number, volume: number): void {
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);

      oscillator.frequency.value = frequency;
      oscillator.type = 'sine';

      gainNode.gain.setValueAtTime(volume, audioContext.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + duration / 1000);

      oscillator.start(audioContext.currentTime);
      oscillator.stop(audioContext.currentTime + duration / 1000);
    } catch (error) {
      console.warn('Audio playback failed:', error);
    }
  }

  /**
   * Speak text using Web Speech API
   */
  speak(text: string, lang: string = 'en-US'): void {
    if (this.isMuted) return;

    if ('speechSynthesis' in window) {
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = lang === 'he' ? 'he-IL' : 'en-US';
      utterance.rate = 0.9; // Slightly slower for kids
      utterance.pitch = 1.1; // Slightly higher pitch for friendly tone
      window.speechSynthesis.speak(utterance);
    }
  }

  /**
   * Stop all sounds
   */
  stopAll(): void {
    this.sounds.forEach((sound) => sound.stop());
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
    }
  }

  /**
   * Set mute state
   */
  setMuted(muted: boolean): void {
    this.isMuted = muted;
    if (muted) {
      this.stopAll();
    }
  }

  /**
   * Get mute state
   */
  getMuted(): boolean {
    return this.isMuted;
  }
}

// Export singleton instance
export const audioManager = new AudioManager();
