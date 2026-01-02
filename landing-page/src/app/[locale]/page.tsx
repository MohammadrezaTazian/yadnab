"use client";

import { useTranslations, useLocale } from "next-intl";
import Link from "next/link";
import { useState } from "react";

// Icons as SVG components
const VideoIcon = () => (
    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
);

const QuizIcon = () => (
    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
    </svg>
);

const BookIcon = () => (
    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
    </svg>
);

const ChartIcon = () => (
    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
    </svg>
);

const MobileIcon = () => (
    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
    </svg>
);

const SupportIcon = () => (
    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z" />
    </svg>
);

const iconMap: Record<string, () => JSX.Element> = {
    video: VideoIcon,
    quiz: QuizIcon,
    book: BookIcon,
    chart: ChartIcon,
    mobile: MobileIcon,
    support: SupportIcon,
};

export default function LandingPage() {
    const t = useTranslations();
    const locale = useLocale();
    const isRtl = locale === "fa";
    const [openFaq, setOpenFaq] = useState<number | null>(null);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

    const appUrl = "http://localhost:5200"; // Change this to your Flutter app URL

    return (
        <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
            {/* Navigation */}
            <nav className="fixed top-0 left-0 right-0 z-50 bg-slate-900/80 backdrop-blur-lg border-b border-white/10">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center justify-between h-16">
                        <div className="flex items-center gap-2">
                            <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                                <span className="text-white font-bold text-xl">📚</span>
                            </div>
                            <span className="text-white font-bold text-lg">Education App</span>
                        </div>

                        {/* Desktop Nav */}
                        <div className="hidden md:flex items-center gap-8">
                            <a href="#features" className="text-gray-300 hover:text-white transition">{t("nav.features")}</a>
                            <a href="#testimonials" className="text-gray-300 hover:text-white transition">{t("nav.testimonials")}</a>
                            <a href="#faq" className="text-gray-300 hover:text-white transition">{t("nav.faq")}</a>

                            {/* Language Switcher */}
                            <div className="flex items-center gap-2 bg-white/10 rounded-full p-1">
                                <Link
                                    href="/fa"
                                    className={`px-3 py-1 rounded-full text-sm transition ${locale === "fa" ? "bg-white text-purple-900 font-bold" : "text-gray-300"}`}
                                >
                                    فا
                                </Link>
                                <Link
                                    href="/en"
                                    className={`px-3 py-1 rounded-full text-sm transition ${locale === "en" ? "bg-white text-purple-900 font-bold" : "text-gray-300"}`}
                                >
                                    EN
                                </Link>
                            </div>

                            <a
                                href={appUrl}
                                className="px-5 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full font-medium hover:opacity-90 transition"
                            >
                                {t("nav.register")}
                            </a>
                        </div>

                        {/* Mobile menu button */}
                        <button
                            className="md:hidden text-white"
                            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                        >
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                            </svg>
                        </button>
                    </div>
                </div>

                {/* Mobile Menu */}
                {mobileMenuOpen && (
                    <div className="md:hidden bg-slate-900/95 border-t border-white/10 p-4">
                        <div className="flex flex-col gap-4">
                            <a href="#features" className="text-gray-300">{t("nav.features")}</a>
                            <a href="#testimonials" className="text-gray-300">{t("nav.testimonials")}</a>
                            <a href="#faq" className="text-gray-300">{t("nav.faq")}</a>
                            <div className="flex items-center gap-2">
                                <Link href="/fa" className={`px-3 py-1 rounded-full text-sm ${locale === "fa" ? "bg-purple-500 text-white" : "text-gray-300"}`}>فا</Link>
                                <Link href="/en" className={`px-3 py-1 rounded-full text-sm ${locale === "en" ? "bg-purple-500 text-white" : "text-gray-300"}`}>EN</Link>
                            </div>
                            <a href={appUrl} className="px-5 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full text-center font-medium">
                                {t("nav.register")}
                            </a>
                        </div>
                    </div>
                )}
            </nav>

            {/* Hero Section */}
            <section className="pt-32 pb-20 px-4">
                <div className="max-w-7xl mx-auto text-center">
                    <div className="inline-block px-4 py-2 bg-purple-500/20 rounded-full text-purple-300 text-sm mb-6">
                        {t("hero.badge")}
                    </div>

                    <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold text-white mb-6">
                        {t("hero.title")}{" "}
                        <span className="text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-400">
                            {t("hero.titleHighlight")}
                        </span>
                    </h1>

                    <p className="text-lg md:text-xl text-gray-300 max-w-3xl mx-auto mb-10">
                        {t("hero.description")}
                    </p>

                    <div className="flex flex-col sm:flex-row gap-4 justify-center mb-16">
                        <a
                            href={appUrl}
                            className="px-8 py-4 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full text-lg font-bold hover:scale-105 transition-transform shadow-lg shadow-purple-500/25"
                        >
                            {t("hero.cta")}
                        </a>
                        <button className="px-8 py-4 bg-white/10 text-white rounded-full text-lg font-medium hover:bg-white/20 transition border border-white/20">
                            {t("hero.secondaryCta")}
                        </button>
                    </div>

                    {/* Stats */}
                    <div className="grid grid-cols-3 gap-8 max-w-2xl mx-auto">
                        <div className="text-center">
                            <div className="text-3xl md:text-4xl font-bold text-white mb-1">{t("hero.stats.students")}</div>
                            <div className="text-gray-400 text-sm">{t("hero.stats.studentsLabel")}</div>
                        </div>
                        <div className="text-center">
                            <div className="text-3xl md:text-4xl font-bold text-white mb-1">{t("hero.stats.videos")}</div>
                            <div className="text-gray-400 text-sm">{t("hero.stats.videosLabel")}</div>
                        </div>
                        <div className="text-center">
                            <div className="text-3xl md:text-4xl font-bold text-white mb-1">{t("hero.stats.questions")}</div>
                            <div className="text-gray-400 text-sm">{t("hero.stats.questionsLabel")}</div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section id="features" className="py-20 px-4 bg-black/20">
                <div className="max-w-7xl mx-auto">
                    <div className="text-center mb-16">
                        <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">{t("features.title")}</h2>
                        <p className="text-gray-400 text-lg">{t("features.subtitle")}</p>
                    </div>

                    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {[0, 1, 2, 3, 4, 5].map((index) => {
                            const iconKey = t(`features.items.${index}.icon`);
                            const IconComponent = iconMap[iconKey] || VideoIcon;
                            return (
                                <div
                                    key={index}
                                    className="p-6 bg-white/5 rounded-2xl border border-white/10 hover:border-purple-500/50 transition group"
                                >
                                    <div className="w-14 h-14 bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-xl flex items-center justify-center text-purple-400 mb-4 group-hover:scale-110 transition">
                                        <IconComponent />
                                    </div>
                                    <h3 className="text-xl font-bold text-white mb-2">{t(`features.items.${index}.title`)}</h3>
                                    <p className="text-gray-400">{t(`features.items.${index}.description`)}</p>
                                </div>
                            );
                        })}
                    </div>
                </div>
            </section>

            {/* Testimonials Section */}
            <section id="testimonials" className="py-20 px-4">
                <div className="max-w-7xl mx-auto">
                    <h2 className="text-3xl md:text-4xl font-bold text-white text-center mb-16">{t("testimonials.title")}</h2>

                    <div className="grid md:grid-cols-3 gap-8">
                        {[0, 1, 2].map((index) => (
                            <div
                                key={index}
                                className="p-6 bg-gradient-to-br from-white/10 to-white/5 rounded-2xl border border-white/10"
                            >
                                <div className="flex items-center gap-4 mb-4">
                                    <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold">
                                        {t(`testimonials.items.${index}.name`).charAt(0)}
                                    </div>
                                    <div>
                                        <div className="text-white font-medium">{t(`testimonials.items.${index}.name`)}</div>
                                        <div className="text-purple-400 text-sm">{t(`testimonials.items.${index}.role`)}</div>
                                    </div>
                                </div>
                                <p className="text-gray-300 leading-relaxed">"{t(`testimonials.items.${index}.content`)}"</p>
                                <div className="flex gap-1 mt-4">
                                    {[1, 2, 3, 4, 5].map((star) => (
                                        <svg key={star} className="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                                        </svg>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* FAQ Section */}
            <section id="faq" className="py-20 px-4 bg-black/20">
                <div className="max-w-3xl mx-auto">
                    <h2 className="text-3xl md:text-4xl font-bold text-white text-center mb-16">{t("faq.title")}</h2>

                    <div className="space-y-4">
                        {[0, 1, 2, 3].map((index) => (
                            <div
                                key={index}
                                className="bg-white/5 rounded-xl border border-white/10 overflow-hidden"
                            >
                                <button
                                    className="w-full px-6 py-4 flex items-center justify-between text-left"
                                    onClick={() => setOpenFaq(openFaq === index ? null : index)}
                                >
                                    <span className="text-white font-medium">{t(`faq.items.${index}.question`)}</span>
                                    <svg
                                        className={`w-5 h-5 text-purple-400 transition-transform ${openFaq === index ? "rotate-180" : ""}`}
                                        fill="none"
                                        stroke="currentColor"
                                        viewBox="0 0 24 24"
                                    >
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                    </svg>
                                </button>
                                {openFaq === index && (
                                    <div className="px-6 pb-4 text-gray-400">
                                        {t(`faq.items.${index}.answer`)}
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* CTA Section */}
            <section className="py-20 px-4">
                <div className="max-w-4xl mx-auto text-center">
                    <div className="p-12 bg-gradient-to-r from-purple-600/20 to-pink-600/20 rounded-3xl border border-purple-500/30">
                        <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">{t("cta.title")}</h2>
                        <p className="text-gray-300 text-lg mb-8">{t("cta.description")}</p>
                        <a
                            href={appUrl}
                            className="inline-block px-10 py-4 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full text-lg font-bold hover:scale-105 transition-transform shadow-lg shadow-purple-500/25"
                        >
                            {t("cta.button")}
                        </a>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer className="py-12 px-4 border-t border-white/10">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col md:flex-row items-center justify-between gap-6">
                        <div className="flex items-center gap-2">
                            <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                                <span className="text-white font-bold text-xl">📚</span>
                            </div>
                            <div>
                                <span className="text-white font-bold">Education App</span>
                                <p className="text-gray-500 text-sm">{t("footer.description")}</p>
                            </div>
                        </div>

                        <div className="flex gap-6 text-gray-400 text-sm">
                            <a href="#" className="hover:text-white transition">{t("footer.links.about")}</a>
                            <a href="#" className="hover:text-white transition">{t("footer.links.contact")}</a>
                            <a href="#" className="hover:text-white transition">{t("footer.links.privacy")}</a>
                            <a href="#" className="hover:text-white transition">{t("footer.links.terms")}</a>
                        </div>
                    </div>

                    <div className="text-center text-gray-500 text-sm mt-8">
                        {t("footer.copyright")}
                    </div>
                </div>
            </footer>
        </div>
    );
}
