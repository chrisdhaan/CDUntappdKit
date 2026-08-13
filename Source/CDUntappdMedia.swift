//
//  CDUntappdMedia.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
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

public struct CDUntappdMedia: Decodable, Sendable {

    public var id: Int?
    public var originalImage: URL?
    public var smallImage: URL?
    public var mediumImage: URL?
    public var largeImage: URL?
    public var checkInId: Int?
    public var user: CDUntappdUser?
    public var brewery: CDUntappdBrewery?
    public var beer: CDUntappdBeer?
    public var venue: CDUntappdVenue?
    public var createdAt: String?

    private enum RootKeys: String, CodingKey {
        case id = "photo_id"
        case photo
        case checkInId = "checkin_id"
        case user
        case brewery
        case beer
        case venue
        case createdAt = "created_at"
    }

    private enum PhotoKeys: String, CodingKey {
        case original = "photo_img_og"
        case small = "photo_img_sm"
        case medium = "photo_img_md"
        case large = "photo_img_lg"
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        id = try root.decodeIfPresent(Int.self, forKey: .id)
        checkInId = try root.decodeIfPresent(Int.self, forKey: .checkInId)
        user = try root.decodeIfPresent(CDUntappdUser.self, forKey: .user)
        brewery = try root.decodeIfPresent(CDUntappdBrewery.self, forKey: .brewery)
        beer = try root.decodeIfPresent(CDUntappdBeer.self, forKey: .beer)
        venue = try root.decodeIfPresent(CDUntappdVenue.self, forKey: .venue)
        createdAt = try root.decodeIfPresent(String.self, forKey: .createdAt)

        if let photoContainer = try? root.nestedContainer(keyedBy: PhotoKeys.self, forKey: .photo) {
            originalImage = try photoContainer.decodeIfPresent(URL.self, forKey: .original)
            smallImage = try photoContainer.decodeIfPresent(URL.self, forKey: .small)
            mediumImage = try photoContainer.decodeIfPresent(URL.self, forKey: .medium)
            largeImage = try photoContainer.decodeIfPresent(URL.self, forKey: .large)
        } else {
            originalImage = nil
            smallImage = nil
            mediumImage = nil
            largeImage = nil
        }
    }
}
