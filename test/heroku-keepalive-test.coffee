chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'heroku-keepalive', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/heroku-keepalive')(@robot)

  it 'registers a respond listener', ->
    expect(@robot.respond).to.have.been.calledWith(/hello/)

  it 'registers a hear listener', ->
    expect(@robot.hear).to.have.been.calledWith(/orly/)
