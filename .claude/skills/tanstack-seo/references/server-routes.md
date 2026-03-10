# Server Routes & Static Files

Non-HTML server routes for SEO infrastructure: sitemap, robots.txt, llms.txt, and web manifest.

## Dynamic Sitemap — `src/routes/sitemap[.]xml.ts`

Generates a standard XML sitemap. Adapt `staticRoutes` and `dynamicRoutes` to your project's pages.

```typescript
import { createFileRoute } from "@tanstack/react-router";

import { siteConfig } from "@/lib/seo";

interface SitemapRoute {
  url: string;
  priority: string;
  changefreq: string;
  lastmod?: string;
}

function generateSitemap(): string {
  // CUSTOMIZE: Add all your static routes with appropriate priorities
  const staticRoutes: SitemapRoute[] = [
    { url: "/", priority: "1.0", changefreq: "weekly" },
    { url: "/blog", priority: "0.9", changefreq: "daily" },
    { url: "/pricing", priority: "0.8", changefreq: "monthly" },
    { url: "/about", priority: "0.5", changefreq: "monthly" },
    { url: "/login", priority: "0.3", changefreq: "yearly" },
  ];

  // CUSTOMIZE: Add dynamic routes from your CMS / content collections.
  // Example with content-collections:
  //
  // import { allBlogs } from "content-collections";
  // const blogRoutes: SitemapRoute[] = allBlogs.map((post) => ({
  //   url: `/blog/${post.slug}`,
  //   priority: "0.8",
  //   changefreq: "monthly",
  //   lastmod: new Date(post.date).toISOString().split("T")[0],
  // }));

  const dynamicRoutes: SitemapRoute[] = [];

  const allRoutes: SitemapRoute[] = [...staticRoutes, ...dynamicRoutes];

  const urls = allRoutes
    .map(
      (route) => `  <url>
    <loc>${siteConfig.url}${route.url}</loc>
    <changefreq>${route.changefreq}</changefreq>
    <priority>${route.priority}</priority>${route.lastmod ? `\n    <lastmod>${route.lastmod}</lastmod>` : ""}
  </url>`,
    )
    .join("\n");

  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;
}

export const Route = createFileRoute("/sitemap.xml")({
  server: {
    handlers: {
      GET: () => {
        return new Response(generateSitemap(), {
          headers: {
            "Content-Type": "application/xml",
            "Cache-Control": "public, max-age=3600",
          },
        });
      },
    },
  },
});
```

### Priority Guidelines

| Route Type | Priority | Changefreq |
|---|---|---|
| Homepage | 1.0 | weekly |
| Blog/content index | 0.9 | daily |
| Product/pricing pages | 0.8 | monthly |
| Individual blog posts | 0.8 | monthly |
| Individual doc pages | 0.7 | monthly |
| About/info pages | 0.5 | monthly |
| Login/auth pages | 0.3 | yearly |

## Robots.txt — `public/robots.txt`

Static file. Place in `public/` directory.

```
# CUSTOMIZE: Replace yoursite.com with your production domain
# robots.txt
# https://www.robotstxt.org/

User-agent: *
Allow: /

# Disallow private/authenticated routes
# CUSTOMIZE: Add your protected route prefixes
Disallow: /dashboard
Disallow: /dashboard/*
Disallow: /account/*
Disallow: /settings
Disallow: /settings/*
Disallow: /api/

# Sitemaps
# CUSTOMIZE: Replace with your production domain
Sitemap: https://yoursite.com/sitemap.xml

# LLM content (optional — remove if you don't implement llms.txt)
Allow: /llms.txt
Allow: /llms-full.txt
```

## LLM Content Routes

Following the [llms.txt proposal](https://llmstxt.org/) for AI crawler discoverability. These are optional but increasingly valuable as AI-powered search grows.

### Concise Summary — `src/routes/llms[.]txt.ts`

```typescript
import { createFileRoute } from "@tanstack/react-router";

import { generateLLMSummary } from "@/lib/seo";

export const Route = createFileRoute("/llms.txt")({
  server: {
    handlers: {
      GET: () => {
        return new Response(generateLLMSummary(), {
          headers: {
            "Content-Type": "text/plain; charset=utf-8",
            "Cache-Control": "public, max-age=86400",
          },
        });
      },
    },
  },
});
```

### Full Content — `src/routes/llms-full[.]txt.ts`

```typescript
import { createFileRoute } from "@tanstack/react-router";
// import { allBlogs } from "content-collections"; // If using content-collections

import { generateLLMFullContent } from "@/lib/seo";

export const Route = createFileRoute("/llms-full.txt")({
  server: {
    handlers: {
      GET: () => {
        // CUSTOMIZE: Pull your actual content here
        const docs: Array<{
          title: string;
          description: string;
          content: string;
          slug: string;
        }> = [];

        const blogs: Array<{
          title: string;
          description: string;
          content: string;
          slug: string;
          date: string;
        }> = [];

        // Example with content-collections:
        // const blogs = allBlogs.map((post) => ({
        //   title: post.title,
        //   description: post.description,
        //   content: post.content,
        //   slug: post.slug,
        //   date: post.date,
        // }));

        return new Response(generateLLMFullContent(docs, blogs), {
          headers: {
            "Content-Type": "text/plain; charset=utf-8",
            "Cache-Control": "public, max-age=86400",
          },
        });
      },
    },
  },
});
```

## Web Manifest — `public/site.webmanifest`

For PWA support and "Add to Home Screen".

```json
{
  "name": "Your App",
  "short_name": "App",
  "icons": [
    {
      "src": "/web-app-manifest-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "/web-app-manifest-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ],
  "theme_color": "#d9d9d9",
  "background_color": "#ffffff",
  "display": "standalone"
}
```

## Favicon Checklist

Place these in `public/`:

| File | Purpose |
|---|---|
| `favicon.svg` | Modern browsers (scalable, dark mode support via CSS media queries) |
| `favicon-96x96.png` | PNG fallback |
| `favicon.ico` | Legacy browser support |
| `apple-touch-icon.png` | iOS home screen (180x180) |
| `web-app-manifest-192x192.png` | Android PWA icon |
| `web-app-manifest-512x512.png` | Android PWA splash |

Generate all sizes from a single source SVG using [realfavicongenerator.net](https://realfavicongenerator.net/) or [favicon.io](https://favicon.io/).
