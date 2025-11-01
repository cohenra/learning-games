import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { motion } from 'framer-motion';
import { CommonButton } from '../../components/CommonButton';
import { NumbersLearning } from './NumbersLearning';
import { NumbersQuiz } from './NumbersQuiz';

type Mode = 'menu' | 'learning' | 'quiz';

/**
 * NumbersModule - Main container for the Numbers learning module
 * Allows switching between menu, learning mode, and quiz mode
 */
export const NumbersModule: React.FC = () => {
  const { t } = useTranslation();
  const [mode, setMode] = useState<Mode>('menu');

  if (mode === 'learning') {
    return (
      <div>
        <div className="fixed top-4 left-4 z-50">
          <CommonButton onClick={() => setMode('menu')} variant="secondary" size="small">
            {t('common.back')}
          </CommonButton>
        </div>
        <NumbersLearning />
      </div>
    );
  }

  if (mode === 'quiz') {
    return (
      <div>
        <div className="fixed top-4 left-4 z-50">
          <CommonButton onClick={() => setMode('menu')} variant="secondary" size="small">
            {t('common.back')}
          </CommonButton>
        </div>
        <NumbersQuiz />
      </div>
    );
  }

  // Menu mode
  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-8 gap-8">
      <motion.div
        initial={{ scale: 0, rotate: -10 }}
        animate={{ scale: 1, rotate: 0 }}
        transition={{ type: 'spring', stiffness: 150 }}
        className="text-7xl font-fredoka text-primary-600 mb-4"
      >
        {t('numbers.title')}
      </motion.div>

      <div className="text-2xl text-gray-700 mb-8">
        {t('numbers.description')}
      </div>

      <div className="flex flex-col gap-6 w-full max-w-md">
        <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
          <CommonButton
            onClick={() => setMode('learning')}
            variant="primary"
            size="large"
            icon="📚"
            className="w-full"
          >
            {t('numbers.learnMode')}
          </CommonButton>
        </motion.div>

        <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
          <CommonButton
            onClick={() => setMode('quiz')}
            variant="secondary"
            size="large"
            icon="🎮"
            className="w-full"
          >
            {t('numbers.quizMode')}
          </CommonButton>
        </motion.div>

        <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
          <CommonButton
            onClick={() => (window.location.href = '/')}
            variant="secondary"
            size="medium"
            className="w-full"
          >
            {t('common.back')}
          </CommonButton>
        </motion.div>
      </div>
    </div>
  );
};
