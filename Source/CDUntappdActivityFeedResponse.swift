//
//  CDUntappdActivityFeedResponse.swift
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

/// Top-level response for the check-in activity feed endpoints (activity feed, user/beer/brewery/venue check-in history).
public struct CDUntappdActivityFeedResponse: Decodable, Sendable {

    public var metadata: CDUntappdMetadata?
    public var checkins: [CDUntappdCheckin]?

    private enum RootKeys: String, CodingKey {
        case metadata = "meta"
        case response
    }

    private enum ResponseKeys: String, CodingKey {
        case checkins
    }

    private enum ItemsKeys: String, CodingKey {
        case items
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        metadata = try root.decodeIfPresent(CDUntappdMetadata.self, forKey: .metadata)
        if let responseContainer = try? root.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response),
           let checkinsContainer = try? responseContainer.nestedContainer(keyedBy: ItemsKeys.self, forKey: .checkins) {
            checkins = try checkinsContainer.decodeIfPresent([CDUntappdCheckin].self, forKey: .items)
        } else {
            checkins = nil
        }
    }
}
