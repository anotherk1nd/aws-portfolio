# Jekyll Setup Instructions

## File Structure

```
/workspaces/aws-portfolio/
├── _config.yml              ← Site settings
├── _layouts/
│   ├── default.html         ← Main layout (nav + footer)
│   └── post.html            ← Blog post layout
├── _posts/                  ← Put blog posts here
│   └── 2026-02-23-example.md
├── index.md                 ← Home page
├── about.md                 ← About page
├── projects.md              ← Projects page
├── blog.md                  ← Blog index (auto-generated)
├── contact.md               ← Contact page
├── Gemfile                  ← Jekyll dependencies
├── assets/                  ← Keep your CSS/JS (no changes)
├── images/                  ← Keep your images (no changes)
└── _site/                   ← Generated site (git ignore this)
```

---

## Step 1: Place Files

**Download all the Jekyll files and place them in your project:**

1. `_config.yml` → `/workspaces/aws-portfolio/_config.yml`
2. `_layouts_default.html` → `/workspaces/aws-portfolio/_layouts/default.html`
3. `_layouts_post.html` → `/workspaces/aws-portfolio/_layouts/post.html`
4. `Gemfile` → `/workspaces/aws-portfolio/Gemfile`
5. `index.md` → `/workspaces/aws-portfolio/index.md`
6. `about.md` → `/workspaces/aws-portfolio/about.md`
7. `projects.md` → `/workspaces/aws-portfolio/projects.md`
8. `blog.md` → `/workspaces/aws-portfolio/blog.md`
9. `contact.md` → `/workspaces/aws-portfolio/contact.md`

**Create empty _posts folder:**
```bash
mkdir -p /workspaces/aws-portfolio/_posts
```

---

## Step 2: Backup Old HTML Files

```bash
cd /workspaces/aws-portfolio
mkdir _old_html
mv *.html _old_html/
```

---

## Step 3: Update .gitignore

Add to `.gitignore`:
```
_site/
.jekyll-cache/
.jekyll-metadata
Gemfile.lock
_old_html/
```

---

## Step 4: Install Jekyll in Dev Container

```bash
# In VS Code terminal (dev container)
gem install jekyll bundler

# Install dependencies
bundle install
```

---

## Step 5: Test Locally

```bash
# Start Jekyll server (accessible from host Mac)
bundle exec jekyll serve --host 0.0.0.0 --port 4000

# Visit in browser: http://localhost:4000
# (Port should be auto-forwarded by VS Code)
```

**Test all pages:**
- http://localhost:4000/ (Home)
- http://localhost:4000/about (About)
- http://localhost:4000/projects (Projects)
- http://localhost:4000/blog (Blog - empty for now)
- http://localhost:4000/contact (Contact)

---

## Step 6: Update GitHub Actions

Replace `.github/workflows/deploy-with-security.yml` content with the updated version (provided separately).

Key changes:
- Adds Ruby/Jekyll setup
- Runs `jekyll build`
- Syncs `_site/` to S3 instead of root

---

## Step 7: Deploy

```bash
git add .
git commit -m "Convert to Jekyll: update nav/footer once, write posts in Markdown"
git push

# GitHub Actions will:
# 1. Install Jekyll
# 2. Build site to _site/
# 3. Sync _site/ to S3
# 4. Invalidate CloudFront
```

---

## Writing Blog Posts

### Create a new post:

```bash
# File naming: YYYY-MM-DD-title.md
touch _posts/2026-02-23-aws-waf-security.md
```

### Post format:

```markdown
---
layout: post
title: "Securing AWS CloudFront with WAF"
date: 2026-02-23
tags: [aws, security, waf, cloudfront]
image: /images/pic02.jpg
description: "A practical guide to implementing AWS WAF rules"
---

Your post content in **Markdown**...

## Introduction

Content here...

## Main Section

More content...

### Code Examples

\`\`\`bash
aws wafv2 create-web-acl --name MyWAF
\`\`\`

## Conclusion

Final thoughts...
```

### Post appears automatically on blog page!

---

## Updating Nav/Footer

**Before (HTML):** Edit 5 files  
**After (Jekyll):** Edit ONE file: `_layouts/default.html`

All pages update automatically!

---

## Troubleshooting

### Port 4000 not accessible?

Check VS Code PORTS tab, should auto-forward. Or manually forward port 4000.

### Jekyll build errors?

```bash
bundle exec jekyll build --trace
```

### Missing gems?

```bash
bundle install
```

### Changes not showing?

Hard refresh: `Cmd+Shift+R` or restart Jekyll server

---

## Benefits

✅ Update nav/footer ONCE, applies to all pages  
✅ Write blog posts in Markdown (faster!)  
✅ Blog index auto-generates  
✅ Same GitHub Actions workflow  
✅ Keep your exact Massively design  
✅ No database, still static files  

---

## File Naming Reference

**Pages:** `pagename.md` → builds to `/pagename/index.html`  
**Posts:** `YYYY-MM-DD-title.md` → builds to `/blog/YYYY/MM/DD/title/`  
**Assets:** `/assets/` and `/images/` stay the same  

Done! 🎉
