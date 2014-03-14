---
title: Puppet Master Health Check for HAProxy
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

Basic [HAProxy](http://haproxy.1wt.eu/) monitoring for [puppet](http://projects.puppetlabs.com/) masters is pretty easy, just have HAProxy check puppet's default port, 8140. This works great for normal usage but what if you want to upgrade the puppet masters or test large manifest changes slowly? Just stopping puppet works for upgrades, but makes it difficult to test the server after the upgrade is complete. Not to mention that there's a chance puppet could die but since HAProxy only tests opening an ssl connection, the node would stay in the VIP. We obviously need a better way to dynamically enable/disable nodes from HAProxy without having to manually edit HAProxy's config.

One possible solution is having HAProxy monitor a file in `/var/www/html`. This would let us move the file to disable the node in the VIP. Problem solved! But this wouldn't really monitor puppet at all, just its node. If puppet crashed or was off HAProxy would never know. It'd only turn the node off if the whole server was down.

Enter [xinetd](http://www.xinetd.org/). Xinetd gives us a way to launch a simple script that can check on the puppet master and let the HAProxy know the servers status. Then if we need to take the puppet master out of the VIP we can disable xinetd and leave puppet up for additional testing.

## Xinetd Setup

Below is the script used to monitor the puppet master. This script is essentially a hand coded web server, so we need it to return the proper http status codes (usually handled by apache). HAProxy uses the HTTP 200 or 503 status codes to monitor how the puppet master is doing. If you need a more intensive check you can use the puppet [HTTP API](http://docs.puppetlabs.com/guides/rest_api.html). I'm personally using the [Status](http://docs.puppetlabs.com/guides/rest_api.html#status) URL, I don't think it provides any meaningful information other than that the puppetmaster is up. It does not even matter what environment you put in the URL, the environment can not exist and still return true. You could easily change this to monitor a [CA server](http://docs.puppetlabs.com/guides/rest_api.html#certificate-status) or something else.

Note that I've set the URL to use the `@FQDN` fact, you are using puppet? Right? Personally, I'm installing the xinetd service, but not checking it's status. This allows me to stop the service and not have to worry about puppet re-enabling it. Please go to my [Github](https://github.com/rbirnie/puppet-master-health-check) to get the most recent copy.

{% highlight bash %}
#!/bin/bash
#
# Script to make a proxy (ie HAProxy) capable of monitoring puppet master nodes
#
# Author: Robert Birnie <rbirnie@gmail.com>
# Documentation and download: https://github.com/rbirnie/puppet-master-health-check
#
# Based on the original script from Unai Rodriguez and Olaf van Zandwijk
#

ERR_FILE="/dev/null"

#
# Curl puppet status for prod
#
puppet_status=`/usr/bin/curl -ksS -H "Accept: pson" https://<%= @fqdn %>:8140/production/status/no_key | \
               grep "\"is_alive\":true" >${ERR_FILE} 2>&1; echo $?`

if [ "${puppet_status}" == "0" ]
then
    # Puppetmaster is running => return HTTP 200
    /bin/echo -en "HTTP/1.1 200 OK\r\n"
    /bin/echo -en "Content-Type: text/plain\r\n"
    /bin/echo -en "Content-Length: 26\r\n"
    /bin/echo -en "\r\n"
    /bin/echo -en "Puppetmaster is running.\r\n"
else
    # Puppetmaster is off => return HTTP 503
    /bin/echo -en "HTTP/1.1 503 Service Unavailable\r\n"
    /bin/echo -en "Content-Type: text/plain\r\n"
    /bin/echo -en "Content-Length: 26\r\n"
    /bin/echo -en "\r\n"
    /bin/echo -en "Puppetmaster has failed.\r\n"
fi
{% endhighlight %}

Next we need the xinetd config to receive requests and run the script. This goes in `/etc/xinetd.d/`. Alter the 'server' line for the script location. The log location defaults to `/var/lib/messages` and creates quite a bit of noise. So I have put it in its own file.

{% highlight bash %}
# default: on
# description: puppetmastercheck
service puppetmastercheck
{
# this is a config for xinetd, place it in /etc/xinetd.d/
    disable = no
    flags = REUSE
    socket_type = stream
    port = 9200
    wait = no
    user = nobody
    server = /usr/local/sbin/puppetmastercheck
    log_type = FILE /var/log/xinetdlog
    log_on_failure += USERID
    only_from = 0.0.0.0/0
    # recommended to put the IPs that need
    # to connect exclusively (security purposes)
    per_source = UNLIMITED
}
{% endhighlight %}

Finally, to get xinetd working you need to open up the port used by the server. Add this line to your `/etc/services` file.

{% highlight bash %}
puppetmastercheck      9200/tcp                # puppetmastercheck
{% endhighlight %}

## Configure Puppet

Next we need to configure puppet for our fancy pansy script. This isn't to difficult, but the default `/etc/puppet/auth.conf` doesn't allow access to the `/status/` API URL. So add these lines to your auth.conf.

{% highlight bash %}
# Allow access for HAProxy puppetmastercheck
path /status
auth any
method find
allow *
{% endhighlight %}

## HAProxy Config

Now that your script should be working, I'd test it out a few times with curl. And finally we can swap the port within HAProxy.

{% highlight bash %}
# Load balanced puppetmasters
listen puppetmaster_8140 10.0.0.100:8140
  mode tcp
  balance source
  hash-type map-based
  option httpchk

  server puppetmaster1 10.0.0.101:8140 check port 9200 inter 2000 rise 3 fall 3
  server puppetmaster1 10.0.0.102:8140 check port 9200 inter 2000 rise 3 fall 3
{% endhighlight %}

## Conclusion and Credits

Let me know either in the comments on here or via my [github](https://github.com/rbirnie/puppet-master-health-check) of any issues or recommendations. I'm not the sharpest tool in the shed so I'm sure there's a better way to do this!

The basis of the script and xinetd config was from the [Percona Clustercheck](https://github.com/olafz/percona-clustercheck) by Olaf van Zandwijk. Thanks!
