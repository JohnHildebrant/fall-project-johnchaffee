# Build Blog Script

## Introduction

This script creates a static blog from a new file plus existing html files. It is designed around my workflow and probably won't be useful to anyone else. When running the script, it adds/renames the new.html file to the blog, and updates the index.html, feed.xml, and supporting files.

## Workflow
- Create a new blog post using the new.html file as a template.
- The template contains sections for the header, footer, sidebar and post content.
- When editing the template, you should only edit the "FullPost" section, and the categories in the head.
- Optional categories may be entered, one per line, in the meta category lines in the head.
- There should only be one blog title/url line surrounded by h2 tags.
- All urls must be absolute (for the feed.xml)
- All styles must be inline (for the feed.xml)
- After editing the new.html file, run the build_blog.rb script to start the process. You'll be prompted to add the new.html file to the blog, then the supporting files will be rebuilt (index, feed, and supporting files).

## File Structure

The root directory (/blog) contains:

- Template files (feedfooter.txt, header.txt, new.html, sidebar.html, etc.)
- Generated blog posts (2011-01-01-my-first-blog-post.html, etc.)
- Generated supporting files (archive.html, category1.html, etc.)
- The /app folder (described below)

/blog

	2011-01-01-my-first-blog-post.html
	2011-01-02-my-second-blog-post.html
	2011-01-03-my-third-blog-post.html
	/app
	archive.html
	category1.html
	category2.html
	category3.html
	feed.xml
	feedfooter.txt
	feedheader.txt
	footer.txt
	header.txt
	index.html
	new.html
	sidebar.html


The /app directory contains the code. The meat is in the /lib directory:

- build_blog.rb -- script that prompts user to add a new blog post and/or rebuilding the site.
- build_all_pages.rb -- code that generates the static site.
- create_new_post.rb -- code that adds new blog post.

/app

	Gemfile
	Gemfile.lock
	/lib
		build_all_pages.rb
		build_blog.rb
		create_new_post.rb
	Rakefile.rb
	README.md
	/spec
		build_blog_spec.rb

