[![Actions Status](https://github.com/colinbruce/laa-apply-bot/workflows/Deploy%20to%20Production/badge.svg)](https://github.com/colinbruce/laa-apply-bot/actions)

# LAA-Apply Slack bot
A bot designed to allows slack users to run commands to assist with maintaining the LAA Apply applications

## Usage
The bot can be invited to a channel `/invite @apply-bot` or interacted with via direct messages.

## Interacting
Should be addressed as `@apply-bot` 

e.g. `@apply-bot <command>`

## Commands
- `add users` - ```@apply-bot add users name1, name.2, name.three@provider.com``` 
- `ages` - ```@apply-bot ages```
- `details` - ```@apply-bot cfe details staging``` or ```@apply-bot apply details live```
- `run tests` - ```@applybot run tests```
- `uat url` - ```@applybot uat url ap-1234```
- `uat urls` - ```@applybot uat urls```
- `help` - ```@apply-bot help``` provides better examples than these

## Developing locally

This can be a handful... 

The corporate slack instance doesn't allow unsanctioned bots to run. Therefore you will need access to a standalone slack instance. 

I have set up a personal, free, slack instance and configured a slack token of my own. See the [Slack API](https://api.slack.com/) documents for help with that.
To access all of the commands, you will need to be running `redis` (```redis-server```), `sidekiq` (```bundle exec sidekiq -r ./app.rb```) and the 
server itself (```bundle exec rackup -r ./app.rb``)

As an alternative you can use ```foreman start``` which will run all three services in a single window, but that is not as helpful for debugging.  
Binding.pry breakpoints tend to freeze and/or get lost in the threaded services as they run. YMMV

As interactive elements have been developed you will now need to run a service that allows passing a url to the slack instance
e.g. [ngrok](https://ngrok.com/)  [**Note**: I used ngrok but do not necessarily endorse it for all users, use it at your own risk!] 

Set this up and start it running on your machine. 
Then, when it's running and pointing at your local 9292 port (e.g. `ngrok http 9292`), it will give you a url
(e.g. `https://1234-56-7-250-215.ngrok.io`) that you can add to your 
Slack instance api/application Interactivity & shortcuts section with the suffix `/interactive`
(e.g. `https://1234-56-7-250-215.ngrok.io/interactive`) this will allow callbacks from slack button clicks to your local test server while ngrok runs

## Deploying

This is handled via github actions - on a pull request being merged to master, rspec and rubocop run.  

As long as they are successful, a deploy job runs that will build a new docker container, push it to ECR and then apply that docker tag to the K8s cluster

<img src="https://user-images.githubusercontent.com/6757677/102602821-f4ae8d00-4119-11eb-8f81-0d26f4564f59.png" width=50% height=50%>

After approx ~3 minutes the pods should have updated and the bot should respond to `hi` or your new command
