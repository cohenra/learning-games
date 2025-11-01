import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useTranslation } from 'react-i18next';
import { CommonButton } from '../../components/CommonButton';
import { audioManager } from '../../utils/audioManager';
import { useAppStore } from '../../context/store';

interface QuizQuestion {
  number: number;
  options: number[];
}

/**
 * NumbersQuiz - Quiz mode for numbers
 * Features:
 * - Random questions with multiple choice
 * - Visual feedback for correct/incorrect answers
 * - Score tracking
 * - Encouraging feedback
 */
export const NumbersQuiz: React.FC = () => {
  const { t } = useTranslation();
  const { soundEnabled, setShowReward, recordAnswer, addStar, language } = useAppStore();
  const [currentQuestion, setCurrentQuestion] = useState<QuizQuestion | null>(null);
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null);
  const [score, setScore] = useState(0);
  const [questionsAnswered, setQuestionsAnswered] = useState(0);
  const totalQuestions = 5;

  // Generate a random question
  const generateQuestion = () => {
    const number = Math.floor(Math.random() * 10) + 1;
    const options = [number];

    // Generate 3 wrong options
    while (options.length < 4) {
      const wrongOption = Math.floor(Math.random() * 10) + 1;
      if (!options.includes(wrongOption)) {
        options.push(wrongOption);
      }
    }

    // Shuffle options
    const shuffled = options.sort(() => Math.random() - 0.5);

    setCurrentQuestion({ number, options: shuffled });
    setSelectedAnswer(null);
    setIsCorrect(null);
  };

  // Initialize first question
  useEffect(() => {
    generateQuestion();
  }, []);

  const handleAnswer = (answer: number) => {
    if (selectedAnswer !== null) return; // Already answered

    setSelectedAnswer(answer);
    const correct = answer === currentQuestion?.number;
    setIsCorrect(correct);

    // Record answer in store
    recordAnswer('numbers', correct);

    if (correct) {
      setScore(score + 1);
      setShowReward(true);
      if (soundEnabled) {
        audioManager.playSuccess();
      }
      addStar('numbers');
    } else {
      if (soundEnabled) {
        audioManager.playError();
      }
    }

    setQuestionsAnswered(questionsAnswered + 1);
  };

  const handleNext = () => {
    if (questionsAnswered >= totalQuestions) {
      // Quiz completed
      return;
    }
    generateQuestion();
  };

  // Generate visual dots to represent the number
  const renderDots = (count: number) => {
    const dots = [];
    for (let i = 0; i < count; i++) {
      dots.push(
        <motion.div
          key={i}
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: i * 0.05, type: 'spring', stiffness: 200 }}
          className="w-12 h-12 bg-gradient-to-br from-secondary-400 to-secondary-600 rounded-full shadow-lg"
        />
      );
    }
    return dots;
  };

  if (!currentQuestion) return null;

  if (questionsAnswered >= totalQuestions) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen p-8 gap-8">
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          className="text-6xl font-fredoka text-primary-600"
        >
          {t('common.wellDone')}
        </motion.div>
        <div className="text-3xl font-bold">
          {language === 'en' ? 'Score:' : 'ניקוד:'} {score} / {totalQuestions}
        </div>
        <div className="flex gap-2">
          {Array.from({ length: score }).map((_, i) => (
            <motion.div
              key={i}
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ delay: i * 0.1 }}
              className="text-5xl"
            >
              ⭐
            </motion.div>
          ))}
        </div>
        <CommonButton onClick={() => window.location.reload()} variant="primary">
          {language === 'en' ? 'Play Again' : 'שחק שוב'}
        </CommonButton>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-8 gap-8">
      {/* Progress */}
      <div className="text-2xl font-bold text-gray-700">
        {language === 'en' ? 'Question' : 'שאלה'} {questionsAnswered + 1} / {totalQuestions}
      </div>

      {/* Question: Show dots */}
      <div className="text-3xl font-fredoka text-secondary-600 mb-4">
        {language === 'en' ? 'How many?' : 'כמה?'}
      </div>

      <div className="flex flex-wrap justify-center gap-3 max-w-2xl mb-8">
        {renderDots(currentQuestion.number)}
      </div>

      {/* Answer options */}
      <div className="grid grid-cols-2 gap-4">
        {currentQuestion.options.map((option) => {
          let buttonVariant: 'primary' | 'success' | 'danger' = 'primary';

          if (selectedAnswer !== null) {
            if (option === currentQuestion.number) {
              buttonVariant = 'success';
            } else if (option === selectedAnswer && !isCorrect) {
              buttonVariant = 'danger';
            }
          }

          return (
            <motion.div
              key={option}
              whileHover={selectedAnswer === null ? { scale: 1.05 } : {}}
              whileTap={selectedAnswer === null ? { scale: 0.95 } : {}}
            >
              <CommonButton
                onClick={() => handleAnswer(option)}
                variant={buttonVariant}
                disabled={selectedAnswer !== null}
                size="large"
                className="w-32 h-32 text-5xl"
              >
                {option}
              </CommonButton>
            </motion.div>
          );
        })}
      </div>

      {/* Feedback */}
      {selectedAnswer !== null && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex flex-col items-center gap-4"
        >
          <div className={`text-3xl font-fredoka ${isCorrect ? 'text-green-600' : 'text-red-600'}`}>
            {isCorrect ? t('common.correct') : t('common.tryAgain')}
          </div>
          <CommonButton onClick={handleNext} variant="secondary">
            {t('common.next')}
          </CommonButton>
        </motion.div>
      )}

      {/* Score */}
      <div className="flex gap-2 mt-4">
        {Array.from({ length: score }).map((_, i) => (
          <div key={i} className="text-3xl">
            ⭐
          </div>
        ))}
      </div>
    </div>
  );
};
