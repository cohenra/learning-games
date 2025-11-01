import React from 'react';
import { motion } from 'framer-motion';
import { audioManager } from '../utils/audioManager';
import { useAppStore } from '../context/store';

interface CommonButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'secondary' | 'success' | 'danger';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  className?: string;
  icon?: React.ReactNode;
  playSound?: boolean;
}

/**
 * CommonButton - A reusable button component with animations and sound
 * Features:
 * - Framer Motion animations (hover, tap)
 * - Sound feedback on click
 * - Multiple variants and sizes
 * - Child-friendly design (large, colorful, rounded)
 */
export const CommonButton: React.FC<CommonButtonProps> = ({
  children,
  onClick,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  className = '',
  icon,
  playSound = true,
}) => {
  const soundEnabled = useAppStore((state) => state.soundEnabled);

  const handleClick = () => {
    if (disabled) return;

    // Play click sound if enabled
    if (playSound && soundEnabled) {
      audioManager.playClick();
    }

    onClick?.();
  };

  // Size classes
  const sizeClasses = {
    small: 'min-h-[60px] min-w-[60px] text-lg px-4 py-2',
    medium: 'min-h-[80px] min-w-[80px] text-xl px-6 py-3',
    large: 'min-h-[100px] min-w-[100px] text-2xl px-8 py-4',
  };

  // Variant classes
  const variantClasses = {
    primary: 'bg-gradient-to-br from-primary-400 to-primary-600 text-white hover:from-primary-500 hover:to-primary-700',
    secondary: 'bg-gradient-to-br from-secondary-400 to-secondary-600 text-white hover:from-secondary-500 hover:to-secondary-700',
    success: 'bg-gradient-to-br from-green-400 to-green-600 text-white hover:from-green-500 hover:to-green-700',
    danger: 'bg-gradient-to-br from-red-400 to-red-600 text-white hover:from-red-500 hover:to-red-700',
  };

  const baseClasses = 'rounded-3xl shadow-lg font-bold transition-all duration-200 flex items-center justify-center gap-3';
  const disabledClasses = disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer';

  return (
    <motion.button
      className={`${baseClasses} ${sizeClasses[size]} ${variantClasses[variant]} ${disabledClasses} ${className}`}
      onClick={handleClick}
      disabled={disabled}
      whileHover={disabled ? {} : { scale: 1.05 }}
      whileTap={disabled ? {} : { scale: 0.95 }}
      transition={{ type: 'spring', stiffness: 400, damping: 17 }}
    >
      {icon && <span className="text-3xl">{icon}</span>}
      <span>{children}</span>
    </motion.button>
  );
};
