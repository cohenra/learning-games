import React from 'react';
import { motion } from 'framer-motion';
import { useTranslation } from 'react-i18next';
import { CommonButton } from '../components/CommonButton';

interface ModuleCardProps {
  title: string;
  description: string;
  icon: string;
  color: string;
  onClick: () => void;
  disabled?: boolean;
}

const ModuleCard: React.FC<ModuleCardProps> = ({
  title,
  description,
  icon,
  color,
  onClick,
  disabled = false,
}) => {
  return (
    <motion.div
      whileHover={disabled ? {} : { scale: 1.05, rotate: 2 }}
      whileTap={disabled ? {} : { scale: 0.95 }}
      className={`module-card ${disabled ? 'opacity-50 cursor-not-allowed' : ''}`}
      onClick={disabled ? undefined : onClick}
    >
      <div className="flex flex-col items-center gap-4">
        <motion.div
          className="text-8xl"
          animate={{ rotate: [0, -10, 10, -10, 0] }}
          transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
        >
          {icon}
        </motion.div>
        <div className={`text-3xl font-fredoka ${color}`}>{title}</div>
        <div className="text-lg text-gray-600 text-center">{description}</div>
      </div>
    </motion.div>
  );
};

/**
 * Home - Main landing page with module selection
 * Features:
 * - Colorful module cards for each learning topic
 * - Settings access
 * - Welcome message
 */
export const Home: React.FC = () => {
  const { t } = useTranslation();

  const modules = [
    {
      id: 'numbers',
      title: t('modules.numbers'),
      description: t('numbers.description'),
      icon: '🔢',
      color: 'text-primary-600',
      path: '/numbers',
      disabled: false,
    },
    {
      id: 'letters',
      title: t('modules.letters'),
      description: t('letters.description'),
      icon: '🔤',
      color: 'text-blue-600',
      path: '/letters',
      disabled: true, // Coming soon
    },
    {
      id: 'colors',
      title: t('modules.colors'),
      description: t('colors.description'),
      icon: '🎨',
      color: 'text-pink-600',
      path: '/colors',
      disabled: true, // Coming soon
    },
    {
      id: 'shapes',
      title: t('modules.shapes'),
      description: t('shapes.description'),
      icon: '⭐',
      color: 'text-purple-600',
      path: '/shapes',
      disabled: true, // Coming soon
    },
  ];

  return (
    <div className="min-h-screen p-8">
      {/* Header */}
      <motion.div
        initial={{ y: -50, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        className="text-center mb-12"
      >
        <h1 className="text-7xl font-fredoka text-primary-600 mb-4 animate-bounce-gentle">
          {t('common.appName')}
        </h1>
        <p className="text-3xl text-gray-700">{t('common.welcome')}</p>
      </motion.div>

      {/* Module grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-8 max-w-6xl mx-auto">
        {modules.map((module, index) => (
          <motion.div
            key={module.id}
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <ModuleCard
              title={module.title}
              description={module.description}
              icon={module.icon}
              color={module.color}
              onClick={() => {
                if (!module.disabled) {
                  window.location.href = module.path;
                }
              }}
              disabled={module.disabled}
            />
          </motion.div>
        ))}
      </div>

      {/* Settings button */}
      <div className="fixed bottom-8 right-8">
        <CommonButton
          onClick={() => (window.location.href = '/settings')}
          variant="secondary"
          icon="⚙️"
          size="medium"
        >
          {t('settings.title')}
        </CommonButton>
      </div>
    </div>
  );
};
