# Description:
#   A way to interact with Travis CI builds.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TRAVIS_ACCESS_TOKEN - API key
#   HUBOT_TRAVIS_API_HOST - API endpoint
#   HUBOT_TRAVIS_ORGNAME - Organization, user, or project name
#   HUBOT_TRAVIS_URL - e.g. "https://travis-ci.org"
#
# Commands:
#   hubot travis restart <repo> - Restart a travis build
#   hubot travis cancel <repo> - Cancel a travis build

# Constants.
TRAVIS_ACCEPT_HEADER = 'application/vnd.travis-ci.2+json'

# Configs.
apiToken  = process.env.HUBOT_TRAVIS_ACCESS_TOKEN ? null
apiHost   = process.env.HUBOT_TRAVIS_API_HOST ? null
orgName   = process.env.HUBOT_TRAVIS_ORGNAME ? null
travisUrl = process.env.HUBOT_TRAVIS_URL ? null

# Messages.
NOT_FOUND_MSG     = 'Travis CI could not find that endpoint.'
TOKEN_MISSING_MSG = 'The HUBOT_TRAVIS_ACCESS_TOKEN is not set.'
CANCEL_MSG        = 'Build has been successfully cancelled.'

module.exports = (robot) ->

  unless apiToken?
    robot.logger.warning TOKEN_MISSING_MSG

  # @param   opts   [Object]   Options.
  # @option  url    [String]   Request URL.
  # @option  method [String]   HTTP request method.
  # @option  token  [String]   API token.
  # @param   cb     [Function] Callback.
  _request = (opts = {}, cb) ->

    robot.http(opts.url)
      .header('Accept', TRAVIS_ACCEPT_HEADER)
      .header('Authorization', "token #{opts.token}")
      .request(opts.method) (err, res, body) ->
        return cb err if err?

        if body? and body isnt ''
          data = JSON.parse body

        if data?.file is 'not found'
          err = new Error NOT_FOUND_MSG
          return cb err

        cb err, data

  _getLastBuild = (repo, cb) ->
    url = [apiHost, 'repos', orgName, repo].join '/'

    _request
      url:    url
      method: 'GET'
      token:  apiToken
      , (err, data) ->

        # Example body data
        # {
        #   "repo": {
        #     "id": 82,
        #     "slug": "sinatra/sinatra",
        #     "description": "Classy web-development dressed in a DSL",
        #     "last_build_id": 23436881,
        #     "last_build_number": "792",
        #     "last_build_state": "passed",
        #     "last_build_duration": 2542,
        #     "last_build_started_at": "2014-04-21T15:27:14Z",
        #     "last_build_finished_at": "2014-04-21T15:40:04Z",
        #     "github_language": "Ruby"
        #   }
        # }

        cb err, data

  _restartOrCancelBuild = (buildId, action, cb) ->
    url = [apiHost, 'builds', buildId, action].join '/'

    _request
      url:    url
      method: 'POST'
      token:  apiToken
      , (err, data) ->

        # Example body data
        # {
        #   "result": true,
        #   "flash": [
        #     {
        #       "notice": "The build was successfully restarted."
        #     }
        #   ]
        # }

        cb err, data

  robot.respond /travis (restart|cancel) (.*)$/i, (msg) ->
    action = msg.match[1].toLowerCase()
    repo   = msg.match[2]

    _getLastBuild repo, (err, data) ->

      if err?
        msg.send err.message
        return

      lastBuild =
        url: [travisUrl, orgName, repo].join '/'
        num: data.repo.last_build_number
        id:  data.repo.last_build_id

      _restartOrCancelBuild lastBuild.id, action, (err, data) ->

        if err?
          msg.send err.message
          return

        if data?.error?
          flashMsg  = data.error.message + "."
        else if data?
          flashData = data?.flash?[0]
          flashMsg  = flashData.notice ? flashData.error
        # Travis returns an empty body on cancel command, so we mock a message.
        else if action is 'cancel'
          flashMsg  = CANCEL_MSG

        # Example: "The build was successfully restarted. Build #137."
        # Formatted specifically for Slack's URL detection.
        outputMsg = "#{flashMsg} Build <#{lastBuild.url}|\##{lastBuild.num}>."

        msg.send outputMsg
