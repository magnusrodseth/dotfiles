# SEO Utilities — `src/lib/seo.ts`

Complete implementation. Adapt `siteConfig` values and schema generators to the project.

```typescript
/**
 * SEO Utilities
 *
 * Centralized meta tags, Open Graph, Twitter Cards, structured data (JSON-LD),
 * canonical URLs, and LLM optimization helpers.
 */

import { brand } from "@/lib/brand";

// =============================================================================
// Site Configuration — UPDATE THESE VALUES FOR YOUR PROJECT
// =============================================================================

export const siteConfig = {
  name: brand.name,
  shortName: brand.shortName,
  description: brand.description,
  url: "https://yoursite.com", // Production URL, no trailing slash
  ogImage: "/og.png",
  twitterHandle: brand.social.twitter,
  githubUrl: brand.social.github,
  author: brand.author,
  keywords: brand.keywords,
} as const;

// =============================================================================
// Types
// =============================================================================

export interface PageSEO {
  title: string;
  description: string;
  canonical?: string;
  noindex?: boolean;
  ogImage?: string;
  ogType?: "website" | "article";
  publishedTime?: string;
  modifiedTime?: string;
  author?: string;
  tags?: string[];
}

export interface ArticleSEO extends PageSEO {
  ogType: "article";
  publishedTime: string;
  author: string;
}

// =============================================================================
// URL Helpers
// =============================================================================

export function getAbsoluteUrl(path: string): string {
  const base = siteConfig.url.replace(/\/$/, "");
  const cleanPath = path.startsWith("/") ? path : `/${path}`;
  return `${base}${cleanPath}`;
}

export function getCanonicalUrl(path: string): string {
  return getAbsoluteUrl(path);
}

export function getOGImageUrl(title: string, description?: string): string {
  const params = new URLSearchParams({ title });
  if (description) {
    params.set("description", description);
  }
  return getAbsoluteUrl(`/og.png?${params.toString()}`);
}

function resolveOGImageUrl(ogImage?: string): string {
  const image = ogImage || siteConfig.ogImage;
  if (image.startsWith("http")) return image;
  return getAbsoluteUrl(image);
}

// =============================================================================
// Meta Tag Generators
// =============================================================================

export function generateMetaTags(seo: PageSEO) {
  const title = seo.title.includes(siteConfig.name)
    ? seo.title
    : `${seo.title} | ${siteConfig.name}`;

  const meta: Array<Record<string, string>> = [
    { title },
    { name: "description", content: seo.description },
  ];

  if (seo.noindex) {
    meta.push({ name: "robots", content: "noindex, nofollow" });
  }

  const keywords = [...siteConfig.keywords, ...(seo.tags || [])];
  if (keywords.length > 0) {
    meta.push({ name: "keywords", content: keywords.join(", ") });
  }

  // Open Graph
  meta.push(
    { property: "og:type", content: seo.ogType || "website" },
    { property: "og:site_name", content: siteConfig.name },
    { property: "og:title", content: title },
    { property: "og:description", content: seo.description },
    { property: "og:url", content: seo.canonical || siteConfig.url },
    { property: "og:image", content: resolveOGImageUrl(seo.ogImage) },
    { property: "og:image:alt", content: title },
  );

  // Article-specific OG tags
  if (seo.ogType === "article") {
    if (seo.publishedTime) {
      meta.push({ property: "article:published_time", content: seo.publishedTime });
    }
    if (seo.modifiedTime) {
      meta.push({ property: "article:modified_time", content: seo.modifiedTime });
    }
    if (seo.author) {
      meta.push({ property: "article:author", content: seo.author });
    }
    seo.tags?.forEach((tag) => {
      meta.push({ property: "article:tag", content: tag });
    });
  }

  // Twitter Cards
  meta.push(
    { name: "twitter:card", content: "summary_large_image" },
    { name: "twitter:site", content: siteConfig.twitterHandle },
    { name: "twitter:title", content: title },
    { name: "twitter:description", content: seo.description },
    { name: "twitter:image", content: resolveOGImageUrl(seo.ogImage) },
  );

  return meta;
}

export function generateLinkTags(seo: PageSEO) {
  const links: Array<Record<string, string>> = [];
  if (seo.canonical) {
    links.push({ rel: "canonical", href: seo.canonical });
  }
  return links;
}

/**
 * Primary function used by every route's head().
 * Returns { meta, links } ready for TanStack Router.
 */
export function generateHead(seo: PageSEO) {
  return {
    meta: generateMetaTags(seo),
    links: generateLinkTags(seo),
  };
}

// =============================================================================
// Structured Data (JSON-LD)
// =============================================================================

export function generateOrganizationSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: siteConfig.name,
    url: siteConfig.url,
    logo: getAbsoluteUrl("/logo.svg"),
    sameAs: [siteConfig.githubUrl],
    description: siteConfig.description,
  };
}

export function generateWebSiteSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: siteConfig.name,
    url: siteConfig.url,
    description: siteConfig.description,
    publisher: {
      "@type": "Organization",
      name: siteConfig.name,
    },
  };
}

export function generateArticleSchema(article: {
  title: string;
  description: string;
  url: string;
  publishedTime: string;
  modifiedTime?: string;
  author: string;
  image?: string;
  tags?: string[];
}) {
  return {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: article.title,
    description: article.description,
    url: article.url,
    datePublished: article.publishedTime,
    dateModified: article.modifiedTime || article.publishedTime,
    author: { "@type": "Person", name: article.author },
    publisher: {
      "@type": "Organization",
      name: siteConfig.name,
      logo: { "@type": "ImageObject", url: getAbsoluteUrl("/logo.svg") },
    },
    image: article.image
      ? getAbsoluteUrl(article.image)
      : getAbsoluteUrl(siteConfig.ogImage),
    keywords: article.tags?.join(", "),
    mainEntityOfPage: { "@type": "WebPage", "@id": article.url },
  };
}

export function generateBreadcrumbSchema(
  items: Array<{ name: string; url: string }>,
) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.name,
      item: item.url,
    })),
  };
}

export function generateFAQSchema(
  faqs: Array<{ question: string; answer: string }>,
) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.question,
      acceptedAnswer: { "@type": "Answer", text: faq.answer },
    })),
  };
}

export function generateSoftwareSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "SoftwareSourceCode",
    name: siteConfig.name,
    description: siteConfig.description,
    url: siteConfig.url,
    codeRepository: siteConfig.githubUrl,
    programmingLanguage: ["TypeScript", "JavaScript"],
    runtimePlatform: ["Bun", "Node.js"],
    author: { "@type": "Person", name: siteConfig.author.name, url: siteConfig.author.url },
    license: "https://opensource.org/licenses/MIT",
  };
}

export function generateJsonLdScript(data: object | object[]): string {
  return `<script type="application/ld+json">${JSON.stringify(data)}</script>`;
}

// =============================================================================
// LLM Optimization Helpers (for llms.txt / llms-full.txt)
// =============================================================================

export function generateLLMSummary(): string {
  return `# ${siteConfig.name}

> ${siteConfig.description}

${siteConfig.name} key features:
- Feature 1
- Feature 2
- Feature 3

## Documentation
- /docs - Full documentation
- /blog - Blog posts

## Source Code
${siteConfig.githubUrl}
`;
}

export function generateLLMFullContent(
  docs: Array<{ title: string; description: string; content: string; slug: string }>,
  blogs: Array<{ title: string; description: string; content: string; slug: string; date: string }>,
): string {
  let content = `# ${siteConfig.name} - Complete Documentation\n\n> ${siteConfig.description}\n\n---\n\n`;

  if (docs.length > 0) {
    content += `## Documentation\n\n`;
    for (const doc of docs) {
      content += `### ${doc.title}\n\n${doc.description}\n\n${doc.content}\n\n---\n\n`;
    }
  }

  if (blogs.length > 0) {
    content += `## Blog Posts\n\n`;
    for (const blog of blogs) {
      content += `### ${blog.title}\n\n*Published: ${blog.date}*\n\n${blog.description}\n\n${blog.content}\n\n---\n\n`;
    }
  }

  content += `\n## Links\n\n- Website: ${siteConfig.url}\n- GitHub: ${siteConfig.githubUrl}\n`;
  return content;
}
```

## Customization Notes

- Replace `siteConfig.url` with the production domain
- Remove `generateSoftwareSchema()` if not applicable (it's for open-source code projects)
- Add/remove schema generators as needed — only include what matches your content types
- The `generateLLMSummary()` function should be customized with actual feature descriptions
- `sameAs` in Organization schema can include additional social profile URLs
