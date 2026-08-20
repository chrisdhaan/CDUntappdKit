//
//  ViewController.swift
//  iOS Example
//
//  Created by Christopher de Haan on 8/4/17.
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

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hidden here (rather than always-hidden on the navigation controller) so the bar still
        // animates back in for the pushed JSON response screen and back out when returning here.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - UITableViewDataSource Methods

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        12
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CDUntappdEndpointCell", for: indexPath)

        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.untappdYellow() : UIColor.untappdBrown()
        cell.textLabel?.text = cellTitle(for: indexPath)
        cell.textLabel?.textColor = UIColor.white

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            "Untappd API Endpoints"
        default:
            ""
        }
    }
}

// MARK: - UITableView Delegate Methods

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Task {
            do {
                let response = try await response(forRow: indexPath.row)
                presentJSONResponse(response, title: cellTitle(for: indexPath))
            } catch {
                presentError(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.1
    }
}

private extension ViewController {

    /// Endpoint rows that need a real beer/brewery ID look one up first via a live search, rather
    /// than hardcoding an ID that could go stale or stop existing.
    struct DemoDataUnavailable: Error, CustomStringConvertible {
        let description: String
    }

    func cellTitle(for indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0: "user/info/{username}"
        case 1: "user/wishlist/{username}"
        case 2: "user/friends/{username}"
        case 3: "user/badges/{username}"
        case 4: "user/beers/{username}"
        case 5: "user/checkins/{username}"
        case 6: "search/beer"
        case 7: "search/brewery"
        case 8: "beer/info/{bid}"
        case 9: "brewery/info/{breweryId}"
        case 10: "beer/checkins/{bid}"
        case 11: "brewery/checkins/{breweryId}"
        default: ""
        }
    }

    func response(forRow row: Int) async throws -> Sendable {
        let apiClient = CDUntappdKitManager.shared.apiClient!
        switch row {
        case 0:
            return try await apiClient.fetchUserInfo(forUsername: "DehaanSolo", compact: false)
        case 1:
            return try await apiClient.fetchUserWishList(forUsername: "DehaanSolo", offset: 0, limit: 10, sort: .highestABV)
        case 2:
            return try await apiClient.fetchUserFriends(forUsername: "DehaanSolo", offset: 0, limit: 10)
        case 3:
            return try await apiClient.fetchUserBadges(forUsername: "DehaanSolo", offset: 0)
        case 4:
            return try await apiClient.fetchUserBeers(forUsername: "DehaanSolo", offset: 0, limit: 10, sort: .date)
        case 5:
            return try await apiClient.fetchUserActivityFeed(forUsername: "DehaanSolo", maxId: nil, minId: nil, limit: 10)
        case 6:
            return try await apiClient.searchBeers(query: "IPA", offset: 0, limit: 10, sort: .checkin)
        case 7:
            return try await apiClient.searchBreweries(query: "Russian River", offset: 0)
        case 8:
            let bid = try await demoBeerId()
            return try await apiClient.fetchBeerInfo(forBid: bid, compact: false)
        case 9:
            let breweryId = try await demoBreweryId()
            return try await apiClient.fetchBreweryInfo(forBreweryId: breweryId, compact: false)
        case 10:
            let bid = try await demoBeerId()
            return try await apiClient.fetchBeerActivityFeed(forBid: bid, maxId: nil, minId: nil, limit: 10)
        case 11:
            let breweryId = try await demoBreweryId()
            return try await apiClient.fetchBreweryActivityFeed(forBreweryId: breweryId, maxId: nil, minId: nil, limit: 10)
        default:
            throw DemoDataUnavailable(description: "No endpoint configured for row \(row).")
        }
    }

    func demoBeerId() async throws -> Int {
        let response = try await CDUntappdKitManager.shared.apiClient.searchBeers(query: "IPA", offset: 0, limit: 10, sort: .checkin)
        guard let bid = response.beers?.first?.beer?.id else {
            throw DemoDataUnavailable(description: "No beers found for demo search query \"IPA\".")
        }
        return bid
    }

    func demoBreweryId() async throws -> Int {
        let response = try await CDUntappdKitManager.shared.apiClient.searchBreweries(query: "Russian River", offset: 0)
        guard let breweryId = response.breweries?.first?.id else {
            throw DemoDataUnavailable(description: "No breweries found for demo search query \"Russian River\".")
        }
        return breweryId
    }

    func presentJSONResponse(_ response: Sendable, title: String) {
        let jsonText = JSONPrettyPrinter.string(from: response)
        let jsonResponseViewController = CDUntappdJSONResponseViewController(title: title, jsonText: jsonText)
        navigationController?.pushViewController(jsonResponseViewController, animated: true)
    }

    func presentError(_ error: Error) {
        let alertController = UIAlertController(title: "Request Failed", message: "\(error)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
