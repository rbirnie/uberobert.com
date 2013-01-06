---
title: Jekyll, Jenkins, and Github OAuth
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

Just finished my Jenkins setup for this Jenkins blog. [Jenkins](http://jenkins-ci.org/) is a pretty sweet [Continuous Integration](http://en.wikipedia.org/wiki/Continuous_integration) server. Here's how it all went down: 

## Install Jenkins

The first bit is straight from the Jenkin's setup page. No need to reinvent the wheel

{% highlight bash %}
wget -q -O abcd http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add abcd
apt-key add abcd 
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install jenkins
passwd jenkins
su jenkins
git config --global user.name "Robert"
git config --global user.email "robert@uberobert.com"
{% endhighlight %}

Took a second, but forgot that I had to update my ec2 firewall so back on my MacBook: 
{% highlight bash %}ec2-authorize Blog -p 8080{% endhighlight %}

I then dug into jenkin's plugins and added plugin for Github so I can track my [repository](https://github.com/rbirnie/uberobert.com) and I also added the [Github OAuth Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin) for authentication. 

From here I went ahead and setup my links to my Github. I added my repository url and set it to "build periodically" as I want it to rebuild once per day. I'm using a Jekyll feature that will keep it from posting blogs that are dated in the future, so I'm having Jenkins re-run once per day so the new blog of the day gets posted at the same time. The Jenkins schedule is 

{% highlight bash %}0 1 * * *{% endhighlight %}

I also set it to rebuild when a change is pushed to github, just to keep it all up to date. Finally I listed my shell commands I wanted it to run, these are pretty simple as Jekyll is pretty simple. 

{% highlight bash %}
jekyll
rsync -a ./_site/. /usr/share/blog/
{% endhighlight %}

That will make it rebuild the site and then rsync it to my chosen static file location. Finally I had it run a few builds, each time I usually got a minor error and just worked through them till I had working builds. Super! I've got a working site! Now it is time to secure Jenkins some. 

## Secure Jenkins

Hop on into Jenkin's "Configure Global Security" page. Now this part was a little tricky to find as the Github OAuth Plugin's documentation was a little out of date. First check "Enabled Security" then toggle on "Github Authentication Plugin". Leave the Github Uri the same, and now its time to get a Client ID and Secret. Browse to [Github Applications](https://github.com/settings/applications) and create a new "Developer Application". The URL is the URL/port used by your [Jenkins server](http://uberobert.com:8080). The CallBack URL will be the Jenkins server with [/securityRealm/finishLogin](http://uberobert.com:8080/securityRealm/finishLogin) appended to the url. After creating the application Github will give you a Client ID and Client Secret for your Jenkins server. Great! 

After putting those into your Jenkins server, you get to choose your authentication strategy. I personally like "Github Commiter Authorization Strategy". Although I'm not sure if I use it properly... It seems to be made for Github Organizations, which I'm not. So I just plopped my user name as an Admin User Name and left the Organization field blank. I also gave READ access to all Authenticated Users so you fine folks could poke around, be nice... At the end, save this guy and you should have authentication working. 

## Final Thoughts

So far Jenkins seems very powerful and easy to use and setup. I can't wait to implement it on a more complex site than a Jekyll blog. I could easily have recreated this simple setup with a single cronjob but where'd the fun be in that!

Have fun and stay out of trouble!