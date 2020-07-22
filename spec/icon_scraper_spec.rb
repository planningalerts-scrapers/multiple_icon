# frozen_string_literal: true

require "timecop"

RSpec.describe IconScraper do
  it "has a version number" do
    expect(IconScraper::VERSION).not_to be nil
  end

  describe ".rest_xml", :vcr do
    context "feed without address" do
      it "should not error" do
        agent = Mechanize.new
        IconScraper.rest_xml(
          "http://epb.swan.wa.gov.au/Pages/XC.Track/SearchApplication.aspx",
          { d: "thisweek", k: "LodgementDate", t: "282,281,283", o: "xml" },
          agent
        ) {}
      end
    end
  end

  describe ".scrape_and_save" do
    def test_scraper(authority)
      results = VCR.use_cassette(authority) do
        Timecop.freeze(Date.new(2019, 5, 15)) do
          results = []
          IconScraper.scrape(authority) do |record|
            results << record
          end
          results.sort_by { |r| r["council_reference"] }
        end
      end

      expected = if File.exist?("spec/expected/#{authority}.yml")
                   YAML.safe_load(File.read("spec/expected/#{authority}.yml"))
                 else
                   []
                 end

      if results != expected
        # Overwrite expected so that we can compare with version control
        # (and maybe commit if it is correct)
        File.open("spec/expected/#{authority}.yml", "w") do |f|
          f.write(results.to_yaml)
        end
      end

      expect(results).to eq expected
    end

    IconScraper::AUTHORITIES.each_key do |authority|
      it authority do
        test_scraper(authority)
      end
    end
  end
end
