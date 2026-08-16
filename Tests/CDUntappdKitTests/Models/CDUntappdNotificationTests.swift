//
//  CDUntappdNotificationTests.swift
//  CDUntappdKitTests
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdNotification Tests")
struct CDUntappdNotificationTests {

    @Test
    func decodesNotificationWithNestedUserAndCheckin() throws {
        let json = """
        {
          "notification_id": 1,
          "type": "toast",
          "created_at": "Thu, 01 Jan 2015 00:00:00 +0000",
          "user": { "uid": 10, "user_name": "testuser" },
          "checkin": { "checkin_id": 100 }
        }
        """.data(using: .utf8)!
        let notification = try JSONDecoder().decode(CDUntappdNotification.self, from: json)
        #expect(notification.id == 1)
        #expect(notification.type == "toast")
        #expect(notification.user?.username == "testuser")
        #expect(notification.checkin?.id == 100)
    }
}
