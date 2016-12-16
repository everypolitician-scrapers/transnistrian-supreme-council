#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//tr[.//div[@class="persona"]]').each do |person|
    source = person.css('.title a/@href').text

    data = { 
      id: File.basename(source),
      name: person.css('.title').text.tidy,
      area: person.text[/округ № (\d+)/, 1],
      image: person.css('a img/@src').text,
      term: 6,
      source: source,
      last_seen: Date.today.to_s,
    }
    %i(source image).each { |i| data[i] = URI.join(url, data[i]).to_s unless data[i].to_s.empty? }
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape_list('http://vspmr.org/structure/deputies/')
