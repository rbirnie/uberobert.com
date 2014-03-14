---
title: Setting Puppet Defaults with Resource Collectors
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

In an environment we often have files or configurations that we want to have on every node but then customize on specific nodes. For example a customized Ganglia gmond.conf file with differnt ports based on which cluster the machine belongs. The most basic method of doing this is with a giant case statement within the configuration file, but this gets unweildy at scale. A great solution for this is a [resource collector](http://docs.puppetlabs.com/puppet/3/reference/lang_collectors.html). Resource collectors let you do a "find and replace" on an already defined resource. In the ganglia example it will let us define the gmond file once with default cluster settings, and then override it's attributes for any node with a more specific cluster.

