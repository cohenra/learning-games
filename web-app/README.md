# 🎮 Learning Fun - Interactive Bilingual Kids Learning App

An interactive educational web application for children aged 2-6, featuring bilingual support (Hebrew–English) and fun learning modules for numbers, letters, colors, and shapes.

## ✨ Features

### 🌐 Bilingual Support
- **English ↔ Hebrew** toggle with full RTL support
- Real-time language switching
- Native speech synthesis for both languages

### 📚 Learning Modules
- **Numbers Module** (MVP - Fully Implemented)
  - Learning Mode: Visual number learning with dots representation
  - Quiz Mode: Interactive number recognition game
  - Voice narration in selected language
  - Progress tracking with star rewards

- **Coming Soon:**
  - Letters Module
  - Colors Module
  - Shapes Module

### 🎨 Child-Friendly Design
- Large, colorful buttons (minimum 80px touch targets)
- Smooth animations with Framer Motion
- Rounded corners and playful gradients
- Friendly fonts (Fredoka One + Alef)
- Encouraging feedback and reward animations

### 🎵 Audio Features
- Sound effects for interactions
- Speech synthesis for learning content
- Mute controls in settings
- Separate music/sound toggles

### 📊 Progress Tracking
- Star-based reward system
- Module completion tracking
- Statistics in settings
- Local storage persistence

## 🛠 Tech Stack

- **Framework:** React 18 + TypeScript
- **Build Tool:** Vite
- **Styling:** TailwindCSS v4
- **Animations:** Framer Motion
- **Audio:** Howler.js + Web Speech API
- **State Management:** Zustand with persistence
- **Internationalization:** i18next + react-i18next

## 📁 Project Structure

```
web-app/
├── src/
│   ├── assets/              # Images, sounds, icons
│   │   ├── images/
│   │   ├── sounds/
│   │   └── icons/
│   ├── components/          # Reusable components
│   │   ├── CommonButton.tsx
│   │   ├── LanguageToggle.tsx
│   │   └── RewardAnimation.tsx
│   ├── modules/             # Learning modules
│   │   ├── numbers/
│   │   │   ├── NumbersLearning.tsx
│   │   │   ├── NumbersQuiz.tsx
│   │   │   └── NumbersModule.tsx
│   │   ├── letters/
│   │   ├── colors/
│   │   └── shapes/
│   ├── context/             # State management
│   │   └── store.ts
│   ├── pages/               # Main pages
│   │   ├── Home.tsx
│   │   └── Settings.tsx
│   ├── hooks/               # Custom React hooks
│   ├── utils/               # Utilities
│   │   └── audioManager.ts
│   ├── i18n/                # Translations
│   │   ├── config.ts
│   │   └── locales/
│   │       ├── en.json
│   │       └── he.json
│   ├── App.tsx              # Main app component
│   ├── main.tsx             # Entry point
│   └── index.css            # Global styles
├── public/                  # Static assets
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.js
```

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ and npm

### Installation

1. **Navigate to the web-app directory:**
   ```bash
   cd web-app
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the development server:**
   ```bash
   npm run dev
   ```

4. **Open your browser:**
   Visit `http://localhost:5173`

### Build for Production

```bash
npm run build
```

The built files will be in the `dist/` directory.

### Preview Production Build

```bash
npm run preview
```

## 🎯 Usage

### Navigation
- **Home Page:** Select a learning module
- **Numbers Module:** Choose between Learning or Quiz mode
- **Settings:** Configure language, sound, and view progress
- **Language Toggle:** Click the flag icon (top-right) to switch languages

### Learning Mode
1. Click on a module card (e.g., Numbers)
2. Select "Learning Mode"
3. View numbers with visual representation
4. Click the speaker icon to hear pronunciation
5. Use Next/Back buttons to navigate

### Quiz Mode
1. Click on a module card
2. Select "Quiz Time"
3. Count the dots and select the correct number
4. Earn stars for correct answers
5. Complete 5 questions to finish

## 🎨 Design Guidelines

### Colors
- **Primary:** Orange gradient (#f7a028 → #dd7800)
- **Secondary:** Blue gradient (#34b9ff → #0095e6)
- **Success:** Green gradient
- **Background:** Soft blue-purple-pink gradient

### Typography
- **Headings:** Fredoka One (playful, rounded)
- **Body:** Alef (Hebrew-friendly)
- **Sizes:** Minimum 1.25rem for buttons, larger for learning content

### Accessibility
- Minimum 80px touch targets
- High contrast text
- RTL support for Hebrew
- Keyboard navigation support
- Screen reader compatible

## 🔧 Configuration

### Adding New Languages
1. Create translation file in `src/i18n/locales/{lang}.json`
2. Update `src/i18n/config.ts` to include new language
3. Add language option to Settings page

### Adding New Modules
1. Create module folder in `src/modules/{module-name}/`
2. Implement Learning and Quiz components
3. Add translations
4. Update Home page with new module card
5. Add routing in App.tsx

## 📝 Code Quality

### TypeScript
- Strict mode enabled
- Full type coverage
- Interface definitions for all props

### Comments
- Clear component descriptions
- JSDoc-style documentation
- Inline comments for complex logic

### Best Practices
- Functional components with hooks
- Custom hooks for reusable logic
- Proper state management with Zustand
- Optimized re-renders with React.memo where needed

## 🐛 Known Issues & Future Enhancements

### Current Limitations
- Only Numbers module fully implemented
- Audio files are placeholders (using Web Speech API)
- No backend integration (all data stored locally)

### Planned Features
- [ ] Complete Letters, Colors, and Shapes modules
- [ ] Add custom audio files for better narration
- [ ] Implement drag-and-drop quiz types
- [ ] Add parental dashboard with detailed analytics
- [ ] Backend API for cloud progress sync
- [ ] Additional languages support
- [ ] Offline mode with service workers
- [ ] Certificate/achievement system

## 📄 License

This project is part of the learning-games repository.

## 👥 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 🙏 Credits

- **Fonts:** Google Fonts (Fredoka One, Alef)
- **Icons:** Emoji (cross-platform compatible)
- **Audio:** Web Speech API
- **Animations:** Framer Motion

---

Built with ❤️ for young learners everywhere!
