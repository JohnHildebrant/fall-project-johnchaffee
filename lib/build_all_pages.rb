def build_all_pages
  ### REBUILD SITE/FEED ###
  # Create an array of blogpost html files
  Dir.chdir(@dir)
  files = Dir["*.html"].sort.reverse
  blogposts = []
  files.each do |file|
    # if file starts with a digit (ignore the new/index/sidebar/category.html files)
    if file =~ /^\d/
      blogposts << file
      puts file.to_s
    end
  end
  puts "blogposts.length: " + blogposts.length.to_s

  ### ARCHIVE PAGE ###
  # Generate Archive Page
  # Overwrite archive.html with archive header
  File.open(@dir + 'archive.html', 'w') { |file| file.puts @header + '<h1>Archive</h1>' } 
  blogposts.each do |post|
    File.readlines(post).each do |line|
      # Find the h2 tags (the line containing the blog title + href)
      if line =~ /h2/
        # Replace h2 tag with p tag
        link = line.gsub('h2','p')
        # Append line to category page
        File.open(@dir + 'archive.html', 'a') { |file| file.puts link  } 
        break
      end
    end
  end
  # Append footer to archive page after looping through all posts
  File.open(@dir + 'archive.html', 'a') { |file| file.puts @footer } 

  ### CATEGORY PAGES ###
  #  Build an array of unique categories from all pages
  @all_categories = []
  blogposts.each do |post|
    File.readlines(post).each do |line|
      # Extract the category names from the meta category lines and append to @all_categories array
      if line =~ /.*meta name=\"category\"/
        category = line.sub('<meta name="category" content="','').sub('"/>','').strip
        @all_categories << category
      end
    end
  end
  @all_categories = @all_categories.sort.uniq.compact

  sidebarcategories = ''
  # Generate category pages
  @all_categories.each do |category|
    # Create category-name.html filename
    catfilename = category.downcase.gsub(' ', '-') + '.html'
    # Create category href line
    catref = '<p class="category"><a href="' + @baseurl + catfilename + '" target="_parent">' + category.to_s + '</a></p>'
    # Append category href line to sidebarcategories string
    sidebarcategories += "\n" + catref
    # Create category page
    File.open(@dir + catfilename, 'w') { |file| file.puts @header + '<h1>' + category.to_s + '</h1>' } 
    # Loop through each blogpost searching for matching category
    blogposts.each do |post|
      catpost = File.read(post)
      if catpost =~  /meta name="category" content="#{category}"/
        # If there's a match, loop through each line of the post
        File.readlines(post).each do |line|
          if line =~ /h2/  # If line contains h2
            link = line.gsub('h2','p')  # Grab the h2 line and replace h2 tags with p tags
            File.open(@dir + catfilename, 'a') { |file| file.puts link  } # Append link to category page
            break
          end
        end
      end
    end
    File.open(@dir + catfilename, 'a') { |file| file.puts @footer  } # Append footer to category page after looping through all posts
  end

  ### SIDEBAR IFRAME ###
  # Replace existing category links on sidebar page, with new sidebarcategories from above
  catpost = File.read(@sidebar)  # Read entire contents of sidebar.html to string
  removecats = catpost.gsub(/.*<p class=\"category\".*\n/, '') # remove old category links
  newcats = removecats.gsub('<h2 id="title">Categories</h2>', '<h2 id="title">Categories</h2>' + sidebarcategories) # add new category links
  File.open(@sidebar, 'w') { |file| file.puts newcats } # Overwrite sidefar.html file with new contents

  ### PREV/NEXT LINKS, INDEX AND FEED ###
  # Highline - ask replace links on all or last 2 pages
  prevnextcount = 0
  response = ask("Build prev/next links (enter digit or all)? ") do |question| 
    question.default = '2'
  end
  if response =~ /a|all/
    prevnextcount = blogposts.length
  elsif response =~ /\d+/
    prevnextcount = response.to_i
  else
    prevnextcount = 2
  end
  say "prevnextcount: #{prevnextcount}"

  count = 0
  tenposts = ''
  tenfeeds = ''
  blogposts.each do |post|

    ### PREV/NEXT LINKS ###
    nextlink = ''
    prevlink = ''  
    if count < prevnextcount
      unless count == 0
        prevfile = blogposts[count-1]
        prevlink = '<a href="' + @baseurl + prevfile + '">&larr; Newer</a>'
      else
        prevlink = ''
      end
      unless count == blogposts.length-1
        unless count == 0
          prevlink += ' | '  # insert divider between prev/next links
        end
        nextfile = blogposts[count+1]
        nextlink = '<a href="' + @baseurl + nextfile + '">Older &rarr;</a>'
      else
        nextlink = ''
      end
      newerolder = '<p class="newerolder">' + prevlink + nextlink + '</p>'
      catpost = File.read(post)  # Read entire contents of blog post file to string
      outputfile = catpost.gsub(/<p class=\"newerolder\".*/, newerolder) # replace prev/next line
      # Overwrite file with new prev/next links
      File.open(@dir + post, 'w') { |file| file.puts outputfile }  
    end

    ### INDEX ###
    # Generate index page & feed from last 10 posts
    if count < 10
      # Extract post for the index page, including the date header and category footer
      thispost = `grep -A1000 '<div><!-- FullPost -->' #{post} | grep -B1000 '</div><!-- End FullPost -->'`
      # Append thispost to the tenposts array for the index page
      tenposts += thispost + "<hr />\n"

      ### FEED ###
      # Extract title, href and pubdate from the post
      href = ''
      title = ''
      pubdate = ''
      # Extract post for the feed, minus the date header and category footer
      thisfeed = `grep -A1000 '<div><!-- FeedPost -->' #{post} | grep -B1000 '</div><!-- End FeedPost -->'`
      File.readlines(post).each do |line|
        if line =~ /h2/  # If line contains h2, grab the title and href
          href = line.sub(/<h2.*href="/,'').sub(/.html.*/,'.html').strip
          title = line.sub(/.*.html">/,'').sub('</a></h2>','').strip
        end
        if line =~ /pubDate/
          pubdate = line.sub('<meta name="pubDate" content="','').sub('"/>','').strip
        end
      end
      # Append post title, href, pubdate, and thisfeed to tenfeeds array for the feed.xml
      tenfeeds += "<item>\n<title>" + title + "</title>\n<link>" + href + "</link>\n<guid>" + href + "</guid>\n<pubDate>" + pubdate + "</pubDate>\n<description>\n<![CDATA[\n" + thisfeed + "\n]]>\n</description>\n</item>\n"
    end
    count += 1  
  end

  ### OVERWRITE THE INDEX AND FEED FILES
  File.open(@index, 'w') { |file| file.puts @header + tenposts + @footer }  # Overwrite the index file
  File.open(@feed, 'w') { |file| file.puts @feedheader + tenfeeds + @feedfooter }  # Overwrite the feed file  
end
