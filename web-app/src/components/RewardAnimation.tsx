import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAppStore } from '../context/store';
import { audioManager } from '../utils/audioManager';

/**
 * RewardAnimation - Celebratory animation for correct answers
 * Features:
 * - Confetti/stars animation
 * - Success sound
 * - Encouraging text
 * - Auto-dismisses after animation
 */
export const RewardAnimation: React.FC = () => {
  const { showReward, setShowReward, soundEnabled } = useAppStore();
  const [particles, setParticles] = useState<{ id: number; x: number; emoji: string }[]>([]);

  useEffect(() => {
    if (showReward) {
      // Play success sound
      if (soundEnabled) {
        audioManager.playSuccess();
      }

      // Generate random particles (stars, sparkles, etc.)
      const emojis = ['⭐', '✨', '🌟', '💫', '🎉', '🎊', '👏'];
      const newParticles = Array.from({ length: 20 }, (_, i) => ({
        id: i,
        x: Math.random() * 100 - 50,
        emoji: emojis[Math.floor(Math.random() * emojis.length)],
      }));
      setParticles(newParticles);

      // Auto-dismiss after 2 seconds
      const timer = setTimeout(() => {
        setShowReward(false);
      }, 2000);

      return () => clearTimeout(timer);
    }
  }, [showReward, soundEnabled, setShowReward]);

  const encouragingPhrases = [
    '🎉 Awesome!',
    '⭐ Great Job!',
    '💯 Perfect!',
    '🌟 Well Done!',
    '👏 Amazing!',
    '🎊 Excellent!',
  ];

  const randomPhrase = encouragingPhrases[Math.floor(Math.random() * encouragingPhrases.length)];

  return (
    <AnimatePresence>
      {showReward && (
        <div className="reward-container">
          {/* Central success message */}
          <motion.div
            initial={{ scale: 0, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0, opacity: 0 }}
            transition={{ type: 'spring', stiffness: 200, damping: 15 }}
            className="text-6xl font-fredoka text-primary-600 z-50"
          >
            {randomPhrase}
          </motion.div>

          {/* Particle effects */}
          {particles.map((particle) => (
            <motion.div
              key={particle.id}
              initial={{ y: 0, x: 0, opacity: 1, scale: 0 }}
              animate={{
                y: [-100, -300],
                x: [0, particle.x * 3],
                opacity: [1, 0],
                scale: [0, 1.5],
                rotate: [0, 360],
              }}
              transition={{
                duration: 1.5,
                ease: 'easeOut',
              }}
              className="absolute text-4xl pointer-events-none"
              style={{
                left: `calc(50% + ${particle.x}px)`,
                top: '50%',
              }}
            >
              {particle.emoji}
            </motion.div>
          ))}
        </div>
      )}
    </AnimatePresence>
  );
};
