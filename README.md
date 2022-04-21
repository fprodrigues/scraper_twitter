# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...



*** Estudo de caso ***

```
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'net/http'
require 'watir'
require 'webdrivers'

class TweetController < ApplicationController
  def get
  url = "https://twitter.com/search?lang=pt&src=typed_query&q=saude&f=live"
  #   uri = URI(url)
  #   binding.pry
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = true if url.match?(/^https/)
  #   http.open_timeout = 5
  #   http.read_timeout = 5
  #   req = Net::HTTP::Get.new(uri)

  #   # headers.each do |key, value|
  #   #   req[key] = value
  #   # end

  #   res = http.start { http.request(req) }
  #   document = Nokogiri::HTML(html)
  browser = Watir::Browser.new
  browser.goto(url)
  until browser.section(:aria_labelledby => /accessible-list.*/ ).present? do sleep 5 end
  tweets = browser.articles
  limit=4
  result=[]

  while result.length < limit
    tweets.each do |t|
      tweet=t.div.div.div
      single_result ={
        username: tweet.a.href.gsub("https://twitter.com/","@"),
        text: tweet.div(index: 3).div(index: 46).text.downcase,
        timestamp: DateTime.parse(tweet.time.datetime).to_time.to_i
      }
      result.push(single_result);
      if(result.length == limit)
        break
      end
    end
    browser.driver.execute_script("window.scrollBy(0,20000)")
    sleep 5
    tweets =  browser.articles
  end



  # tweets.each do |t|
  #   tweet=t.div.div.div
  #   single_result ={
  #     username: tweet.a.href.gsub("https://twitter.com/","@"),
  #     text: tweet.div(index: 3).div(index: 46).text.downcase,
  #     timestamp: DateTime.parse(tweet.time.datetime).to_time.to_i
  #   }
  #   result.push(single_result);
  # end

    return result
  end
end
```