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
import LoggerAPI
import KituraWebSocket

/**
 * This is the WebSocket endpoint for a room. An instance of this class
 * will be created for every connected client.
 * https://book.game-on.org/microservices/WebSocketProtocol.html
 */

public class RoomEndpoint: WebSocketService {
    
    private let roomImplementation: RoomImplementation = RoomImplementation()
    
    private var connections = [String: WebSocketConnection]()
    
    public func connected(connection: WebSocketConnection) {
        
        Log.info("A new connection has been made to the room.")
        
        connections[connection.id] = connection
        
        connection.send(message: Message.createAckMessage())
        
    }
    
    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        
        connections.removeValue(forKey: connection.id)
        Log.info("A connection to the room has been closed with reason \(reason.code())")
        
    }
    
    public func received(message: String, from: WebSocketConnection) {
        print("server received message: \(message)")
        for (_, connection) in connections {
            
            do {
                try roomImplementation.handleMessage(messageStr: message, endpoint: self, connection: connection)
            }
            catch {
                Log.error("Error handling message in the room.")
            }
        }
    }
    
    public func received(message: Data, from: WebSocketConnection) {
        from.close(reason: .invalidDataType, description: "GameOn Swift room only accepts text messages")
        connections.removeValue(forKey: from.id)
    }
    
    public func sendMessage(connection: WebSocketConnection, message: Message) {
        print("server sending processed message to client: \(message.toString())")
        connection.send(message: message.toString())
        
    }
}
