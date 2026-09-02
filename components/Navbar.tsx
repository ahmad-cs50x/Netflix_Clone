'use client';

import { useState, useEffect } from 'react';

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 80);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <nav
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
        scrolled ? 'bg-black' : 'bg-gradient-to-b from-black/80 to-transparent'
      }`}
    >
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 md:px-8 lg:px-12 xl:px-16 py-3 sm:py-4 md:py-5 flex items-center justify-between">
        {/* Netflix Logo - Responsive sizing */}
        <div className="flex items-center">
          <img
            src="https://upload.wikimedia.org/wikipedia/commons/0/08/Netflix_2015_logo.svg"
            alt="Netflix"
            className="h-5 sm:h-6 md:h-7 lg:h-8 xl:h-9 2xl:h-10 w-auto"
          />
        </div>

        {/* Sign In Button - Responsive sizing */}
        <div className="flex items-center">
          <button className="px-2.5 sm:px-3 md:px-4 lg:px-5 py-1 sm:py-1.5 md:py-1.5 hover:bg-red-700 bg-[#E50914] text-white rounded-sm sm:rounded transition-colors">
            <span className="text-xs sm:text-sm md:text-base lg:text-lg font-medium">
              Sign In
            </span>
          </button>
        </div>
      </div>
    </nav>
  );
}