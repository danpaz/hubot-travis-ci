chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'hubot-travis-ci', ->
  beforeEach ->

    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/hubot-travis-ci')(@robot)

  it 'should register a respond listener', ->
    expect(@robot.respond).to.have.been.calledWith \
      /travis (restart|cancel) (.*)$/i

