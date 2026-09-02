"use client";

import React, { useState } from "react";

export default function NetflixClone() {
  const [openIndex, setOpenIndex] = useState(null);

  const faqs = [
    {
      question: "What is Netflix?",
      answer:
        "Netflix is a streaming service that offers a wide variety of award-winning TV shows, movies, anime, documentaries, and more on thousands of internet-connected devices.\n\nYou can watch as much as you want, whenever you want without a single commercial – all for one low monthly price. There's always something new to discover and new TV shows and movies are added every week!",
    },
    {
      question: "How much does Netflix cost?",
      answer:
        "Watch Netflix on your smartphone, tablet, Smart TV, laptop, or streaming device, all for one fixed monthly fee. Plans range from Rs 250 to Rs 1,100 a month. No extra costs, no contracts.",
    },
    {
      question: "Where can I watch?",
      answer:
        "Watch anywhere, anytime. Sign in with your Netflix account to watch instantly on the web at netflix.com from your personal computer or on any internet-connected device that offers the Netflix app, including smart TVs, smartphones, tablets, streaming media players and game consoles.\n\nYou can also download your favorite shows with the iOS, Android, or Windows 10 app. Use downloads to watch while you're on the go and without an internet connection. Take Netflix with you anywhere.",
    },
    {
      question: "How do I cancel?",
      answer:
        "Netflix is flexible. There are no pesky contracts and no commitments. You can easily cancel your account online in two clicks. There are no cancellation fees – start or stop your account anytime.",
    },
    {
      question: "What can I watch on Netflix?",
      answer:
        "Netflix has an extensive library of feature films, documentaries, TV shows, anime, award-winning Netflix originals, and more. Watch as much as you want, anytime you want.",
    },
    {
      question: "Is Netflix good for kids?",
      answer:
        "The Netflix Kids experience is included in your membership to give parents control while kids enjoy family-friendly TV shows and movies in their own space.\n\nKids profiles come with PIN-protected parental controls that let you restrict the maturity rating of content kids can watch and block specific titles you don’t want kids to see.",
    },
  ];

  const Divider = () => <div className="h-2 w-full bg-[#000000]"></div>;

  return (
    <div className="bg-black min-h-screen font-[Netflix Sans] text-white selection:bg-[#E50914] selection:text-white">
      {/* Hero Section */}
      <div className="relative h-[100vh] min-h-[600px] w-full border-b-8 border-[#232323]">
        <div className="absolute inset-0 z-0 overflow-hidden">
          <img
            src="fgdf.png"
            className="h-full w-full md:mt-45 mt-0  mr-12 object-cover opacity-50 scale-145"
            alt="Netflix Background"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-black/30 to-black/20"></div>
        </div>

        <div className="relative z-10 flex flex-col h-full">

          {/* Hero Content */}
          <main className="flex-1 flex flex-col items-center justify-center text-center px-4 md:px-32 max-w-5xl mx-auto w-full">
            <h2 className="text-3xl md:text-5xl lg:text-6xl font-black text-white mb-6">
              Unlimited movies, TV shows, and more
            </h2>
            <p className="text-[14px] md:text-xl text-white mb-6 font-medium">
              Starts at Rs 250. Cancel anytime.</p>
            <p className="text-white text-[14px] md:text-lg mb-4 font-normal">
              Ready to watch? Enter your email to create or restart your membership.
            </p>
            <div className="flex flex-col md:flex-row gap-2 w-full max-w-xl mt-2">
              <input
                type="email"
                placeholder="Email address"
                className="flex-1 bg-black/50 border border-neutral-500 rounded px-3 py-3 md:py-4 text-white placeholder-neutral-400 focus:outline-none focus:border-white focus:ring-1 focus:ring-white transition-all text-lg"
              />
                <button className="bg-[#E50914] text-[22px] lg:text-[25px] text-white py-2 rounded ml-12 lg:ml-0 md:ml-0 w-[68%] md:w-[30%] font-extralight hover:bg-[#C11119] transition-colors flex items-center justify-center gap-2">
                Get Started
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </button>
            </div>
          </main>
        </div>
      </div>

      {/* Feature 1: TV */}
      <div className="bg-black py-16 md:py-24 px-4 md:px-32 border-b-8 border-[#232323]">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-8">
          <div className="flex-1 text-center md:text-left z-10">
            <h2 className="text-3xl md:text-5xl font-black mb-6">Enjoy on your TV</h2>
            <p className="text-lg md:text-2xl font-medium">
              Watch on Smart TVs, Playstation, Xbox, Chromecast, Apple TV, Blu-ray players, and more.
            </p>
          </div>
          <div className="flex-1 relative">
            <img src="https://assets.nflxext.com/ffe/siteui/acquisition/ourStory/fuji/desktop/tv.png" alt="TV" className="relative z-10 w-full" />
            <video className="absolute top-[20%] left-[13%] w-[73%] z-0" autoPlay playsInline muted loop>
              <source src="https://assets.nflxext.com/ffe/siteui/acquisition/ourStory/fuji/desktop/video-tv-0819.m4v" type="video/mp4" />
            </video>
          </div>
        </div>
      </div>

      {/* Feature 2: Download */}
      <div className="bg-black py-16 md:py-24 px-4 md:px-32 border-b-8 border-[#232323]">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row-reverse items-center justify-between gap-8">
          <div className="flex-1 text-center md:text-left z-10">
            <h2 className="text-3xl md:text-5xl font-black mb-6">Download your shows to watch offline</h2>
            <p className="text-lg md:text-2xl font-medium">
              Save your favorites easily and always have something to watch.
            </p>
          </div>
          <div className="flex-1 relative">
            <img src="https://assets.nflxext.com/ffe/siteui/acquisition/ourStory/fuji/desktop/mobile-0819.jpg" alt="Mobile" className="w-full" />
            <div className="absolute bottom-[8%] left-[20%] right-[20%] bg-black border-2 border-neutral-700 rounded-xl p-3 flex items-center gap-4 shadow-xl z-20">
              <img src="https://assets.nflxext.com/ffe/siteui/acquisition/ourStory/fuji/desktop/boxshot.png" alt="Stranger Things" className="h-16 md:h-20" />
              <div className="text-left flex-1">
                <div className="text-white font-semibold text-sm md:text-base">Stranger Things</div>
                <div className="text-blue-600 text-xs md:text-sm font-medium">Downloading...</div>
              </div>
              <div className="w-12 h-12 bg-[url('https://assets.nflxext.com/ffe/siteui/acquisition/ourStory/fuji/desktop/download-icon.gif')] bg-cover"></div>
            </div>
          </div>
        </div>
      </div>

      {/* Feature 3: Everywhere */}
      <div className="bg-black py-16 md:py-24 px-4 md:px-32 border-b-8 border-[#232323]">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-8">
          <div className="flex-1 text-center md:text-left z-10">
            <h2 className="text-3xl md:text-5xl font-black mb-6">Watch everywhere</h2>
            <p className="text-lg md:text-2xl font-medium">
              Stream unlimited movies and TV shows on your phone, tablet, laptop, and TV.
            </p>
          </div>
          <div className="flex-1 relative">
            <img src="https://assets.nflxext.com/ffe/siteui/acquisition/ourStory/fuji/desktop/device-pile.png" alt="Devices" className="relative z-10 w-full" />
            <video className="absolute top-[10%] left-[18%] w-[63%] z-0" autoPlay playsInline muted loop>
              <source src="https://assets.nflxext.com/ffe/siteui/acquisition/ourStory/fuji/desktop/video-devices.m4v" type="video/mp4" />
            </video>
          </div>
        </div>
      </div>

      {/* Feature 4: Kids */}
      <div className="bg-black py-16 md:py-24 px-4 md:px-32 border-b-8 border-[#232323]">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row-reverse items-center justify-between gap-8">
          <div className="flex-1 text-center md:text-left z-10">
            <h2 className="text-3xl md:text-5xl font-black mb-6">Create profiles for kids</h2>
            <p className="text-lg md:text-2xl font-medium">
              Send kids on adventures with their favorite characters in a space made just for them—free with your membership.
            </p>
          </div>
          <div className="flex-1">
<img
            src="https://occ-0-58-64.1.nflxso.net/dnm/api/v6/19OhWN2dO19C9txTON9tvTFtefw/AAAABVr8nYuAg0xDpXDv0VI9HUoH7r2aGp4TKRCsKNQrMwxzTtr-NlwOHeS8bCI2oeZddmu3nMYr3j9MjYhHyjBASb1FaOGYZNYvPBCL.png?r=54d"
            alt="Kids profile"
            className="w-full" />          </div>
        </div>
      </div>

      {/* FAQ Section */}
      <div className="bg-black py-16 md:py-24 font-[Sans] px-4 md:px-32 border-b-8 border-[#232323]">
        <div className="w-[94%] mx-auto">
          <h2 className="text-lg  md:text-3xl font-extralight mb-4">Frequently Asked Questions</h2>
          <div className="flex flex-col gap-2 mb-12">
            {faqs.map((faq, index) => (
              <div key={index} className="bg-[#2D2D2D] hover:bg-[#414141] transition-colors duration-200">
                <button
                  onClick={() => setOpenIndex(openIndex === index ? null : index)}
                  className="w-full text-left px-6 py-6 text-xl md:text-2xl font-medium flex justify-between items-center"
                >
                  {faq.question}
                  <svg
                    className={`w-8 h-8 transform transition-transform duration-300 ${openIndex === index ? "rotate-45" : ""}`}
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                  </svg>
                </button>
                {openIndex === index && (
                  <div className="px-6 pb-6 text-lg md:text-xl border-t-[1px] border-black bg-[#2D2D2D]">
                    <div className="pt-6 whitespace-pre-wrap leading-tight">{faq.answer}</div>
                  </div>
                )}
              </div>
            ))}
          </div>

          <div className="text-center mt-16">
            <p className="text-white text-[15px] md:text-[16px] mb-4 font-normal">
              Ready to watch? Enter your email to create or restart your membership.
            </p>
            <div className="flex flex-col md:flex-row justify-center gap-2 w-full max-w-3xl mx-auto">
              <input
                type="email"
                placeholder="Email address"
                className="flex-1 bg-black/50 border border-neutral-500 rounded px-4 py-3 lg:py-4 text-white placeholder-neutral-400 focus:outline-none focus:border-white focus:ring-1 focus:ring-white transition-all text-lg"
              />
              <button className="bg-[#E50914] text-[22px] md:text-[25px] text-white w-[60%] md:w-[28%] px-0 md:px-6 py-1 lg:py-3 rounded  font-extralight hover:bg-[#C11119] transition-colors flex items-center justify-center gap-2">
                Get Started
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Footer Section */}
      <footer className="bg-black text-[#ffffffb3] py-16 px-6 md:px-32 text-sm font-medium">
        <div className="max-w-5xl mx-auto">
          <p className="mb-8 hover:underline cursor-pointer text-base">Questions? Contact us.</p>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-y-4 gap-x-8 mb-10">
            <a className="hover:underline" href="#">FAQ</a>
            <a className="hover:underline" href="#">Help Center</a>
            <a className="hover:underline" href="#">Account</a>
            <a className="hover:underline" href="#">Media Center</a>
            <a className="hover:underline" href="#">Investor Relations</a>
            <a className="hover:underline" href="#">Jobs</a>
            <a className="hover:underline" href="#">Ways to Watch</a>
            <a className="hover:underline" href="#">Terms of Use</a>
            <a className="hover:underline" href="#">Privacy</a>
            <a className="hover:underline" href="#">Cookie Preferences</a>
            <a className="hover:underline" href="#">Corporate Information</a>
            <a className="hover:underline" href="#">Contact Us</a>
            <a className="hover:underline" href="#">Speed Test</a>
            <a className="hover:underline" href="#">Legal Notices</a>
            <a className="hover:underline" href="#">Only on Netflix</a>
          </div>
          <div className="mb-6 inline-block relative">
             <select className="bg-black/50 border border-neutral-500 text-white px-6 py-2 rounded text-sm font-medium focus:ring-2 focus:ring-white focus:outline-none appearance-none cursor-pointer w-32">
              <option>English</option>
            </select>
          </div>
          <p className="text-sm">Netflix Pakistan</p>
          <p className="mt-4 mb-12 text-gray-500 text-[13px]">This page is protected by Google reCAPTCHA to ensure you're not a bot.</p>
        </div>
      </footer>
    </div>
  );
}