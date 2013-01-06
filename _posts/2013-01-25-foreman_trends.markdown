---
date: 2013-01-25
title: Foreman Trends
category: Foreman
layout: post
---

I'm super excited about the 1.1 release of [Foreman](http://theforeman.org/), as it has a chunk of my code in there! My work needed a way to track historical trends in our infrastructure over time and gave me the task of coming up with a solution. The Trend pages in Foreman give a graph of the number of hosts with a puppet fact value over time, and the list of current hosts.

[Puppet](http://puppetlabs.com/) is great for finding current data points using [Facter](http://www.puppetlabs.com/puppet/related-projects/facter/). Facter is flexible in allowing you to create custom facts to track and has a slew of pre-built facts. But Facter has a pretty short memory as it only shows the current configuration, and each time the host reports into the puppet server it overwrites is prior entry. 

[Foreman](http://theforeman.org/) integrates with puppet and receives puppet reports and fact updates and can give great insight into how the infrastructure is performing, but also had a short memory. So in comes Foreman Trends and the ability to track facts/foreman information over time. 

## Setup

There are two pieces to the Trends area, the Trends to track and their corresponding counters. To define trend counters, use the "Add Trend Counter" button on the '/trends' page. Optionally set the "Name" field to over-ride odd puppet fact names to be more readable. Once created you can optionally 'Edit' the Trend to change the display names of the underlying values. 

Next, to start collecting trend data, set a cron job to execute 'rake trends:counter'. Each time the rake task executes it will create 1 tick on the graphs, so you can fine tune the granularity with your cron job. The granularity is dependent on how much history you want to show, if you are showing 30 days, 1 hour granularity should be good. If you are displaying longer then you may want to increase the number as it'll speed up the page loads. Here's an example to run once per hour: 

{% highlight sh %}
0 * * * * cd /usr/share/foreman/ && /usr/bin/rake trends:counter
{% endhighlight %}

# How it Looks

Here's a couple screenshots:

## Future Ideas

I'm toying with a few possible changes. 

* Move the data into a json api call rather than served directly with page load. 

* Scope Trends data by puppet environment