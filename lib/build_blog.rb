#!/usr/bin/ruby

# This script builds the blog by adding the new.html file and rebuilding index.html, feed.xml, and other files

require 'rubygems'
require 'uri'
require 'highline/import'
require "build_all_pages.rb"
require "create_new_post.rb"

@baseurl = "http://localhost/www/blog/"
@dir = "/Library/WebServer/Documents/www/blog/"
newpost = @dir + "new.html"
@sidebar = @dir + "sidebar.html"
@index = @dir + "index.html"
@feed = @dir + "feed.xml"
@header = File.read(@dir + "header.txt")
@footer = File.read(@dir + "footer.txt")
@feedheader = File.read(@dir + "feedheader.txt")
@feedfooter = File.read(@dir + "feedfooter.txt")


# Highline - Ask new file or just rebuild blog
response = ask("Do you want to add a new file or just rebuild the blog? (add|build) ") do |question| 
  question.default = 'add'
end
if response != 'add'  # starts with a slash, must be absolute path
  say "Rebuilding blog from existing files"
  build_all_pages
  puts "Rebuilt all pages. Exiting."
  exit
end

# Highline - confirm new.html
response = ask("Process new.html or a different file? ") do |question| 
  question.default = newpost
end
if response =~ /^\//  # starts with a slash, must be absolute path
  newpost = response
else  # Does not start with slash, must be relative. Add @dir prefix.
  newpost = @dir + response
end
say "Processing: #{newpost}"

# Highline - confirm post date
response = ask("Enter pubdate (mm/dd/yyyy) or press return for Time.now ", DateTime) do |question| 
  question.default = Time.now.to_s
end
pubdate = response.to_s
postdate = response.strftime("%b %d, %Y")
@filedate = response.strftime("%Y-%m-%d")
say "Pubdate: #{pubdate}"
say "Postdate: #{postdate}"

# Create categories
create_categories(newpost)

# Highline - confirm categories
response = ask("Are these the correct categories? " + @new_categories.join(', ') ) do |question| 
  question.default = 'yes'
end
unless response == 'yes'
  say "Goodbye"
  exit
end

# Create filename
create_filename(newpost)

# Highline - confirm filename
response = ask("Enter filename: ") do |question| 
  question.default = @filename
end
@filename = response
if File.exist?(newpost)
  say "Filename: #{@filename}"
else
  say "File does not exist"
  exit
end

# Generate new blog post
create_slugs(@new_categories, postdate, pubdate, @filename, @title)
create_new_post(newpost)

# Highline - confirm overwrite
if File.exist?(@dir + @filename)
  response = ask("Overwrite existing #{@filename}? ") do |question| 
    question.default = 'yes'
  end
  unless response =~ /yes/
    exit
  end
end

# Write new blog post
File.open(@dir + @filename, 'w') { |file| file.puts @outputfile }

# Build blog
build_all_pages