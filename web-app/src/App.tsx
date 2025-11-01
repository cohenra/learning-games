import { useEffect, useState } from 'react';
import { Home } from './pages/Home';
import { Settings } from './pages/Settings';
import { NumbersModule } from './modules/numbers/NumbersModule';
import { LanguageToggle } from './components/LanguageToggle';
import { RewardAnimation } from './components/RewardAnimation';
import { useAppStore } from './context/store';
import { audioManager } from './utils/audioManager';

/**
 * App - Main application component with simple routing
 * Features:
 * - Hash-based routing (no external router needed)
 * - Language toggle always visible
 * - Reward animation overlay
 * - Audio management
 */
function App() {
  const [route, setRoute] = useState(window.location.pathname);
  const { soundEnabled, language } = useAppStore();

  // Simple routing - listen to hash changes or use pathname
  useEffect(() => {
    const handleLocationChange = () => {
      setRoute(window.location.pathname);
    };

    window.addEventListener('popstate', handleLocationChange);
    return () => window.removeEventListener('popstate', handleLocationChange);
  }, []);

  // Set audio mute state
  useEffect(() => {
    audioManager.setMuted(!soundEnabled);
  }, [soundEnabled]);

  // Set document direction based on language (RTL for Hebrew)
  useEffect(() => {
    document.documentElement.dir = language === 'he' ? 'rtl' : 'ltr';
    document.documentElement.lang = language;
  }, [language]);

  // Render the appropriate component based on route
  const renderPage = () => {
    switch (route) {
      case '/numbers':
        return <NumbersModule />;
      case '/settings':
        return <Settings />;
      default:
        return <Home />;
    }
  };

  return (
    <div className="min-h-screen">
      <LanguageToggle />
      <RewardAnimation />
      {renderPage()}
    </div>
  );
}

export default App;
