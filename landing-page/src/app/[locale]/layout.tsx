import type { Metadata } from "next";
import localFont from "next/font/local";
import "../globals.css";
import { NextIntlClientProvider } from "next-intl";
import { getMessages, setRequestLocale } from "next-intl/server";
import { notFound } from "next/navigation";
import { locales } from "../../i18n";

const vazir = localFont({
    src: "../../fonts/Vazirmatn-RD-Regular.woff2",
    variable: "--font-vazir",
});

export function generateStaticParams() {
    return locales.map((locale) => ({ locale }));
}

export async function generateMetadata({
    params,
}: {
    params: { locale: string };
}): Promise<Metadata> {
    const { locale } = await params;
    const messages = await getMessages({ locale });
    const meta = messages.metadata as { title: string; description: string };

    return {
        title: meta.title,
        description: meta.description,
        openGraph: {
            title: meta.title,
            description: meta.description,
            locale: locale === "fa" ? "fa_IR" : "en_US",
            type: "website",
        },
        alternates: {
            languages: {
                fa: "/fa",
                en: "/en",
            },
        },
    };
}

export default async function LocaleLayout({
    children,
    params,
}: {
    children: React.ReactNode;
    params: Promise<{ locale: string }>;
}) {
    const { locale } = await params;

    // Enable static rendering
    setRequestLocale(locale);

    if (!locales.includes(locale as any)) {
        notFound();
    }

    const messages = await getMessages({ locale });
    const isRtl = locale === "fa";

    return (
        <html lang={locale} dir={isRtl ? "rtl" : "ltr"}>
            <body className={`${vazir.variable} font-sans antialiased`}>
                <script src="/config.js" defer></script>
                <NextIntlClientProvider messages={messages}>
                    {children}
                </NextIntlClientProvider>
            </body>
        </html>
    );
}
