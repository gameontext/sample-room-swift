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
 **/

import LoggerAPI
import Foundation
import KituraWebSocket
import SwiftyJSON
//import HeliumLogger

public class RoomImplementation {
        
    var roomDescription = RoomDescription()
    
    public func handleMessage(messageStr: String, endpoint: RoomEndpoint, connection: WebSocketConnection) throws {
        
        let message: Message = try Message(message: messageStr)
        
        let userId = message.userId ?? ""
        let username = message.username ?? ""
        let target = message.target.rawValue

        switch target {
        case "roomHello":
            
            // Send location message
            try endpoint.sendMessage(connection: connection,
                                 message: Message.createLocationMessage(userId: userId, roomDescription: self.roomDescription))
            
            // Say hello to a new person in the room
            try endpoint.sendMessage(connection: connection,
                                     message: Message.createBroadcastEvent(
                                        allContent: Constants.Room.helloAll(name: username),
                                        pairs: [userId, Constants.Room.helloUser]))
            
            break;
            
        case "roomJoin":
            
            try endpoint.sendMessage(connection: connection,
                                 message: Message.createLocationMessage(userId: userId, roomDescription: self.roomDescription))
            
            break;
            
        case "roomGoodbye":
            
            // Say goodbye to person leaving the room
            try endpoint.sendMessage(connection: connection,
                                 message: Message.createBroadcastEvent(
                                    allContent: Constants.Room.goodbyeAll(name: username),
                                    pairs: [userId, Constants.Room.goodbyeUser] ))
            
            break;
            
        case "roomPart":
            // TODO ??
            break;
            
        case "room":
            
            // This message will be either a command or a chat
            guard let payloadJSON = (message.payload).data(using: String.Encoding.utf8) else {
                throw SwiftRoomError.errorInJSONProcessing
            }
            
            let json = JSON(data: payloadJSON)
            let content = json[Constants.Message.content].stringValue
            
            if messageIsCommand(content: content) {
                try processCommand(message: message, content: content, endpoint: endpoint, connection: connection)
            }
            else {
                try endpoint.sendMessage(connection: connection,
                                         message: Message.createChatMessage(username: username, message: content))
            }
            
            break;
        default:
            Log.info("unknown message")
        }
        
        return
    }
    
    private func processCommand(
        message: Message,
        content: String,
        endpoint: RoomEndpoint,
        connection: WebSocketConnection) throws {
        
//        HeliumLogger.use()
        
        let contentTrimmed = content.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let userId = message.userId ?? ""
        
        let username = message.username ?? ""
        
        let firstWord: String, remainder: String?
        
        if let index = contentTrimmed.characters.index(of: " ") {
            firstWord = contentTrimmed.substring(to: index)
            remainder = contentTrimmed.substring(from: index).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else {
            firstWord = contentTrimmed
            remainder = nil
        }
        
        switch firstWord {
        case "/heygirl":
            
            try endpoint.sendMessage(connection: connection, message: Message.createLocationMessage(userId: userId, roomDescription: self.roomDescription))
            break;
            
        case "/increment":
            
            self.roomDescription.count += 1
            try endpoint.sendMessage(connection: connection, message: Message.createChatMessage(username: username, message: "Count has been incremented \(self.roomDescription.count)"))
        break;
        case "/addthing":
            
            if let remainder = remainder {
                self.roomDescription.addInventoryItem(item: remainder)
            }
            
            Log.info("adding thing with remainder = \(remainder)")
            
            try endpoint.sendMessage(connection: connection, message: Message.createLocationMessage(userId: userId, roomDescription: self.roomDescription))
            break;
        case "/go":
            
            let exitId = getDirection(direction: remainder)
            
            if let exitId = exitId {
                
                try endpoint.sendMessage(connection: connection,
                                         message: Message.createExitMessage(userId: userId, exitId: exitId, message: nil))
            }
            else {
                
                if ( remainder == nil) {
                    try endpoint.sendMessage(connection: connection,
                                     message: Message.createSpecificEvent(userId: userId, messageForUser: Constants.Room.unspecifiedDirection))
                }
                else {
                    if let remainder = remainder {
                        try endpoint.sendMessage(connection: connection,
                                                 message: Message.createSpecificEvent(
                                                    userId: userId, messageForUser:
                                                    Constants.Room.unknownDirection(direction: remainder)))
                    }
                }
            }
            
            Log.info("/go")
            break;
        
        case "/look", "/examine":
            if let remainder = remainder, remainder.range(of: "room") == nil {
                try endpoint.sendMessage(connection: connection,
                                     message: Message.createSpecificEvent(userId: userId, messageForUser: Constants.Room.lookUnknown))
                
            }
            else {
                // This is looking at or examining the entire room. Send the player location message,
                // which includes the room description and inventory
                
                try endpoint.sendMessage(connection: connection, message: Message.createLocationMessage(userId: userId, roomDescription: self.roomDescription))
            }
            
            
            Log.info("/look")
            break;
        
        case "/ping":
            // Custom command /ping is added for testing
            let allContent: String, toUserId: String
            
            if let remainder = remainder {
                allContent = "Ping! Pong sent to " + username + ": " + remainder
                toUserId = "Ping! Pong " + remainder
            }
            else {
                allContent = "Ping! Pong sent to " + username
                toUserId = "Ping! Pong"
            }
            
            try endpoint.sendMessage(connection: connection,
                                 message: Message.createBroadcastEvent(
                                    allContent: allContent,
                                    pairs: [userId, toUserId]))
            
           
            Log.info("/ping")
            break;
        
        default:
            try endpoint.sendMessage(connection: connection,
                                     message: Message.createSpecificEvent(userId: userId, messageForUser: Constants.Room.unknownCommand(command: content)))
            break;
        }
        
    }
    
    private func messageIsCommand(content: String) -> Bool {
        
        if let first = content.characters.first, first == "/" {
            return true
        }
        
        return false
    }
    
    /**
     * Given a lower case string describing the direction someone wants
     * to go (/go N, or /go North), filter or transform that into a recognizable
     * id that can be used as an index into a known list of exits. Always valid
     * are n, s, e, w. If the string doesn't match a known exit direction,
     * return null.
     *
     * @param lowerDirection String read from the provided message
     * @return exit id or null
     */
    private func getDirection(direction: String?) -> String? {
        
        guard let direction = direction else {
            return nil
        }
        
        switch(direction) {
            
        case "north", "south", "east", "west":
            return String(direction.characters.first!)
            
        case "n", "s", "e", "w":
            // Assume N/S/E/W are managed by the map service.
            return direction;
            
        default:
            return nil;
        }
    }
    
}
