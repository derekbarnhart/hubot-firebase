util = require('util')
Q = require('q')
_ = require('lodash')
FirebaseClient = require("firebase")

try
  {Robot, Adapter, EnterMessage, LeaveMessage, TextMessage, User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot, Adapter, EnterMessage, LeaveMessage, TextMessage, User} = prequire 'hubot'


class Firebase extends Adapter


  getChatPath:(roomId)=> "/#{roomId}#{@options.chatPath}"

  trackRooms:()=>
    @client.on("child_added",
          (result)=>
            @watchRoom(result.key())
        )
    @client.on("child_removed",
          (result)=>
            @unWatchRoom(result.key())
        )

  watchRoom:( roomId )=>
    @robot.logger.info("Now watching room: #{roomId}")
    roomRef = @client.child @getChatPath roomId
    roomRef.limitToLast(1).on "child_added", @chatHandler roomId

  unWatchRoom:( roomId )=>
    @robot.logger.info "No longer watching room: #{roomId}"
    roomRef = @client.child("#{roomId}@chatPath")
    roomRef.off "child_added", @chatHandler

  createNewUser:(userId)-> new User(userId, {})


  chatHandler: (roomId)=>
    (result)=>
      if userId is @robot.name
        return

      #Setup the user object
      userId = result.child( @options.msg.userIdPath ).val()
      userName = result.child( @options.msg.userNamePath ).val()
      user = @robot.brain.userForId userId,
                room:roomId
                name :userName

      messageId = result.key()
      messageContent = result.child( @options.msg.contentPath ).val()

      console.log(messageContent)


      message = new TextMessage( user, messageContent, messageId )
      #@robot.logger.info "#{userName}: #{messageContent}"

      @robot.receive message

  send: (envelope, strings...) ->
    @robot.logger.info "Send"
    roomRef = @client.child @getChatPath envelope.room

    buildPath = (value, nsPath, obj) ->
      #The first element in the array is our namespace
      ns = nsPath.shift()
      if nsPath.length is 0
        return obj[ns] = value
      obj[ns] ?= {}
      if _.isObject(obj[ns])
          obj[ns] = {}
          #good to go
      return buildPath( value, nsPath, obj[ns])

    idPath = _.rest @options.msg.userIdPath.split('/')
    namePath = _.rest @options.msg.userNamePath.split('/')
    contentPath = _.rest @options.msg.contentPath.split('/')

    obj = {}
    buildPath @robot.name,   idPath,       obj
    buildPath @robot.name,   namePath,     obj
    buildPath strings[0],    contentPath,  obj
    roomRef.push(obj)


    # reply: (envelope, strings...) ->
    #   @robot.logger.info "Reply"

  run: ->

    requiredEnvVars =[
      'HUBOT_FIREBASE_APP_URL'
      'HUBOT_FIREBASE_ROOMS_PATH'
      'HUBOT_FIREBASE_CHAT_PATH'
      'HUBOT_FIREBASE_MSG_USERID_PATH'
      'HUBOT_FIREBASE_MSG_USERNAME_PATH'
      'HUBOT_FIREBASE_MSG_CONTENT_PATH'
    ]

    errors = requiredEnvVars.filter ( envVar )-> !process.env[envVar]?

    if errors.length > 0
      errorStr = 'You must provide the following environment variables:\n'
      errorStr += errors.join('\n')
      throw new Error(errorStr)

    @options =
      baseRef : process.env.HUBOT_FIREBASE_APP_URL
      roomsPath : process.env.HUBOT_FIREBASE_ROOMS_PATH
      chatPath : process.env.HUBOT_FIREBASE_CHAT_PATH
      msg:
          userIdPath: process.env.HUBOT_FIREBASE_MSG_USERID_PATH
          userNamePath: process.env.HUBOT_FIREBASE_MSG_USERNAME_PATH
          contentPath: process.env.HUBOT_FIREBASE_MSG_CONTENT_PATH


    @robot.logger.info("#{@options.baseRef}#{@options.roomsPath}")
    @client = new FirebaseClient("#{@options.baseRef}#{@options.roomsPath}")

    @trackRooms()
    @robot.logger.info "Run"
    @emit "connected"

  shutdown: () ->
    @robot.shutdown()
    process.exit 0



exports.use = (robot) ->
  new Firebase robot