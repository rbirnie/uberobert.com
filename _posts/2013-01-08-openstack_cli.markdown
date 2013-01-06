---
title: OpenStack CLI
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

Starting and managing machines from the CLI is at times useful. It is nice managing your instances from your local machine without the need of a web browser. Here's the basics on how to start a host.

## Install 

First you must install the [Python bindings to the OpenStack Nova API](https://github.com/openstack/python-novaclient). Once that is installed setup your ~/.novarc file. This will contain the settings to access your OpenStack cluster. 

Mine looks something like this:

{% highlight bash %}
# ~/.novarc
# COMMON OPENSTACK ENVS
export OS_USERNAME=username
export OS_PASSWORD=password
export OS_TENANT_NAME=dev # This is the Project you are apart of
export OS_AUTH_URL=http://10.0.0.10:5000/v2.0/
{% endhighlight %}

Great! Now finally source it with 'source ~/.novarc'

## Start an Instance

Now we are ready to get down and dirty

{% highlight bash %}
nova list # show your instances
nova list --all-tenants # show all instances
nova flavor-list # list available flavors
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+-------------+
| ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public | extra_specs |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+-------------+
| 1  | m1.tiny   | 512       | 0    | 0         |      | 1     | 1.0         | True      | {}          |
| 2  | m1.small  | 2048      | 10   | 20        |      | 1     | 1.0         | True      | {}          |
| 3  | m1.medium | 4096      | 10   | 40        |      | 2     | 1.0         | True      | {}          |
| 4  | m1.large  | 8192      | 10   | 80        |      | 4     | 1.0         | True      | {}          |
| 5  | m1.xlarge | 16384     | 10   | 160       |      | 8     | 1.0         | True      | {}          |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+-------------+
nova image-list # list available images
+--------------------------------------+--------------------------------------+--------+--------+
| ID                                   | Name                                 | Status | Server |
+--------------------------------------+--------------------------------------+--------+--------+
| 3c957e4a-1337-429d-ae61-1a5bec057adb | precise-image                        | ACTIVE |        |
+--------------------------------------+--------------------------------------+--------+--------+
nova keypair-list # list available keypairs
+-----------------+-------------------------------------------------+
| Name            | Fingerprint                                     |
+-----------------+-------------------------------------------------+
| test2           | 68:62:c2:2c:45:fb:c1:b7:93:14:59:72:41:c9:b7:c6 |
+-----------------+-------------------------------------------------+
nova boot --flavor 2 --image 3c957e4a-1337-429d-ae61-1a5bec057adb --security-groups default --key-name test2 host123 # boot an instance named host123
nova list
+--------------------------------------+-------------+--------+------------------------------------+
| ID                                   | Name        | Status | Networks                           |
+--------------------------------------+-------------+--------+------------------------------------+
| 58fb9399-9a2b-4afe-6149-b1ac7c6c9f39 | host123     | ACTIVE | public=192.168.1.5                 |
+--------------------------------------+-------------+--------+------------------------------------+
{% endhighlight %}

Note that it only has an IP from its internal subnet. Now to give it an IP we can access.

{% highlight bash %}
nova floating-ip-create
+---------------+-------------+----------+------+
| Ip            | Instance Id | Fixed Ip | Pool |
+---------------+-------------+----------+------+
| 10.0.0.134    | None        | None     | nova |
+---------------+-------------+----------+------+
nova floating-ip-list
+---------------+--------------------------------------+--------------+------+
| Ip            | Instance Id                          | Fixed Ip     | Pool |
+---------------+--------------------------------------+--------------+------+
| 10.0.0.134    | None                                 | None         | nova |
+---------------+--------------------------------------+--------------+------+
nova add-floating-ip test123 10.0.0.134
nova floating-ip-list
+---------------+--------------------------------------+--------------+------+
| Ip            | Instance Id                          | Fixed Ip     | Pool |
+---------------+--------------------------------------+--------------+------+
| 10.0.0.134    | 58fb9399-9a8b-4afe-9149-b2ac7c6c9f39 | 192.168.1.5 | nova |
+---------------+--------------------------------------+--------------+------+
nova list
+--------------------------------------+-------------+--------+------------------------------------+
| ID                                   | Name        | Status | Networks                           |
+--------------------------------------+-------------+--------+------------------------------------+
| 58fb9399-9a8b-4afe-9149-b2ac7c6c9f39 | host123     | ACTIVE | public=192.168.1.5, 10.0.0.134    |
+--------------------------------------+-------------+--------+------------------------------------+
{% endhighlight %}

That looks better! Now we can ssh into the machine using our personal keypair we setup previously in [your first OpenStack Instance](http://uberobert.com/OpenStack/2013/01/04/your_first_openstack_instance/).

If you want to learn more about the CLI, ['nova help'](http://docs.openstack.org/essex/openstack-compute/starter/content/Nova_Commands-d1e2589.html) and 'nova help command' are indispensible. 
