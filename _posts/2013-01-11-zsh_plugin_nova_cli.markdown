---
title: Zsh plugin for Nova CLI
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

After going through making the tutorial for [OpenStack CLI](https://github.com/openstack/python-novaclient), I got a little irritated at how long the commands are; primarily the boot command with its dozen arguments. So I made a plugin for [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) to autocomplete the madness. The plugin is located in my github repo [oh-my-zsh-nova](https://github.com/rbirnie/oh-my-zsh-nova). To install just copy the nova directory into the oh-my-zsh plugins directory.

{% highlight bash %}
git clone https://github.com/rbirnie/oh-my-zsh-nova.git
cp -r ./oh-my-zsh-nova/nova ~/.oh-my-zsh/custom/plugins/
vi ~/.zshrc # add 'nova' to your plugins
{% endhighlight %}

And that's it, you're now rocking some autocomplete goodness! To try it out just type nova and hit tab. Many of the subcommands are in there too, try nova boot {tab}. Sadly the format of how the zsh autocomplete works is weak with hints at positional arguments that don't have a corresponding -s|--switch. For example this bad boy:

{% highlight bash %}
usage: nova flavor-create [--ephemeral <ephemeral>] [--swap <swap>]
                          [--rxtx-factor <factor>] [--is-public <is-public>]
                          <name> <id> <ram> <disk> <vcpus>

Create a new flavor

Positional arguments:
  <name>                Name of the new flavor
  <id>                  Unique ID (integer or UUID) for the new flavor
  <ram>                 Memory size in MB
  <disk>                Disk size in GB
  <vcpus>               Number of vcpus

Optional arguments:
  --ephemeral <ephemeral>
                        Ephemeral space size in GB (default 0)
  --swap <swap>         Swap space size in MB (default 0)
  --rxtx-factor <factor>
                        RX/TX factor (default 1)
  --is-public <is-public>
                        Make flavor accessible to the public (default true)
{% endhighlight %}

This thing is a nightmare for autocomplete as the zsh plugin doesn't give you good hints for the *name*, *id*, etc. I've got the optional switches, but that's not extremely helpful if you don't know the rest. I'm looking around still to see if there is another syntax for zsh autocomplete to make this a little easier. I'll keep you posted on the progress, but I think this is a great start. 

Once again:<br>
My [github](https://github.com/rbirnie)<br>
The [nova plugin](https://github.com/rbirnie/oh-my-zsh-nova)<br>
The [nova installer](https://github.com/openstack/python-novaclient)<br>
And [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
