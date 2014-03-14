---
title: Download S3 Backups
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

In the last blog I wrote I detailed how to [send backups directly into S3]({% post_url 2014-03-11-ec2-to-s3-backups %}). You might want to send backups to S3 rather than doing snapshots of your block devices in EC2 so that you can later download those backups and keep some form of your data in house. In this blog detail a basic script that does just that.

Now in this script I don't really care to download all the backups in my S3 bucket, merely the most recent. So what I'll do is parse the files in the bucket looking for the newest and then download that file.

Once again, to use these scripts first you must install the aws-sdk ruby gem from EPEL.

{% highlight bash %}
# Install EPEL
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
sudo rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

# Install Ruby
yum install rubygems ruby rubygem-nokogiri rubygem-aws-sdk
{% endhighlight %}

Next, here's the actual backup script.

{% highlight ruby %}
#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'

AWS.config(
  :access_key_id => '*** Provide your access key ***',
  :secret_access_key => '*** Provide your secret key ***'
)

mysql_path = '/backups/web/mysql'
mysql_bucket = 'mysql-backups'

www_path = '/backups/web/www'
www_bucket = 'www-backups'


def s3_download(file_name, base, bucket)
  # Get an instance of the S3 interface.
  s3 = AWS::S3.new

  # Upload backup file.
  key = File.basename(file_name)

  puts "Downloading file #{file_name} from bucket #{bucket}."
  File.open("#{base}/#{file_name}", 'wb') do |file|
    s3.buckets[bucket].objects[key].read do |chunk|
      file.write(chunk)
    end
  end
end

def newest_file(bucket_name)
  files = Hash.new

  s3 = AWS::S3.new
  bucket = s3.buckets[bucket_name]

  bucket.objects.each do |obj|
    files[obj.last_modified] = obj.key
  end

  files.max[1]
end

# Find newest file name
mysql_file = newest_file(mysql_bucket)
# Download mysql
unless mysql_file.empty? or File.exists? "#{mysql_path}/#{mysql_file}"
  s3_download(mysql_file, mysql_path, mysql_bucket)
end

# Find newest file name
www_file = newest_file(www_bucket)
# Download www
unless mysql_file.empty? or File.exists? "#{www_path}/#{www_file}"
  s3_download(www_file, www_path, www_bucket)
end
{% endhighlight %}

And that should be about it!