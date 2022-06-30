//
//  CDUntappdMedia.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
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

public struct CDUntappdMedia: Decodable {

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

    enum CodingKeys: String, CodingKey {
        case id = "photo_id"
        case originalImage = "photo.photo_img_og"
        case smallImage = "photo.photo_img_sm"
        case mediumImage = "photo.photo_img_md"
        case largeImage = "photo.photo_img_lg"
        case checkInId = "checkin_id"
        case user = "user"
        case brewery = "brewery"
        case beer = "beer"
        case venue = "venue"
        case createdAt = "created_at"
    }
}
