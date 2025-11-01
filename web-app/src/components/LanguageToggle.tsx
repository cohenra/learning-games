import React from 'react';
import { motion } from 'framer-motion';
import { useAppStore } from '../context/store';
import { audioManager } from '../utils/audioManager';

/**
 * LanguageToggle - Switch between English and Hebrew
 * Features:
 * - Smooth animation between states
 * - Visual feedback
 * - Sound on toggle
 * - Flag emojis for visual clarity
 */
export const LanguageToggle: React.FC = () => {
  const { language, setLanguage, soundEnabled } = useAppStore();

  const handleToggle = () => {
    const newLang = language === 'en' ? 'he' : 'en';
    setLanguage(newLang);

    if (soundEnabled) {
      audioManager.playClick();
    }
  };

  return (
    <motion.button
      onClick={handleToggle}
      className="fixed top-4 right-4 z-50 bg-white rounded-full shadow-lg p-2 flex items-center gap-2 min-w-[120px] justify-center"
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      <motion.div
        className="flex items-center gap-2"
        initial={false}
        animate={{ x: language === 'en' ? 0 : 0 }}
      >
        {language === 'en' ? (
          <>
            <span className="text-2xl">🇺🇸</span>
            <span className="font-bold text-sm">EN</span>
          </>
        ) : (
          <>
            <span className="text-2xl">🇮🇱</span>
            <span className="font-bold text-sm">עב</span>
          </>
        )}
      </motion.div>
    </motion.button>
  );
};
