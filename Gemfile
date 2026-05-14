# frozen_string_literal: true

source "https://rubygems.org"

# Chirpy theme
gem "jekyll-theme-chirpy", "~> 7.5"

# For html-proofer (optional test tool)
group :test do
  gem "html-proofer", "~> 5.0"
end

# Windows and JRuby compatibility
platforms :windows, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.2.0", platforms: [:windows]
