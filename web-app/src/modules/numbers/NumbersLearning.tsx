import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useTranslation } from 'react-i18next';
import { CommonButton } from '../../components/CommonButton';
import { audioManager } from '../../utils/audioManager';
import { useAppStore } from '../../context/store';

interface NumberData {
  value: number;
  key: string;
}

const numbers: NumberData[] = [
  { value: 1, key: 'one' },
  { value: 2, key: 'two' },
  { value: 3, key: 'three' },
  { value: 4, key: 'four' },
  { value: 5, key: 'five' },
  { value: 6, key: 'six' },
  { value: 7, key: 'seven' },
  { value: 8, key: 'eight' },
  { value: 9, key: 'nine' },
  { value: 10, key: 'ten' },
];

/**
 * NumbersLearning - Learning mode for numbers
 * Features:
 * - One number at a time with large visual display
 * - Voice narration in selected language
 * - Visual dots/objects to represent quantity
 * - Next/Previous navigation
 */
export const NumbersLearning: React.FC = () => {
  const { t } = useTranslation();
  const { language, soundEnabled } = useAppStore();
  const [currentIndex, setCurrentIndex] = useState(0);

  const currentNumber = numbers[currentIndex];

  // Speak the number when it changes
  useEffect(() => {
    if (soundEnabled) {
      const text = t(`numbers.${currentNumber.key}`);
      audioManager.speak(text, language);
    }
  }, [currentIndex, soundEnabled, language, t, currentNumber.key]);

  const handleNext = () => {
    if (currentIndex < numbers.length - 1) {
      setCurrentIndex(currentIndex + 1);
    }
  };

  const handlePrevious = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  };

  const handleSpeak = () => {
    if (soundEnabled) {
      const text = t(`numbers.${currentNumber.key}`);
      audioManager.speak(text, language);
    }
  };

  // Generate visual dots to represent the number
  const renderDots = () => {
    const dots = [];
    for (let i = 0; i < currentNumber.value; i++) {
      dots.push(
        <motion.div
          key={i}
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: i * 0.1, type: 'spring', stiffness: 200 }}
          className="w-16 h-16 bg-gradient-to-br from-primary-400 to-primary-600 rounded-full shadow-lg"
        />
      );
    }
    return dots;
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-8 gap-8">
      {/* Number display */}
      <motion.div
        key={currentNumber.value}
        initial={{ scale: 0, rotate: -180 }}
        animate={{ scale: 1, rotate: 0 }}
        transition={{ type: 'spring', stiffness: 150 }}
        className="text-9xl font-fredoka text-primary-600 cursor-pointer"
        onClick={handleSpeak}
      >
        {currentNumber.value}
      </motion.div>

      {/* Number name */}
      <motion.div
        key={`text-${currentNumber.value}`}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-4xl font-fredoka text-secondary-600"
      >
        {t(`numbers.${currentNumber.key}`)}
      </motion.div>

      {/* Visual representation with dots */}
      <div className="flex flex-wrap justify-center gap-4 max-w-2xl">
        {renderDots()}
      </div>

      {/* Navigation buttons */}
      <div className="flex gap-4 mt-8">
        <CommonButton
          onClick={handlePrevious}
          disabled={currentIndex === 0}
          variant="secondary"
        >
          {t('common.back')}
        </CommonButton>

        <CommonButton
          onClick={handleSpeak}
          variant="primary"
          icon="🔊"
        >
          {language === 'en' ? 'Listen' : 'הקשב'}
        </CommonButton>

        <CommonButton
          onClick={handleNext}
          disabled={currentIndex === numbers.length - 1}
          variant="secondary"
        >
          {t('common.next')}
        </CommonButton>
      </div>

      {/* Progress indicator */}
      <div className="flex gap-2 mt-4">
        {numbers.map((_, index) => (
          <div
            key={index}
            className={`w-3 h-3 rounded-full ${
              index === currentIndex ? 'bg-primary-600' : 'bg-gray-300'
            }`}
          />
        ))}
      </div>
    </div>
  );
};
