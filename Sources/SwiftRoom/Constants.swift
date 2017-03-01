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

public struct Constants {
    
    struct Room {
        
        static let lookUnknown = "It doesn't look interesting"
        
        static func unknownCommand(command: String) -> String {
         
            return "This room is a basic model. It doesn't understand \(command)"
        }
        
        static let unspecifiedDirection = "You didn't say which way you wanted to go."
        
        static func unknownDirection(direction: String) -> String {
            
            return "There isn't a door in this direction: \(direction)"
        }
        
        static func helloAll(name: String) -> String {
            
            return "\(name) is here"
        }
        
        static let helloUser = "Welcome!"
        
        static func goodbyeAll(name: String) -> String {
            
            return "\(name) has gone"
        }
        
        static let goodbyeUser = "Bye!"
        
    }
    
    struct Message {
        
        /**
         * prefix for bookmark: customize it! Just doing something here to make
         * it less likely to collide with other rooms.
         */
        static let prefix = "room-"
        
        /** JSON element specifying the type of message. */
        static let type = "type"
        
        /** Type of message to indicate room events */
        static let event = "event"
        
        /** */
        static let chat = "chat"
        
        /** JSON element specifying the user id. */
        static let userId = "userId"
        
        /** JSON element specifying the username. */
        static let username = "username"
        
        /** JSON element specifying the content of message. */
        static var content = "content"
        
        /** JSON element specifying the content bookmark. */
        static let bookmark = "bookmark"
        
        /** Messages sent to everyone */
        static let all = "*"
        
    }
}
