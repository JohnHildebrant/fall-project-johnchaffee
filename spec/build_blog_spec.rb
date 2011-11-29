require_relative "../lib/create_new_post"

describe "build_blog" do
  context "categories" do
    it "should return the categoires" do
      create_categories('/Library/WebServer/Documents/www/blog/new.html')
      puts @new_categories.to_s
      @new_categories.class.should eq Array
    end
  end
end
