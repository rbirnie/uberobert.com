---
title: Upgraded Fact Imports
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

[Foreman](http://theforeman.org) has a [script](https://github.com/theforeman/puppet-foreman/blob/283619064fbde0275235535b19c53da249357035/files/push_facts.rb) to update it's facts by going through the fact's in /var/lib/puppet/yaml/facts/*.yaml and posting them to the Foreman server. The only issue is that the script does this one fact at a time and waits for the server response before proceeding which was taking long enough that the hosts had all reported back in again before the script could loop through all the hosts once.

To shorten this I added a queue and multiple threads to the script. The initial thread script I found was [here](http://stackoverflow.com/questions/1988274/ruby-working-on-array-elements-in-groups-of-four) which did the main jist of what I wanted to accomplish by letting me spin out any number of threads and then join them again at the end. Here's the script:

{% highlight ruby %}
#! /usr/bin/env ruby

require 'thread'

elements = [1,2,3,4,5,6,7,8,9,10]

def process(element)
    puts "working on #{element} \n"
    sleep rand * 5
end

queue = Queue.new
elements.each{|e| queue << e }

threads = []
4.times do
    threads << Thread.new do
      while (e = queue.pop(true) rescue nil)
        process(e)
      end
    end
end

threads.each {|t| t.join }

{% endhighlight %}

I then incorporated this with the foreman fact import script. The final copy is [here](https://gist.github.com/4261855):

{% highlight ruby %}
#! /usr/bin/env ruby
#
# This scripts runs on remote puppetmasters that you wish to import their nodes facts into Foreman
# it uploads all of the new facts its encounter based on a control file which is stored in /tmp directory.
# This script can run in cron, e.g. once every minute
# ohadlevy@gmail.com

# puppet config dir
puppetdir="/var/lib/puppet"

# URL where Foreman lives
url="https://foreman"

# Temp file keeping the last run time
stat_file = "/tmp/foreman_fact_import"

require 'fileutils'
require 'net/http'
require 'net/https'
require 'uri'
require 'thread'

last_run = File.exists?(stat_file) ? File.stat(stat_file).mtime.utc : Time.now - 365*60*60

facts = Dir["#{puppetdir}/yaml/facts/*.yaml"]


def process(filename, last_run)
  last_fact = File.stat(filename).mtime.utc
  if last_fact > last_run
    fact = File.read(filename)
    puts "Importing #{filename}"
    begin
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https' then
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = Net::HTTP::Post.new("/fact_values/create?format=yml")
      req.set_form_data({'facts' => fact})
      response = http.request(req)
    rescue Exception => e
      raise "Could not send facts to Foreman: #{e}"
    end
  end
end

queue = Queue.new
facts.each{|e| queue << e }

threads = []
10.times do
  threads << Thread.new do
    while (e = queue.pop(true) rescue nil)
      process(e, last_run)
    end
  end
end

threads.each {|t| t.join }
puts "All Threads Joined. Fact Import Done"
FileUtils.touch stat_file

{% endhighlight %}

The end result of this was about a 90% reduction in time taken to import facts into Foreman. I had to monitor both the foreman server and the puppet server to fine-tune the number of threads to spin out, I had the most luck with 10. This brought CPU on Foreman up to about 80% and on the Puppet server to 20%.

Any questions? Let me know!