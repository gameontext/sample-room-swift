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

import Kitura
import KituraNet
import KituraWebSocket
import LoggerAPI
import SwiftRoom
import Kitura


WebSocket.register(service: RoomEndpoint(), onPath: "room")

let router = Router()
router.all("/", middleware: StaticFileServer(path: "public"))

let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080

Kitura.addHTTPServer(onPort: port, with: router)

Kitura.run()

class RoomDelegate: ServerDelegate {
    
    public func handle(request: ServerRequest, response: ServerResponse) {
    }
}

// Add HTTP Server to listen on port 8080
let server = HTTP.createServer()
server.delegate = RoomDelegate()


do {
    try server.listen(on: 8080)
    ListenerGroup.waitForListeners()
} catch {
    Log.error("Error listening on port 8080: \(error).")
}
