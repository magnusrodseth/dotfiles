# Route Patterns

How to wire up SEO in the root layout and individual routes.

## Root Layout — `src/routes/__root.tsx`

The root layout provides defaults inherited by every page. Child routes override via their own `head()`.

```typescript
import {
  HeadContent,
  Outlet,
  Scripts,
  createRootRoute,
} from "@tanstack/react-router";
import type { ReactNode } from "react";

import {
  siteConfig,
  getAbsoluteUrl,
  generateOrganizationSchema,
  generateWebSiteSchema,
} from "@/lib/seo";

// Pre-compute site-wide structured data (runs once at module load)
const structuredData = [
  generateOrganizationSchema(),
  generateWebSiteSchema(),
];

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: siteConfig.name },
      { name: "description", content: siteConfig.description },
      { name: "keywords", content: siteConfig.keywords.join(", ") },
      { name: "author", content: siteConfig.author.name },
      { name: "apple-mobile-web-app-title", content: siteConfig.shortName },
      // Default Open Graph (overridden by child routes)
      { property: "og:type", content: "website" },
      { property: "og:site_name", content: siteConfig.name },
      { property: "og:image", content: getAbsoluteUrl(siteConfig.ogImage) },
      { property: "og:locale", content: "en_US" },
      // Default Twitter Card
      { name: "twitter:card", content: "summary_large_image" },
      { name: "twitter:site", content: siteConfig.twitterHandle },
      { name: "twitter:image", content: getAbsoluteUrl(siteConfig.ogImage) },
      // PWA
      { name: "theme-color", content: "#ffffff" },
    ],
    links: [
      // Favicons — CUSTOMIZE paths to match your files in public/
      { rel: "icon", type: "image/png", href: "/favicon-96x96.png", sizes: "96x96" },
      { rel: "icon", type: "image/svg+xml", href: "/favicon.svg" },
      { rel: "shortcut icon", href: "/favicon.ico" },
      { rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png" },
      { rel: "manifest", href: "/site.webmanifest" },
    ],
    scripts: [
      {
        type: "application/ld+json",
        children: JSON.stringify(structuredData),
      },
    ],
  }),
  component: RootComponent,
});

function RootComponent() {
  return (
    <html lang="en">
      <head>
        <HeadContent />
      </head>
      <body>
        <Outlet />
        <Scripts />
      </body>
    </html>
  );
}
```

Key points:
- `<html lang="en">` is set here, not in a separate HTML file
- `HeadContent` renders all meta/link/script tags from `head()` functions
- Site-wide JSON-LD (Organization + WebSite) is injected once at the root
- Child routes merge/override these defaults via their own `head()` return

## Per-Route Patterns

### Pattern 1: Static Page (minimal — no custom OG image)

For simple pages where the default OG image is fine.

```typescript
import { createFileRoute } from "@tanstack/react-router";

import { generateHead, getCanonicalUrl, siteConfig } from "@/lib/seo";

export const Route = createFileRoute("/pricing")({
  head: () =>
    generateHead({
      title: "Pricing",
      description: `Simple, transparent pricing for ${siteConfig.name}.`,
      canonical: getCanonicalUrl("/pricing"),
    }),
  component: PricingPage,
});
```

- `generateHead()` returns `{ meta, links }` with OG, Twitter, canonical
- Title auto-suffixed to `"Pricing | Your App"` by `generateMetaTags()`
- Uses default `/og.png` (no query params) for OG image

### Pattern 2: Static Page with Custom OG Image

For important pages that should have a unique social preview.

```typescript
import { createFileRoute } from "@tanstack/react-router";

import {
  siteConfig,
  getCanonicalUrl,
  getOGImageUrl,
  generateHead,
  generateSoftwareSchema,
} from "@/lib/seo";

export const Route = createFileRoute("/")({
  head: () => {
    const title = `${siteConfig.name} - Your Tagline Here`;
    const description = "Your homepage description for SEO and social sharing.";
    const seo = generateHead({
      title,
      description,
      canonical: getCanonicalUrl("/"),
      ogType: "website",
      ogImage: getOGImageUrl(title, description), // Dynamic OG image
    });

    return {
      ...seo,
      // Optional: page-specific structured data
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(generateSoftwareSchema()),
        },
      ],
    };
  },
  component: HomePage,
});
```

- `getOGImageUrl(title, description)` → `https://yoursite.com/og.png?title=...&description=...`
- Spread `...seo` then add `scripts` for page-specific JSON-LD
- `generateSoftwareSchema()` is just one example — use whichever schema fits the page

### Pattern 3: Dynamic Page (blog post, doc page)

For content pages where title/description come from a loader.

```typescript
import { createFileRoute, notFound } from "@tanstack/react-router";
// import { allBlogs } from "content-collections"; // Or your data source

import {
  getCanonicalUrl,
  getOGImageUrl,
  generateHead,
  generateArticleSchema,
  generateBreadcrumbSchema,
  siteConfig,
} from "@/lib/seo";

export const Route = createFileRoute("/blog/$slug")({
  loader: ({ params }) => {
    const post = allBlogs.find((p) => p.slug === params.slug);
    if (!post) throw notFound();
    return { post };
  },
  head: ({ loaderData }) => {
    if (!loaderData) return {};
    const { post } = loaderData;
    const url = getCanonicalUrl(`/blog/${post.slug}`);

    const seo = generateHead({
      title: post.title,
      description: post.description,
      canonical: url,
      ogType: "article",
      ogImage: getOGImageUrl(post.title, post.description),
      publishedTime: new Date(post.date).toISOString(),
      author: post.author,
      tags: post.tags,
    });

    const articleSchema = generateArticleSchema({
      title: post.title,
      description: post.description,
      url,
      publishedTime: new Date(post.date).toISOString(),
      author: post.author,
      tags: post.tags,
    });

    const breadcrumbSchema = generateBreadcrumbSchema([
      { name: "Home", url: siteConfig.url },
      { name: "Blog", url: getCanonicalUrl("/blog") },
      { name: post.title, url },
    ]);

    return {
      ...seo,
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(articleSchema),
        },
        {
          type: "application/ld+json",
          children: JSON.stringify(breadcrumbSchema),
        },
      ],
    };
  },
  component: BlogPostPage,
});
```

Key points:
- `ogType: "article"` triggers article-specific meta tags (`article:published_time`, `article:author`, `article:tag`)
- Article schema gives Google rich results for blog posts
- Breadcrumb schema shows navigation trail in SERPs (Home > Blog > Post Title)
- Guard `if (!loaderData) return {}` handles the case where the loader hasn't resolved yet

### Pattern 4: FAQ Page

For pages with question/answer content that should appear as FAQ rich results in Google.

```typescript
import { createFileRoute } from "@tanstack/react-router";

import {
  generateHead,
  generateFAQSchema,
  getCanonicalUrl,
} from "@/lib/seo";

const faqs = [
  {
    question: "What is your product?",
    answer: "A detailed answer about the product...",
  },
  {
    question: "How much does it cost?",
    answer: "Pricing details here...",
  },
  // ... more FAQs
];

export const Route = createFileRoute("/faq")({
  head: () => {
    const seo = generateHead({
      title: "Frequently Asked Questions",
      description: "Find answers to common questions about our product.",
      canonical: getCanonicalUrl("/faq"),
    });

    return {
      ...seo,
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(generateFAQSchema(faqs)),
        },
      ],
    };
  },
  component: FAQPage,
});
```

## Schema Selection Guide

| Page Type | Schemas to Include |
|---|---|
| Every page (root) | Organization + WebSite |
| Landing page | SoftwareSourceCode (if software product) |
| Blog post | Article + BreadcrumbList |
| Doc page | BreadcrumbList |
| FAQ page | FAQPage |
| Product page | Product (add your own generator) |

## End-to-End Flow Summary

```
1. Root layout sets: charset, viewport, default title/desc, default OG, favicons,
   Organization + WebSite JSON-LD

2. Each route's head() calls generateHead({ title, description, canonical, ... })
   → Returns { meta: [...], links: [...] }
   → Optionally spreads and adds scripts: [{ type: "application/ld+json", ... }]

3. Meta tags include og:image pointing to /og.png?title=...&description=...

4. When a social crawler fetches that URL:
   → og[.]png.ts server handler extracts query params
   → generateOGImage() renders JSX → SVG → PNG
   → Returns cached PNG response

5. Search engines see:
   → Canonical URL (prevents duplicate content)
   → Structured data (enables rich results)
   → Sitemap (discovers all pages)
   → robots.txt (knows what to crawl)
   → llms.txt (AI crawlers get structured content)
```
