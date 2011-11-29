# Extract new categories from head
def create_categories(newpost)
  @new_categories = []
  File.readlines(newpost).each do |line|
    # Extract category names from meta category and append to array of categories
    if line =~ /.*meta name=\"category\"/
      # Extract the category name from meta category line
      category = line.sub('<meta name="category" content="','').sub('"/>','').strip
      # Append category name to categories array
      @new_categories << category
    end
  end
end

# Create tidy filename from title
def create_filename(newpost)
  File.readlines(newpost).each do |line|
    tidytitle = ''
    # Extract title from the h2 line, and create tidytitle and filename
    if line =~ />\w.*h2/
      # $& returns exact match, not entire line. Strip the tags surroundging the title.
      @title = $&.sub('>','').sub('</a></h2','') 
      # Remove illegaal characters from title
      tidytitle = @title.downcase.gsub(/(#|%|&|\*|<|>|\{|\}|\\|:|;|,|<|>|\?|\/|\+|'|!|\.)/,'').gsub(/ /,'-').gsub(/-+/,'-') + '.html'
      # Create filename preceded with datestamp
      @filename = @filedate + '-' + tidytitle
      break
    end
  end
end

def create_slugs(new_categories, postdate, pubdate, filename, title)
  puts "creating_category_slug"
  # Map array of new_categories to array of category href links
  new_categories = new_categories.sort.uniq.compact
  catrefs =[]
  new_categories.each do |category|
    catref = '<a href="' + @baseurl + category.downcase.gsub(' ', '-') + '.html' + '">' + category + '</a>'
    catrefs << catref
    catrefs = catrefs.sort.uniq.compact
  end
  if catrefs.length > 0
    @categoryslug = 'Posted in ' + catrefs.join(', ') + '&nbsp;&nbsp;|&nbsp;&nbsp;'  # Category links displayed in footer
  else
    @categoryslug = ''
  end
  @postdateline = '<p class="postdate">' + postdate + '</p>' # @postdateline in displayed in header
  @pubdateline = '<meta name="pubDate" content="' + pubdate + '"/>'  # pubDate in head for feed
  @h2line = '<h2 id="title"><a href="' + @baseurl + @filename + '">' + @title + '</a></h2>'  # h2 line that links to self
  @mailto = 'href="mailto:info@busymac.com?subject=BusyBlog:%20' + URI.escape(@title) + '"'  # Comments @mailto link
end

def create_new_post(newpost)
  catpost = File.read(newpost)  # Read entire contents of new.html to string
  # Replace @pubdateline, @postdateline, @h2line, @categoryslug and comment @mailto 
  @outputfile = catpost.sub(/<meta name=\"pubDate\".*/, @pubdateline).sub(/<p class=\"postdate\">.*/, @postdateline).sub(/<h2.*/, @h2line).sub('Posted in <a href="#"></a>&nbsp;&nbsp;|&nbsp;&nbsp;', @categoryslug).sub('href="mailto"', @mailto)  
end
