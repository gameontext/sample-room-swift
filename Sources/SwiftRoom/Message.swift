/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import SwiftyJSON

public class Message {
    
    
    // The first segment in the WebSocket protocol for Game On!
    // This is used as a primitive routing filter as messages flow through the system
    public enum Target: String {
        case
        
        // Protocol acknowledgement, sent on RoomEndpoint.connected
        ack,
        // Message sent to player(s)
        player,
        // Message sent to a specific player to trigger a location change (they are allowed to exit the room)
        playerLocation,
        // Message sent to the room
        room,
        // A player enters the room
        roomHello,
        // A player reconnects to the room (e.g. reconnected session)
        roomJoin,
        // A player's has disconnected from the room without leaving it
        roomPart,
        // A player leaves the room
        roomGoodbye
    }
    
    let target: Target
    
    // Target id for the message (This room, specific player, or '*')
    let targetId: String
    
    // Stringified JSON payload
    let payload: String
    
    // userId and username will be present in JSON payload
    let userId: String?
    
    let username: String?
    
    // Parse a string read from the WebSocket
    public init(message: String) throws {
        /*
         * Expected format:
         *    target,targetId,{"json": "payload"}
         */
        // Extract target
        guard let targetIndex = message.characters.index(of: ",") else {
            throw SwiftRoomError.invalidMessageFormat
        }
        
        let targetStr = message.substring(to: targetIndex)
        
        guard let targetVal = Target.init(rawValue: targetStr) else {
            throw SwiftRoomError.invalidMessageFormat
        }
        
        self.target = targetVal
        
        var remaining = message.substring(from: targetIndex).trimmingCharacters(in: .whitespacesAndNewlines)

        // remaining = `,targetId,{"json": "payload"}`. Now remove the ','
        remaining.remove(at: remaining.startIndex)
        
        // Extract targetId
        guard let targetIdIndex = remaining.characters.index(of: ",") else {
            throw SwiftRoomError.invalidMessageFormat
        }

        self.targetId = remaining.substring(to: targetIdIndex)
        
        // Extract JSON
        guard let jsonIndex = remaining.characters.index(of: "{") else {
            throw SwiftRoomError.invalidMessageFormat
        }

        self.payload = remaining.substring(from: jsonIndex)
        
        guard let payloadJSON = payload.data(using: String.Encoding.utf8) else {
            throw SwiftRoomError.errorInJSONProcessing
        }
        
        let json = JSON(data: payloadJSON)
        
        self.userId = json["userId"].stringValue
        self.username = json["username"].stringValue
        
    }
    
    public init(target: Target, targetId: String? = "", payload: String) throws {
        
        self.target = target
        self.targetId = targetId!
        self.payload = payload
        
        guard let payloadJSON = payload.data(using: String.Encoding.utf8) else {
            throw SwiftRoomError.errorInJSONProcessing
        }
        
        let json = JSON(data: payloadJSON)
        
        self.userId = json["userId"].stringValue
        self.username = json["username"].stringValue
    }
    
    
    public static func createAckMessage() -> String {
        return Target.ack.rawValue + "," + "{\"version\":[1,2]}"
    }
    
    // Create an event targeted at a specific player (use broadcast to send to all connections)
    public static func createSpecificEvent(userId: String, messageForUser: String) throws -> Message {
        //  player,<userId>,{
        //      "type": "event",
        //      "content": {
        //          "<userId>": "specific to player"
        //          },
        //      "bookmark": "String representing last message seen"
        //  }
        
        let payload: JSON = [
            Constants.Message.type: Constants.Message.event,
            Constants.Message.content: [
                userId: messageForUser
            ],
            Constants.Message.bookmark: Constants.Message.prefix + uniqueStr()
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.player, targetId: userId, payload: payloadStr)
    }
    
    
    // Construct an event that broadcasts to all players. The first string will
    // be the message sent to all players. Additional messages should be specified
    // in pairs afterwards, "userId1", "player message 1", "userId2", "player message 2".
    //If the optional specified messages are uneven, only the general message will be sent.
    public static func createBroadcastEvent(allContent: String? = "", pairs: [String]?) throws -> Message {
        //  player,*,{
        //      "type": "event",
        //      "content": {
        //          "*": "general text for everyone",
        //          "<userId>": "specific to player"
        //      },
        //      "bookmark": "String representing last message seen"
        //  }
                
        let contentStr: String = buildBroadcastContent(content: allContent, pairs: pairs)
    
        guard let contentData = contentStr.data(using: String.Encoding.utf8) else {
            throw SwiftRoomError.errorInJSONProcessing
        }
        
        let contentJSON = JSON(data: contentData)

        let payload: JSON = [
            Constants.Message.type: Constants.Message.event,
            Constants.Message.content: contentJSON.object,
            Constants.Message.bookmark: Constants.Message.prefix + uniqueStr()
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.player, targetId: Constants.Message.all, payload: payloadStr)
        
    }
    
    public static func createChatMessage(username: String, message: String) throws ->  Message {
        //  room,*,{...}
        //  {
        //    "type": "chat",
        //    "username": "username",
        //    "content": "<message>",
        //    "bookmark": "String representing last message seen"
        //  }
        
        let payload: JSON = [
            Constants.Message.type: Constants.Message.chat,
            Constants.Message.username: username,
            Constants.Message.content: message,
            Constants.Message.bookmark: Constants.Message.prefix + uniqueStr()
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.room, targetId: Constants.Message.all, payload: payloadStr)
        
    }
    
    // Send information about the room to the client. This message is sent after receiving a `roomHello`.
    public static func createLocationMessage(userId: String, roomDescription: RoomDescription) throws -> Message {
        //  player,<userId>,{
        //      "type": "location",
        //      "name": "Room name",
        //      "fullName": "Room's descriptive full name",
        //      "description", "Lots of text about what the room looks like",
        //      "exits": {
        //          "shortDirection" : "currentDescription for Player",
        //          "N" :  "a dark entranceway"
        //      },
        //      "commands": {
        //          "/custom" : "Description of what command does"
        //      },
        //      "roomInventory": ["itemA","itemB"]
        //  }
        
        let commands: JSON = JSON(roomDescription.commands)
        let inventory: JSON = JSON(roomDescription.inventory)
        
        let payload: JSON = [
            Constants.Message.type: "location",
            "name": roomDescription.name,
            "fullName": roomDescription.fullName,
            "description": roomDescription.description,
            "commands": commands.object,
            "roomInventory": inventory.object
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.player, targetId: userId, payload: payloadStr)
        
    }
    
    // Indicates that a player can leave by the requested exit (`exitId`).
    public static func createExitMessage(userId: String, exitId: String?, message: String?) throws -> Message {
        
        guard  let exitId = exitId else {
            throw SwiftRoomError.missingExitId
        }
        
        //  playerLocation,<userId>,{
        //      "type": "exit",
        //      "content": "You exit through door xyz... ",
        //      "exitId": "N"
        //      "exit": { ... }
        //  }
        // The exit attribute describes an exit the map service wouldn't know about..
        // This would have to be customized..
        
        let payload: JSON = [
            Constants.Message.type: "exit",
            "exitId": exitId,
            Constants.Message.content: message ?? "Fare thee well"
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.playerLocation, targetId: userId, payload: payloadStr)
        
    }
    
    // Used for test purposes, create a message targeted for the room
    public static func createRoomMessage(roomId: String, userId: String, username: String, content: String) throws -> Message {
        //  room,<roomId>,{
        //      "username": "<username>",
        //      "userId": "<userId>"
        //      "content": "<message>"
        //  }
        let payload: JSON = [
            Constants.Message.userId: userId,
            Constants.Message.username: username,
            Constants.Message.content: content
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.room, targetId: roomId, payload: payloadStr)
        
    }
    
    // Used for test purposes, create a room hello message
    public static func createRoomHello(roomId: String, userId: String, username: String, version: Int) throws -> Message {
        
        //  roomHello,<roomId>,{
        //      "username": "<username>",
        //      "userId": "<userId>",
        //      "version": 1|2
        //  }
        let payload: JSON = [
            Constants.Message.userId: userId,
            Constants.Message.username: username,
            "version": version
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.roomHello, targetId: roomId, payload: payloadStr)
        
    }
    
    // Used for test purposes, create a room goodbye message
    public static func createRoomGoodbye(roomId: String, userId: String, username: String) throws -> Message {
        //  roomGoodbye,<roomId>,{
        //      "username": "<username>",
        //      "userId": "<userId>"
        //  }
        
        let payload: JSON = [
            Constants.Message.userId: userId,
            Constants.Message.username: username,
            ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.roomGoodbye, targetId: roomId, payload: payloadStr)
        
    }
    
    // Used for test purposes, create a room join message
    public static func createRoomJoin(roomId: String, userId: String, username: String, version: Int) throws -> Message {
        //  roomJoin,<roomId>,{
        //      "username": "<username>",
        //      "userId": "<userId>",
        //      "version": 2
        //  }
        
        let payload: JSON = [
            Constants.Message.userId: userId,
            Constants.Message.username: username,
            "version": version
        ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.roomJoin, targetId: roomId, payload: payloadStr)
        
    }
    
    // Used for test purposes, create a room part message
    public static func createRoomPart(roomId: String, userId: String, username: String) throws -> Message {
        //  roomPart,<roomId>,{
        //      "username": "<username>",
        //      "userId": "<userId>"
        //  }
        
        let payload: JSON = [
            Constants.Message.userId: userId,
            Constants.Message.username: username,
            ]
        
        let payloadStr = try jsonToString(json: payload)
        
        return try Message(target: Target.roomPart, targetId: roomId, payload: payloadStr)
    }
        
    public func toString() -> String {
        
        return self.target.rawValue + "," + targetId + "," + payload
        
    }
    
    private static func uniqueStr() -> String {
        return UUID().uuidString
    }
    
    private static func jsonToString(json: JSON) throws -> String {
        
        let data = try json.rawData()
        
        guard let jsonString: String = String(bytes: data, encoding: String.Encoding.utf8) else {
            throw SwiftRoomError.errorInJSONProcessing
        }
        
        return jsonString
    }
    
    public static func buildBroadcastContent(content: String?, pairs: [String]?) -> String {
        
        var contentStr: String = "{"
        
        if let content = content {
            contentStr += Constants.Message.all + ": \(content)"
        }
        
        // only add additional messages if there is an even number
        if let pairs = pairs, (pairs.count % 2) == 0 {
            
            for i in stride(from:0, through: pairs.count-1, by: 2) {
                
                if(i != 0 ) {
                    contentStr += ","
                }
                
                contentStr += pairs[i] + ":" + pairs[i+1]
                
            }
        }
        
        return contentStr + "}"
        
    }
    
}
