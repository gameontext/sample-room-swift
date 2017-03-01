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
import XCTest

@testable import SwiftRoom

class MessageCreationTests: XCTestCase {
    
    static var allTests: [(String, (MessageCreationTests) -> () throws -> Void )] {
        return [
            ("testCreateChatMessage", testCreateChatMessage),
            ("testBasicLocationMessage", testBasicLocationMessage),
            ("testDevelopedLocationMessage", testDevelopedLocationMessage),
            ("testCreateEventMessage", testCreateEventMessage),
            ("testCreatePlayerLocationMessage", testCreatePlayerLocationMessage),
            ("testCreateMessageWithString", testCreateMessageWithString),
            ("testCreateAckMessage", testCreateAckMessage)
        ]
    }
    
    public let roomId = "roomId"
    public let userId = "testId"
    public let username = "testUser"
   
    override func setUp() {
        
        super.setUp()
    }
    
    func testCreateChatMessage() throws {
       
        let expectation1 = expectation(description: "Create chat message")

        let message = try Message.createRoomMessage(roomId: self.roomId, userId: self.userId, username: self.username, content: "Just chatting")

        let messageStr = message.toString()
        print("** message: \(messageStr)")
        
        XCTAssert(messageStr.hasPrefix("room,\(self.roomId),{"))
        
        let payload = message.payload
        
        XCTAssert(payload.contains("\"content\":\"Just chatting\""))
        XCTAssert(payload.contains("\"username\":\"" + self.username + "\""))
        XCTAssert(payload.contains("\"userId\":\"" + self.userId + "\""))
 
        expectation1.fulfill()

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func testBasicLocationMessage() throws {
        
        let expectation1 = expectation(description: "Create basic location message")
        
        let roomDescription = RoomDescription()
        
        let basicMessage = try Message.createLocationMessage(
            userId: self.userId,
            roomDescription: roomDescription)
        
        
        let basicMessageStr = basicMessage.toString()
        
        XCTAssert(basicMessageStr.hasPrefix("player,\(self.userId),{"))
        
        let payload = basicMessage.payload
        
        XCTAssert(payload.contains("\"type\":\"location\""))
        XCTAssert(payload.contains("\"name\":\"\(roomDescription.name)\""))
        XCTAssert(payload.contains("\"fullName\":\"\(roomDescription.fullName)\""))
        XCTAssert(payload.contains("\"description\":\"\(roomDescription.description)\""))
        
        XCTAssert(roomDescription.commands.isEmpty)
        XCTAssert(roomDescription.inventory.isEmpty)
        
        expectation1.fulfill()
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })

    }
    
    func testDevelopedLocationMessage() throws {
        
        let expectation1 = expectation(description: "Create developed location message")
        
        var roomDescription = RoomDescription()
        
        roomDescription.addCommand(command: "/thunder", description: "A big storm is coming!")
        roomDescription.addCommand(command: "/shelter", description: "Take shelter from the storm")
        
        roomDescription.addInventoryItem(item: "umbrella")
        roomDescription.addInventoryItem(item: "rain coat")
        
        let message = try Message.createLocationMessage(
            userId: self.userId,
            roomDescription: roomDescription)
        
        
        let messageStr = message.toString()
        XCTAssert(messageStr.hasPrefix("player,\(self.userId),{"))
        
        let payload = message.payload
        
        XCTAssert(payload.contains("\"type\":\"location\""))
        XCTAssert(payload.contains("\"name\":\"\(roomDescription.name)\""))
        XCTAssert(payload.contains("\"fullName\":\"\(roomDescription.fullName)\""))
        XCTAssert(payload.contains("\"description\":\"\(roomDescription.description)\""))
        
        XCTAssert(roomDescription.commands.count == 2)
        XCTAssert(roomDescription.inventory.count == 2)
        

        let commands = roomDescription.commands
        let inventory = roomDescription.inventory
        
        XCTAssertNotNil(commands.index(forKey: "/thunder"))
        XCTAssertNotNil(commands.index(forKey: "/shelter"))
        
        XCTAssertNotNil(inventory.contains("umbrella"))
        XCTAssertNotNil(inventory.contains("rain coat"))
   
        expectation1.fulfill()
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
        
    }

    
    func testCreateEventMessage() throws {
        
    }
    
    func testCreatePlayerLocationMessage() throws {
        
    }
    
    func testCreateMessageWithString() throws {
        
    }
    
    func testCreateAckMessage() throws {
        
        let expectation1 = expectation(description: "Create ack message")
        
        let message = Message.createAckMessage()
        
        XCTAssertEqual(message, "ack,{\"version\":[1,2]}")
        
        expectation1.fulfill()
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
        
    }

}
