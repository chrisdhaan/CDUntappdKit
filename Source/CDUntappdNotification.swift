//
//  CDUntappdNotification.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/16/26.
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

/// Represents a single Untappd notification (toast or comment).
public struct CDUntappdNotification: Decodable, Sendable {

    /// The unique notification identifier.
    public var id: Int?
    /// The notification type (e.g. `"toast"`, `"comment"`).
    public var type: String?
    public var createdAt: String?
    /// The user who triggered the notification.
    public var user: CDUntappdUser?
    /// The check-in the notification refers to.
    public var checkin: CDUntappdCheckin?

    enum CodingKeys: String, CodingKey {
        case id = "notification_id"
        case type
        case createdAt = "created_at"
        case user
        case checkin
    }
}
