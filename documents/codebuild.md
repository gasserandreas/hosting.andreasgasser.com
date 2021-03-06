# Configuration steps / content

## General config

### Configure your project
project-name: andreasgasser-_branch_
description: optional

### Source: What to build
Github
Private repo
Choose your private repo
Clone-path: 1
Report build status: yes
Webhook: yes
Branch filter: your desired build branch
Build badge: yes

### Primary source webhook events
Webhook - optional: Rebuild every time a code change is pushed to this repository
Event type: PUSH
Start a build under these conditions
- HEAD_REF - optional: ^refs/heads/_branch_$
 (Note: don't miss the $ sign at the end)

### Environment: How to build
Environment image: AWS managed
type: Ubuntu --> node --> nodejs:10 (or higher)
Buildspec: buildspec.yml
Everything else: *as it is*

### Artifacts: Where to put the artifacts from this build project
No artefacts at all

### Cache
No cache

### Logs
CloudWatch Logs: yes

### Service role
Choose an existing service role from your account: use build role for branch, created by terraform
Allow AWS CodeBuild to modify this service role so it can be used with this build project: *No*

### Advanced settings
timeout: 0h 15min
Environment variables:
- `BUILD_ENVIRONMENT`: production (master branch) : develop (develop branch)
- `APP_NAME`: desired app name
- `S3_DEPLOY_BUCKET`: s3 deployment bucket url
- `DISTRIBUTION_ID`: cloudfront distribution id for environemnt
- `S3_UTILS_BUCKET`: s3 bucket for utility files and scripts 
- `S3_DEPLOY_STORYBOOK_BUCKET`: s3 bucket for storybook deployment
- `ENV_VAR`: specify .env file for given environment
- `GIT_BRANCH`: set Git branch
- `GH_ACCESS_TOKEN`: GitHub access token created in security access setting