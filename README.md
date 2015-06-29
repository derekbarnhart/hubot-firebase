# hubot-firebase
A simple firebase adapter for hubot




#Usage
You will need to add the following environment variables 
``` sh
#Database
export HUBOT_FIREBASE_APP_URL=<YOUR FIREBASE APP LOCATION>

#Chat room schema
export HUBOT_FIREBASE_ROOMS_PATH=<path to your chat room collection>
export HUBOT_FIREBASE_CHAT_PATH=<path to chat messages collection within each chatroom>

#Message schema
export HUBOT_FIREBASE_MSG_USERID_PATH=<path to user id within each message object>
export HUBOT_FIREBASE_MSG_USERNAME_PATH=<path to username within each message object>
export HUBOT_FIREBASE_MSG_CONTENT_PATH=<path to the actual message content>
```

#Example

```javascript
//Database
{
  applicationStores:{
      chatRooms:[ChatRoom]
  }
}

//ChatRoom schema
{
  name:String,
  chatMessages: [ChatMessage]
}

//ChatMessage schema
{
  userId: String,
  userProfile:{
    userName: String,
  }
  message: String
}
```

Given the above schemas my exports would look like this:

``` sh
#Database
export HUBOT_FIREBASE_APP_URL=<YOUR FIREBASE APP LOCATION>

#Chat room schema
export HUBOT_FIREBASE_ROOMS_PATH=/applicationStores/chatRooms
export HUBOT_FIREBASE_CHAT_PATH=/chatMessages

#Message schema
export HUBOT_FIREBASE_MSG_USERID_PATH=/userId
export HUBOT_FIREBASE_MSG_USERNAME_PATH=/userProfile/userName
export HUBOT_FIREBASE_MSG_CONTENT_PATH=/message
```



