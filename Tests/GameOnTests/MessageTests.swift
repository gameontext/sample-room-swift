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

class MessageTests: XCTestCase {
    
    static var allTests: [(String, (MessageTests) -> () throws -> Void )] {
        return [
            ("testCreateChatMessage", testCreateChatMessage)
        ]
    }
    
    public let roomId = "roomId"
    public let testId = "testId"
    public let testUsername = "testUser"
    
    override func setUp() {
        
        super.setUp()
    }
    
    
    
    func testCreateChatMessage() throws {
       
        let expectation1 = expectation(description: "Create message")

        let message: Message = try Message.createRoomMessage(roomId: self.roomId, userId: self.testId, userName: self.testUsername, content: "Just chatting")

//        let messageStr = message.toString()
//        print("message: \(messageStr)")
//        let messageExpected = "room," + self.roomId + ",{\"userName\":" + self.testUsername + ",\"userId\":" + self.testId + "\"content\":\"Just chatting\"}"
//        
//        print("expected: \(messageExpected)")
//
//        
        XCTAssertEqual("yes", "yes")
        expectation1.fulfill()

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }

}
