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

public struct RoomDescription {

    var name = "swiftRoom"
    
    var fullName = "Swifty room"
    
    var description = "A new swifty room"
    
    var inventory = [String]()
    
    var count = 0
    
    var commands = [String: String]()
    
    public mutating func addInventoryItem(item: String) {
        
        self.inventory.append(item)
    }
    
    public mutating func removeInventoryItem(item: String) {
        
        if let index = inventory.index(of: item) {
            self.inventory.remove(at: index)
        }
    }
    
    public mutating func addCommand(command: String, description: String) {
        
        commands.updateValue(description, forKey: command)
    }
    
    public mutating func removeCommand(command: String) {
        
        commands.removeValue(forKey: command)
    }
}
