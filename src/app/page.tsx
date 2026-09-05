'use client';

import Navbar from '../../components/Navbar';
import Hero from '../../components/Hero';

export default function NetflixHome() {
  return (
    <div className="bg-[#141414] text-white min-h-screen overflow-x-hidden">
      <Navbar />
      <Hero />
    </div>
  );
}
