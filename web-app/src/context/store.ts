import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export type Language = 'en' | 'he';

export type ModuleName = 'numbers' | 'letters' | 'colors' | 'shapes';

export interface ModuleProgress {
  completed: boolean;
  stars: number;
  lastAccessed: number;
  correctAnswers: number;
  totalAttempts: number;
}

export interface AppState {
  // Language settings
  language: Language;
  setLanguage: (lang: Language) => void;

  // Audio settings
  soundEnabled: boolean;
  musicEnabled: boolean;
  toggleSound: () => void;
  toggleMusic: () => void;

  // Progress tracking
  progress: Record<ModuleName, ModuleProgress>;
  updateProgress: (module: ModuleName, updates: Partial<ModuleProgress>) => void;
  addStar: (module: ModuleName) => void;
  recordAnswer: (module: ModuleName, isCorrect: boolean) => void;

  // Current activity
  currentModule: ModuleName | null;
  setCurrentModule: (module: ModuleName | null) => void;

  // Rewards
  showReward: boolean;
  setShowReward: (show: boolean) => void;
}

// Initialize default progress for all modules
const defaultProgress: Record<ModuleName, ModuleProgress> = {
  numbers: { completed: false, stars: 0, lastAccessed: 0, correctAnswers: 0, totalAttempts: 0 },
  letters: { completed: false, stars: 0, lastAccessed: 0, correctAnswers: 0, totalAttempts: 0 },
  colors: { completed: false, stars: 0, lastAccessed: 0, correctAnswers: 0, totalAttempts: 0 },
  shapes: { completed: false, stars: 0, lastAccessed: 0, correctAnswers: 0, totalAttempts: 0 },
};

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({
      // Language
      language: 'en',
      setLanguage: (lang) => {
        set({ language: lang });
        localStorage.setItem('language', lang);
        // Update i18next language
        import('../i18n/config').then((i18n) => {
          i18n.default.changeLanguage(lang);
        });
      },

      // Audio
      soundEnabled: true,
      musicEnabled: true,
      toggleSound: () => set((state) => ({ soundEnabled: !state.soundEnabled })),
      toggleMusic: () => set((state) => ({ musicEnabled: !state.musicEnabled })),

      // Progress
      progress: defaultProgress,
      updateProgress: (module, updates) =>
        set((state) => ({
          progress: {
            ...state.progress,
            [module]: {
              ...state.progress[module],
              ...updates,
              lastAccessed: Date.now(),
            },
          },
        })),
      addStar: (module) =>
        set((state) => ({
          progress: {
            ...state.progress,
            [module]: {
              ...state.progress[module],
              stars: state.progress[module].stars + 1,
            },
          },
        })),
      recordAnswer: (module, isCorrect) =>
        set((state) => ({
          progress: {
            ...state.progress,
            [module]: {
              ...state.progress[module],
              correctAnswers: state.progress[module].correctAnswers + (isCorrect ? 1 : 0),
              totalAttempts: state.progress[module].totalAttempts + 1,
            },
          },
        })),

      // Current activity
      currentModule: null,
      setCurrentModule: (module) => set({ currentModule: module }),

      // Rewards
      showReward: false,
      setShowReward: (show) => set({ showReward: show }),
    }),
    {
      name: 'learning-app-storage',
    }
  )
);
