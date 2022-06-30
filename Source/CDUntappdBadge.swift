//
//  CDUntappdBadge.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
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

#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif

public struct CDUntappdBadge: Decodable {

    public let id: Int?
    public let name: String?
    public let description: String?
    public let smallImage: URL?
    public let mediumImage: URL?
    public let largeImage: URL?
    public let userBadgeId: Int?
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "badge_id"
        case name = "badge_name"
        case description = "badge_description"
        case smallImage = "badge_image.sm"
        case mediumImage = "badge_image.md"
        case largeImage = "badge_image.lg"
        case userBadgeId = "user_badge_id"
        case createdAt = "created_at"
    }
}
