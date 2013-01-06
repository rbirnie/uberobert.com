---
title: Your First OpenStack Instance
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

I've been working with [OpenStack](http://www.openstack.org/) at work and there has been a little confusion with users on how to spin up instances. Some of the concepts are a little new, even if they are relativly simple after you see it once. And the OpenStack documentation is so huge that it takes months to process, which is not great for Joe User. This will guide you through getting a plain instance up on OpenStack and is geared to an average user who just wants this damn system started already.

## Create an Access Keypair

[Keypairs](http://docs.openstack.org/essex/openstack-compute/starter/content/Creation_of_Key_Pairs-d1e1848.html) are OpenStack's way to give you ssh access to new instances without passwords. After sshing in you can set a password on your new instance. You can also use keypairs in the instances so that multiple instances can communicate with each other without password access. You can use the same keypair for multiple instances, so this only needs to be done once.

* Login to Openstack
* Go to "Access & Security" tab
* Click **Create Keypair**
* Name your keypair, preferably your username
* Click **Create**
* This should download a {keypairname}.pem file.

Keep a close eye on this key file. It can be used to access multiple machines so even if you remove a host keep this key around. I have a ~/.nova folder.

## Create an Instance

Creating your first OpenStack instance.

* Login to OpenStack
* Go to Instances -> Launch Instance
* Name your Instance and select base image/snapshot
* Select **Flavor** - ie. how much CPU/RAM
* Under **Access & Security** tab, select a Keypair. This will give you ssh access without a password
* Also under **Access & Security** make note of your *Security Group*, you'll need this later
* Click **Launch**

Now that the instance is launched we have to do a little housekeeping to make sure its ready to go. 

## Set Floating IP

Instances by default only have an internal IP that is only accessible by OpenStack. You need to allocate a **floating address** to get access to your machine. 

* Under your new Instance's Actions select **Allocate Floating IP**
* If there are no IPs in the dropdown hit the + symbol to add a new IP from the pool.
* Select a pool and hit **Allocate IP**
* Finally select your IP and the instance name and click **Associate**

This is your host's external address that you can access. Now to open up access with...

## Security Group Setup

[Security groups](http://docs.openstack.org/essex/openstack-compute/starter/content/Security_Overview-d1e2505.html) control outside access to OpenStack hosts. Think of it as a shared firewall. Under **Access & Security** find your security group and hit **Edit Rules**. This is where you can open different ports to the host group. By default it is empty, you probably want at least TCP port 22.

## Accessing Instances

Finally we are ready to ssh into our new instance. Drop to a terminal and browse to your pem file you downloaded when creating a keypair.

{% highlight bash %}
ssh root@{ip address} -i {keypair}.pem
passwd # set your password
{% endhighlight %}

After you set a password and add another user you can also access it from within the web ui. Open your instance and click VNC to view a terminal session.