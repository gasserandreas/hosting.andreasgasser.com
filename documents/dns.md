# DNS configuration

Main / root accounts uses public CloudFront distribution IDs to forward traffic from root account to sub account CloudFront configuration.
No additional DNS configuration on sub account!

## How to create CloudFront distributions
Use Terraform and add new CloudFront distributions to `main.tf` file. Make sure all required credentials / vars are set.

## How to add new DNS entries
1. Open Route53 in root account and select DNS zone file
2. Add new record with following details:
  - Name: DNS name (without `www.`)
  - Type: A - IPV4 address
  - Alias: Yes
  - Alias Target: distribution id from sub account
  - Routing policy: Simple
  - Evaluate Target Health: No
3. Save entry and create new one
4. Create CNAME record for previous created DNS entry with following details:
  - Name: `www.`_your_previous_added_dns_name
  - Type: CNAME
  - TTL: 300
  - Value: Previous use DNS name
