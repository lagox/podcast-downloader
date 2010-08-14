#!/usr/bin/env ruby -w

# author : Kusainov Yerlan (2010)

require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Podcast
	
	attr_accessor :url, :preg_url, :nokogiri_search_arg, 
								:url_key, :rss_url ,:xml_page, :links, 
								:mp3_links
	
	# initialize
	def initialize(url)
		@preg_url = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
		@mp3_links = []
		@nokogiri_search_arg = []
		@nokogiri_search_arg[0] = "//link[@type='application/rss+xml']"
		@nokogiri_search_arg[1] = "//enclosure[@type='audio/mpeg']"
		@url = url
		#invoke common method
		common
	end
	
	# Check url
	def check_url
		if @url !~ @preg_url
			@url_key = false
			puts "Invalid url!"
			exit
		else
			@url_key = true
		end
	end
	
	# find rss-feed
	def rss_feed
		#open page
		@html_page = Nokogiri::HTML(open(@url))
		if @html_page
			tmp_array = @html_page.search(@nokogiri_search_arg[0])
			tmp_array.each { |f| f.each { |n| n.each { |s| s !~ @preg_url ? nil : @rss_url = s } } }
		else
			puts "server is not responding"
			exit
		end
	end
	
	# collect mp3 links
	def collect_links
		@xml_page = Nokogiri::XML(open(@rss_url))
		if @rss_url
			@links = @xml_page.search(@nokogiri_search_arg[1])
			@links.each { |f| f.each { |n| n.each { |s| s !~ @preg_url ? nil : @mp3_links << s } } }
		else
			puts "server is not responding"
			exit
		end
	end
	
	def wget
		@mp3_links.each do |m| 
			system("wget",m)
		end
	end
	
	# common method
	def common
		check_url
		rss_feed
		collect_links
		wget
	end

end

puts "***************************"
puts "Requirement: installed wget"
puts "***************************"
puts "Input rpod address:"
address = gets.to_s
pod = Podcast.new(address)
