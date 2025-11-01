import React from 'react';
import { motion } from 'framer-motion';
import { useTranslation } from 'react-i18next';
import { CommonButton } from '../components/CommonButton';
import { useAppStore } from '../context/store';
import { audioManager } from '../utils/audioManager';

/**
 * Settings - Configure app preferences
 * Features:
 * - Language selection (English/Hebrew)
 * - Sound on/off toggle
 * - Music on/off toggle
 * - Progress statistics
 */
export const Settings: React.FC = () => {
  const { t } = useTranslation();
  const {
    language,
    setLanguage,
    soundEnabled,
    musicEnabled,
    toggleSound,
    toggleMusic,
    progress,
  } = useAppStore();

  const handleLanguageChange = (lang: 'en' | 'he') => {
    setLanguage(lang);
  };

  const handleToggleSound = () => {
    toggleSound();
    audioManager.setMuted(!soundEnabled);
  };

  const totalStars = Object.values(progress).reduce((sum, p) => sum + p.stars, 0);
  const completedModules = Object.values(progress).filter((p) => p.completed).length;

  return (
    <div className="min-h-screen p-8">
      {/* Header */}
      <motion.div
        initial={{ y: -50, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        className="text-center mb-12"
      >
        <h1 className="text-6xl font-fredoka text-primary-600 mb-4">
          {t('settings.title')}
        </h1>
      </motion.div>

      <div className="max-w-2xl mx-auto space-y-8">
        {/* Language Settings */}
        <motion.div
          initial={{ x: -50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-3xl shadow-xl p-8"
        >
          <h2 className="text-3xl font-fredoka text-gray-800 mb-6">
            {t('settings.language')}
          </h2>
          <div className="flex gap-4">
            <CommonButton
              onClick={() => handleLanguageChange('en')}
              variant={language === 'en' ? 'primary' : 'secondary'}
              icon="🇺🇸"
            >
              {t('settings.english')}
            </CommonButton>
            <CommonButton
              onClick={() => handleLanguageChange('he')}
              variant={language === 'he' ? 'primary' : 'secondary'}
              icon="🇮🇱"
            >
              {t('settings.hebrew')}
            </CommonButton>
          </div>
        </motion.div>

        {/* Sound Settings */}
        <motion.div
          initial={{ x: -50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="bg-white rounded-3xl shadow-xl p-8"
        >
          <h2 className="text-3xl font-fredoka text-gray-800 mb-6">
            {t('settings.sound')}
          </h2>
          <div className="flex gap-4">
            <CommonButton
              onClick={handleToggleSound}
              variant={soundEnabled ? 'success' : 'danger'}
              icon={soundEnabled ? '🔊' : '🔇'}
            >
              {soundEnabled ? t('settings.soundOn') : t('settings.soundOff')}
            </CommonButton>
          </div>
        </motion.div>

        {/* Music Settings */}
        <motion.div
          initial={{ x: -50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="bg-white rounded-3xl shadow-xl p-8"
        >
          <h2 className="text-3xl font-fredoka text-gray-800 mb-6">
            {t('settings.music')}
          </h2>
          <div className="flex gap-4">
            <CommonButton
              onClick={toggleMusic}
              variant={musicEnabled ? 'success' : 'danger'}
              icon={musicEnabled ? '🎵' : '🔇'}
            >
              {musicEnabled ? t('settings.musicOn') : t('settings.musicOff')}
            </CommonButton>
          </div>
        </motion.div>

        {/* Progress Statistics */}
        <motion.div
          initial={{ x: -50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="bg-white rounded-3xl shadow-xl p-8"
        >
          <h2 className="text-3xl font-fredoka text-gray-800 mb-6">
            {t('dashboard.title')}
          </h2>
          <div className="space-y-4">
            <div className="flex items-center justify-between text-xl">
              <span className="text-gray-700">{t('dashboard.stars')}:</span>
              <div className="flex items-center gap-2">
                <span className="text-3xl">⭐</span>
                <span className="font-bold text-primary-600">{totalStars}</span>
              </div>
            </div>
            <div className="flex items-center justify-between text-xl">
              <span className="text-gray-700">{t('dashboard.completed')}:</span>
              <span className="font-bold text-secondary-600">{completedModules} / 4</span>
            </div>
          </div>
        </motion.div>

        {/* Back button */}
        <div className="flex justify-center pt-8">
          <CommonButton
            onClick={() => (window.location.href = '/')}
            variant="secondary"
            size="large"
          >
            {t('common.back')}
          </CommonButton>
        </div>
      </div>
    </div>
  );
};
