---
date: December 7, 2012
title: Getting FreeNode and AndChat to play nice
category: General
layout: post
---

I recently had a battle to get Andchat and Freenode IRC to play nicely. Freenode changed their policy sometime ago where people on mobile or coming from Tor need to connect with SASL (Simple Authentication and Security Layer). Its not too hard to setup but finding the resources on how to do it was a little troubling. Main issue is that AndChat doesn't just have a "turn on SASL" setting and no hints in its UI. So... here's the scoop:


* First you need to register a nick with Freenode. This must be done on a desktop IRC client which can connect. 
{% highlight ruby %}
/msg NickServ REGISTER password youremail@example.com
{% endhighlight %}
* Verify your email address.
* Finally go into AndChat and put in your settings:

{% highlight ruby %}
Name: Freenode
Address: irc.freenode.org
Port: 7000
SSL: Checked
Nick1: Yourname
Username: Yourname
Password: Yourpassword
{% endhighlight %}

After this AndChat will use SASL. The key part is the Username portion, which it says in AndChat is optional, but this is not really correct. 

Good luck!