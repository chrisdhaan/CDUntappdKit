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

    /// Matches Alamofire's `CharacterSet.afURLQueryAllowed` — RFC 3986's query-allowed set minus
    /// the general and sub-delimiters Alamofire additionally escapes for safety. `URLComponents`'s
    /// default `queryItems` escaping does not escape this wider set (notably it leaves `+` alone,
    /// which servers commonly form-decode as a literal space), so the query string is built and
    /// percent-encoded manually below instead of relying on `queryItems`.
    private static let queryAllowedCharacters: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()

    /// Builds a `key=value&key2=value2`-style string, sorted by key, using `queryAllowedCharacters`
    /// escaping. Shared by both the query-string (`GET`) and httpBody (`POST`) encoders below —
    /// the two differ only in *where* this string ends up on the request, not how it's built.
    private static func encodedQueryString(from parameters: Parameters) -> String {
        parameters
            .sorted { $0.key < $1.key }
            .map { key, value -> String in
                let stringValue: String = if let boolValue = value as? Bool {
                    boolValue ? "1" : "0"
                } else {
                    String(describing: value)
                }
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: queryAllowedCharacters) ?? key
                let encodedValue = stringValue.addingPercentEncoding(withAllowedCharacters: queryAllowedCharacters) ?? stringValue
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
    }

    /// Builds a `GET` request with URL-encoded query parameters. Replaces Alamofire's
    /// `URLEncoding.default`, matching its existing wire behavior.
    static func urlRequest(for url: URL, parameters: Parameters) throws -> URLRequest {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }

        if !parameters.isEmpty {
            components.percentEncodedQuery = encodedQueryString(from: parameters)
        }

        guard let requestURL = components.url else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }

    /// Builds a `POST` request with form-URL-encoded parameters in the httpBody, and — as a
    /// defensive hedge — the same parameters mirrored into the query string. Replaces
    /// Alamofire's `URLEncoding.httpBody`, which uses the same escaping as `URLEncoding.default`
    /// (see `encodedQueryString(from:)`), just written to the body instead of the query string.
    ///
    /// The query string is populated in addition to the body because this repository's own
    /// historical Objective-C implementation special-cased `checkin/add` to send `access_token`
    /// in the query string even though it was a `POST`, suggesting some Untappd write endpoints
    /// may expect OAuth credentials there rather than (or in addition to) the body. Since this
    /// layer works on a flat `Parameters` dictionary with no way to distinguish "auth" keys from
    /// "payload" keys, all parameters are sent in both places; a server reading from either
    /// location gets what it needs, and redundant data in the other location is harmless.
    static func httpBodyRequest(for url: URL, parameters: Parameters) throws -> URLRequest {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }

        if !parameters.isEmpty {
            components.percentEncodedQuery = encodedQueryString(from: parameters)
        }

        guard let requestURL = components.url else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = Data(encodedQueryString(from: parameters).utf8)
        return urlRequest
    }
}
