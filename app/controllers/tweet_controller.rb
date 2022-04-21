require 'nokogiri'
require 'open-uri'
require 'pry'
require 'net/http'
require 'watir'
require 'webdrivers'

class TweetController < ApplicationController
  def get(word, delimiter)
    begin
      limit = delimiter[:size]
      browser_service = gateway(word)
      response = scraper(browser_service, limit)
      return response
    rescue => e
      puts e
    end
  end

  private

  def gateway(word)
    url = "https://twitter.com/search?lang=pt&src=typed_query&q=#{word}&f=live"
    browser = Watir::Browser.new
    browser.goto(url)
    until browser.section(:aria_labelledby => /accessible-list.*/ ).present? do sleep 5 end
    return browser
  end

  def scraper(browser, limit)
    result=[]
    tweets = browser.articles
    while result.length < limit
      tweets.each do |t|
        tweet=t.div.div.div
        single_result = parse(tweet)
        result.push(single_result);
        if(result.length == limit)
          break
        end
      end
      browser.driver.execute_script("window.scrollBy(0,20000)")
      sleep 5
      tweets =  browser.articles
    end
    return result
  end

  def parse(tweet)
    return {
      username: tweet.a.href.gsub("https://twitter.com/","@"),
      text: tweet.div(index: 3).div(index: 46).text.downcase,
      timestamp: DateTime.parse(tweet.time.datetime).to_time.to_i
    }
  end
end
