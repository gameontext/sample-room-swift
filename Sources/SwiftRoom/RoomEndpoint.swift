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
import Dispatch

/**
 * This is the WebSocket endpoint for a room. varinstance of this class
 * will be created for every connected client.
 * https://book.gameontext.org/microservices/WebSocketProtocol.html
 */

public class RoomEndpoint: WebSocketService {

    private var roomImplementation: RoomImplementation = RoomImplementation()
    
    private let connectionsLock = DispatchSemaphore(value: 1)
    
    private var connections = [String: WebSocketConnection]()

    public init() {
        roomImplementation.roomDescription.addInventoryItem(item: "counter")
    }

    public func connected(connection: WebSocketConnection) {

        Log.info("A new connection has been made to the room.")

        connections[connection.id] = connection

        connection.send(message: Message.createAckMessage())

    }

    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        
//        lockConnectionsLock()
        
        connections.removeValue(forKey: connection.id)
        Log.info("A connection to the room has been closed with reason \(reason.code())")
        
//        unlockConnectionsLock()
    }

    public func received(message: String, from: WebSocketConnection) {
        print("server received message: \(message)")
        
//        lockConnectionsLock()
        for (_, connection) in connections {

            do {
                try roomImplementation.handleMessage(messageStr: message, endpoint: self, connection: connection)
            }
            catch {
                Log.error("Error handling message in the room.")
            }
        }
//        unlockConnectionsLock()
    }

    public func received(message: Data, from: WebSocketConnection) {
        from.close(reason: .invalidDataType, description: "GameOn Swift room only accepts text messages")
        connections.removeValue(forKey: from.id)
    }

    public func sendMessage(connection: WebSocketConnection, message: Message) {
        print("server sending processed message to client: \(message.toString())")
//        lockConnectionsLock()
        connection.send(message: message.toString())
//        unlockConnectionsLock()
    }
    
//    private func lockConnectionsLock() {
//        _ = connectionsLock.wait(timeout: DispatchTime.distantFuture)
//    }
//    
//    private func unlockConnectionsLock() {
//        connectionsLock.signal()
//    }
}
