---
title: A Second Pair of Eyes
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

A few days ago I moved my hosting off of [Amazon EC2](http://aws.amazon.com/ec2/) and [Rackspace](rackspace.com) and onto my local [Comcast](http://www.comcast.com/) connection. Sure, I've lost a lot of reliability but hey, can't beat free. I was running into space issues and needed more RAM and my local PC has and i7 with 24GB of RAM so it sounded like a better solution.

So I spent a little bit setting everything up again on a VMware instance (blog about that coming soon...) and finally setup [port forwarding](http://en.wikipedia.org/wiki/Port_forwarding) on my router. But it didn't work!! So to troubleshoot I setup another forward rule for port 8080 to see if it was blocked. Sure enough port 8080 worked fine but 80 was timing out. So after a quick Google search I see that Comcast does [block some ports](http://customer.comcast.com/help-and-support/internet/list-of-blocked-ports/) although 80 wasn't listed a few other search results showed others with similar issues. Thus began my Comcast game of phone tag. 

First I tried Chat. They were kind enough to give me the line for Signiture Support (1-877-480-1344). But that’s not free. So I tried the regular technical line, and after multiple calls they all forwarded me to Signiture Support too. After about 3 hours of technicians dodging my questions I made a deal with the Signiture Support salesman: I'd accept the premium account signup and if it was my issue then I'd pay for the first month and signup fee, but if it was their issue they'd refund me my dough. 

Deal done. Comcast support tech hops on the line and sets up a remote session. I show him my site on local and that it works on 8080. Then we hop into the firewall config and he instantly goes "hey, you've got two configs for port 80!" Grrrrr.... Sure enough I had forgotten to uncheck an old port forward rule for port 80, and he found it in nearly under a minute on the line. 

Now I won't say I'm not unhappy with needing to pay for support from Comcast. But I will say the guy I talked to was smart. And for the amount of time I'd spent, and likely would have kept spending to fix the issue it was totally worth the money for a second pair of eyes. 
