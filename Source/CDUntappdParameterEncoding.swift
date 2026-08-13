//
//  CDUntappdParameterEncoding.swift
//  CDUntappdKit
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

/// A dictionary of query parameters for an Untappd API request.
public typealias Parameters = [String: Any]

/// Builds `GET` requests with URL-encoded query parameters.
///
/// Replaces Alamofire's `URLEncoding.default`, matching its existing wire behavior:
/// `Bool` values are numerically encoded (`true` -> `"1"`, `false` -> `"0"`); every other
/// value is rendered with `String(describing:)`.
enum CDUntappdParameterEncoding {

    static func urlRequest(for url: URL, parameters: Parameters) throws -> URLRequest {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }

        if !parameters.isEmpty {
            components.queryItems = parameters.map { key, value in
                let stringValue: String = if let boolValue = value as? Bool {
                    boolValue ? "1" : "0"
                } else {
                    String(describing: value)
                }
                return URLQueryItem(name: key, value: stringValue)
            }
        }

        guard let requestURL = components.url else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
}
