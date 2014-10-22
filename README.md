# hubot-travis-ci

A hubot script used to interact with Travis CI.

Work with both Travis CI for open source and Travis Pro for private projects.

## Installation 

```
npm install hubot-travis-ci --save
```

Add "hubot-travis-ci" to external-scripts.json.

## Configuration

    HUBOT_TRAVIS_ACCESS_TOKEN - API key
    HUBOT_TRAVIS_API_HOST - "https://api.travis-ci.com" or "https://api.travis-ci.org"
    HUBOT_TRAVIS_ORGNAME - Organization, user, or project name
    HUBOT_TRAVIS_URL - "https://<host>.travis-ci.com/<organization>" or "https://travis-ci.org/<organization>"


The Travis [integration token](http://docs.travis-ci.com/user/encryption-keys/) 
is semi-secret. 
Use the [official ruby client](https://github.com/travis-ci/travis#readme) to 
generate an encrypted token.

##  Commands:

    hubot travis restart <repo> - Restart a travis build
    hubot travis cancel <repo> - Cancel a travis build

## Notes:
This script was originally built for the [Slack](https://www.slack.com) 
hubot integration.

To get build notifications posted back into Slack setup the 
[existing Travis CI integration](https://slack.com/integrations).

Refer to the [Travis CI API docs](http://docs.travis-ci.com/api/).
