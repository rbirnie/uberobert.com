---
title: Using Certbot with Route53 plugin for Internal Sites
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

It’s been a while since my last post! Today, let’s explore how to use [Certbot’s](https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal) [Route53](https://certbot-dns-route53.readthedocs.io/en/stable/) plugin to generate SSL certificates using certbot-dns-route53. Typically, Certbot verifies domain ownership by placing files on a public web server and checking for their existence. However, this approach doesn’t work for internal services that are inaccessible from the internet.

This limitation is particularly frustrating because internal sites are a great use case for Let’s Encrypt. Paying for a certificate for something only internal users see feels unnecessary, yet manually generating a certificate every 60 to 90 days can be tedious. Thankfully, AWS Route53 provides a solution.

# Step 1 Install Certbot and the Route53 Plugin

Install Certbot and the Route53 plugin using the following commands:

{% highlight bash %}
sudo snap install --classic certbot
sudo snap set certbot trust-plugin-with-root=ok
sudo snap install certbot-dns-route53
{% endhighlight %}

# Step 2 Create an AWS Route53 Subdomain and IAM User

To minimize security risks, I prefer to avoid using AWS credentials with permissions that can modify second-level DNS names—especially for internal services that don’t require access to public-facing domains. Instead, we will create a subdomain (int.yourdomain.com) in Route53.

## Creating the Subdomain

1. Navigate to **Route53** in the AWS console.
2. Click **Hosted Zones** → Create **Hosted Zone**.
3. Name the zone **int.yourdomain.com.**
4. Update the parent domain’s DNS records to include the nameservers of the newly created subdomain’s hosted zone.

## Creating an IAM User with Limited Access

Now, we’ll create an IAM user with access restricted to our new hosted zone.

1. In the **IAM** console, click **Create User**.
2. Name the user and select **Attach policies directly**.
3. Click **Create Policy**.
4. Under **Specify permissions**, go to the **JSON** tab and paste the following policy (replace YOURHOSTEDZONEID with your actual Hosted Zone ID):
{% highlight json %}
{
    "Version": "2012-10-17",
    "Id": "certbot-dns-route53 sample policy",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect" : "Allow",
            "Action" : [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource" : [
                "arn:aws:route53:::hostedzone/YOURHOSTEDZONEID"
            ]
        }
    ]
}
{% endhighlight %}

5. Save the policy, return to the user creation page, refresh the policy list, and attach the new policy.
6. Generate an access key for the user.
7. On your server, add the access keys to `~/.aws/config`:

{% highlight yaml %}
[defailt]
aws_access_key_id=keyid
aws_secret_access_key=keyvalue
{% endhighlight %}

# Step 3 Test and Generate the Certificate

Before proceeding with the actual certificate issuance, perform a dry run to ensure everything is set up correctly:

{% highlight bash %}
certbot certonly --dns-route53 -d foo.bar.net -n --agree-tos -m c-robert@lily.ai --dry-run --test-cert
{% endhighlight %}

{% highlight bash %}
certbot certonly --dns-route53 -d foo.bar.net -n
{% endhighlight %}

In my case, I had to manually export the AWS credentials for them to be recognized properly. We'll see if they are correctly detected during renewal.

That’s it! Hopefully, this guide helps streamline the process of securing your internal services with Let’s Encrypt. 🚀