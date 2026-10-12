# uarchlabs.github.io

Source for the [uarchlabs](https://uarchlabs.github.io) organization homepage
and blog.

Built with Jekyll. GitHub Pages rebuilds the site on every push to `main`.

## Layout

- `index.html` - organization homepage
- `blog/index.html` - blog listing page
- `_posts/` - blog posts, one Markdown file each, named `YYYY-MM-DD-slug.md`
- `_layouts/` - page templates (`default.html`, `post.html`)
- `assets/diagrams/` - figures referenced by posts
- `img/` - site images (banner, profile)
- `_config.yml` - site config; posts are served at `/blog/:title/`
- `_site/` - generated build output, do not edit (gitignored)

## Adding or editing a post

Create or edit a file in `_posts/`. Each post starts with front matter:

    ---
    layout: post
    title: "Post Title"
    author: Jeff Nye
    date: YYYY-MM-DD
    series: "BPU Series"
    excerpt: "One-line summary"
    copyright: "Copyright 2026 Jeff Nye"
    ---

The body is GitHub-flavored Markdown (kramdown). The filename slug becomes
the URL, so renaming a published post breaks existing links.

## Adding a new project

Add a card to `index.html` in the projects section when a new
uarchlabs repo goes live.

TODO: add cachegen on its next release

## To test local jekyll changes

    bundle install
    sudo bundle exec jekyll serve --port 4001

Then open http://localhost:4001.

Note: 4001, nomachine uses 4000.
