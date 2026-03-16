source "https://rubygems.org"

# Ruby 4.0 compatibility
gem "logger"
gem "base64"
gem "bigdecimal"
gem "mutex_m"

# Just the Docs theme
gem "just-the-docs", "~> 0.11"

# Jekyll
gem "jekyll", "~> 3.10"
gem "kramdown-parser-gfm"

# Jekyll plugins
group :jekyll_plugins do
  gem "jekyll-seo-tag"
  gem "jekyll-sitemap"
end

# Windows and JRuby compatibility
gem "tzinfo", ">= 1", "< 3"
gem "tzinfo-data"

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", platforms: [:jruby]
