#!/usr/bin/env ruby
Bundler.require

exceptions = []
IconScraper::AUTHORITIES.keys.each do |authority_label, url|
  puts "\nCollecting feed data for #{authority_label}..."

  begin
    IconScraper.scrape(authority_label) do |record|
      record["authority_label"] = authority_label.to_s
      IconScraper.log(record)
      ScraperWiki.save_sqlite(["authority_label", "council_reference"], record)
    end
  rescue StandardError => e
    STDERR.puts "#{authority_label}: ERROR: #{e}"
    STDERR.puts e.backtrace
    exceptions << e
  end
end

unless exceptions.empty?
  raise "There were earlier errors. See output for details"
end
