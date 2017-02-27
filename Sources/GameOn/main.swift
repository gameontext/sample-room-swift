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

import KituraNet
import KituraWebSocket
import LoggerAPI
import SwiftRoom

WebSocket.register(service: RoomEndpoint(), onPath: "room")

class RoomDelegate: ServerDelegate {
    public func handle(request: ServerRequest, response: ServerResponse) {}
}

// Add HTTP Server to listen on port 8090
let server = HTTP.createServer()
server.delegate = RoomDelegate()

do {
    try server.listen(on: 8090)
    ListenerGroup.waitForListeners()
} catch {
    Log.error("Error listening on port 8090: \(error).")
}
