# Calisthenics — My Opinionated Static Blog Template

A static blog built with [Hakyll](https://jaspervdj.be/hakyll/) (Haskell), featuring blog posts written in [Typst](https://typst.app/) and styled with [Pico.css](https://picocss.com) and [TailwindCSS](https://tailwindcss.com).

## Features

- **Hakyll static site generator** - Fast, flexible Haskell-based site generation
- **Typst blog posts** - Write posts in Typst markup instead of Markdown
- **Modern styling** - Combination of Pico.css and TailwindCSS for clean, responsive design
- **Nix flakes** - Reproducible development environment
- **GitHub Pages ready** - Builds to `docs/` directory for easy deployment

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/) with flakes enabled

### Development

1. **Enter the development shell:**
   ```bash
   nix develop
   ```

2. **Build the site:**
   ```bash
   build-site
   # or manually:
   cabal run site build
   ```

3. **Start the development server:**
   ```bash
   serve-site
   # or manually:
   cabal run site watch
   ```

4. **Build TailwindCSS (in another terminal):**
   ```bash
   npm run build-css
   ```

The site will be available at `http://localhost:8000`

### Project Structure

```
.
├── flake.nix                 # Nix flake configuration
├── calisthenics.cabal       # Haskell package configuration
├── site.hs                  # Hakyll site generator
├── templates/               # HTML templates
│   ├── default.html        # Main site template
│   ├── post.html           # Blog post template
│   ├── archive.html        # Post list template
│   └── tag.html            # Tag page template
├── posts/                   # Blog posts (Typst files)
├── css/                     # Stylesheets
├── docs/                    # Generated site (build output)
├── index.html              # Homepage
├── about.html              # About page
└── reading-list.html       # Reading list page
```

## Writing Posts

Blog posts are written in Typst format in the `posts/` directory. Each post should start with YAML frontmatter:

```typst
---
title: Your Post Title
date: 2024-01-15
tags: tag1, tag2, tag3
---

= Your Post Title

Your post content in Typst markup...
```

## Deployment

The site builds to the `docs/` directory, making it ready for GitHub Pages deployment:

1. Push your changes to GitHub
2. In your repository settings, enable GitHub Pages
3. Set the source to "Deploy from a branch"
4. Select the `main` branch and `/docs` folder
5. Your site will be available at `https://username.github.io/repository-name`

## Commands

- `build-site` - Build the static site
- `serve-site` - Start development server with auto-rebuild
- `cabal run site build` - Build site manually
- `cabal run site watch` - Watch for changes and rebuild
- `cabal run site clean` - Clean build artifacts
- `npm run build-css` - Build TailwindCSS (watch mode)
- `npm run build-css-prod` - Build TailwindCSS (production, minified)

## Customization

### Styling

- **Pico.css** provides the base styling (loaded from CDN)
- **TailwindCSS** is used for additional utility classes
- Custom styles in `css/input.css` are processed by Tailwind
- The `tailwind.config.js` has `preflight: false` to avoid conflicts with Pico.css

### Templates

HTML templates are in the `templates/` directory and use Hakyll's template syntax.

### Site Configuration

Modify `site.hs` to customize:
- Build directory (currently set to "docs")
- Routing rules
- Template processing
- Typst compilation options

## Dependencies

- **Haskell**: GHC, Cabal, Hakyll
- **Typst**: For compiling blog posts
- **Node.js**: For TailwindCSS processing
- **Nix**: Development environment management

All dependencies are managed through the Nix flake for reproducible builds.
