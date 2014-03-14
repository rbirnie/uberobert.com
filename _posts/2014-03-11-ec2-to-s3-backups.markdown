---
title: EC2 to S3 Backups
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

This blog post will go over the basics on getting automatic backups going from an AWS EC2 instance into an AWS S3 bucket. Storing your backups in S3 is a nice method because you get such good network performance keeping the data in AWS and then you can do a local backup to from the S3 data without effecting server performance or opening up any extra ports from their firewalls.

For this backup I needed to backup a WordPress site, so its both the local filesystem as well as the mysql database. I kept the scripts separate so that they can work if the mysql database is on a different server from the web host. The basis of this script is from the AWS [Documentation](http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjSingleOpRuby.html)

To use these scripts first you must install the aws-sdk ruby gem from EPEL

{% highlight bash %}
# Install EPEL
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
sudo rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

# Install Ruby
yum install rubygems ruby rubygem-nokogiri rubygem-aws-sdk
{% endhighlight %}

Next, here's the actual backup script. Ideally I wouldn't shell out quite so often, but this works so I'm using it for now.

{% highlight ruby %}
#!/usr/bin/env ruby
#
# Script to backup mysql into an S3 bucket
#/usr/local/sbin/mysql_backups.rb

require 'rubygems'
require 'aws-sdk'

AWS.config(
  :access_key_id => '*** Provide your access key ***',
  :secret_access_key => '*** Provide your secret key ***'
)

username='*** Provide mysql user ***'
password='*** Provide mysql password ***'
ERR_LOG="/var/log/mysql_backuperr.log"

bucket_name = 'mysql-backups'
file_name = "/tmp/#{`date +\%Y\%m\%d`.strip}.mysql.gz"

if `mysql -u #{username} -p#{password}  -e ";"`
  # mysqldump database
  if `/usr/bin/mysqldump --user=#{username} --password=#{password} --max_allowed_packet=1024M --opt --single-transaction --all-databases 2>>#{ERR_LOG} | gzip -c > #{file_name} || logger -t mysql_backups -p local6.err errorexit $?`
    # Get an instance of the S3 interface.
    s3 = AWS::S3.new
    File.size(file_name)
    # Upload backup file.
    key = File.basename(file_name)
    s3.buckets[bucket_name].objects[key].write(:file => file_name)
    puts "Uploading file #{file_name} to bucket #{bucket_name}."
  end
else
  `mysql -u #{username} -p#{password} -e ";" 2>#{ERR_LOG}`
end

{% endhighlight %}

Next here's the script to backup the local filesystem.

{% highlight ruby %}
#!/usr/bin/env ruby
#
# Script to backup folder into an S3 bucket
# /usr/local/sbin/www_backup.rb

require 'rubygems'
require 'aws-sdk'

AWS.config(
  :access_key_id => '*** Provide your access key ***',
  :secret_access_key => '*** Provide your secret key ***'
)

bucket_name = 'www-backups'
file_name = "/tmp/www_#{`date +\%Y\%m\%d`.strip}.tar.gz"

`tar -zcvf #{file_name} /var/www/vhosts`

# Get an instance of the S3 interface.
s3 = AWS::S3.new

# Upload backup file.
key = File.basename(file_name)

puts "Uploading file #{file_name} to bucket #{bucket_name}."
s3.buckets[bucket_name].objects[key].write(:file => file_name)

puts "Removing local copy"
File.delete(file_name)
{% endhighlight %}

There are a couple to-do items to improve these scripts that I've not had a chance to test out and use. The first is using [JS3tream](http://js3tream.sourceforge.net/linux_tar.html) to stream the backups to S3, this would remove the need of making a local copy of the files prior to uploading to S3. The next improvement would be [enabling encryption](http://docs.aws.amazon.com/AmazonS3/latest/dev/SSEUsingRubySDK.html) of the files in the S3 bucket.

Next blog post I'll share how to now [download the backups locally]({% post_url 2014-03-14-download-s3-backups %}) so you won't loose data when AWS is bombed by evil aliens attempting to get at your blog.