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
        3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CDUntappdEndpointCell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.backgroundColor = UIColor.untappdYellow()
            cell.textLabel?.text = "user/info/{username}"
            cell.textLabel?.textColor = UIColor.white
        case 1:
            cell.backgroundColor = UIColor.untappdBrown()
            cell.textLabel?.text = "user/wishlist/{username}"
            cell.textLabel?.textColor = UIColor.white
        case 2:
            cell.backgroundColor = UIColor.untappdYellow()
            cell.textLabel?.text = "user/friends/{username}"
            cell.textLabel?.textColor = UIColor.white
        default:
            break
        }

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
        switch indexPath.row {
        case 0:
            Task {
                do {
                    let response = try await CDUntappdKitManager.shared.apiClient.fetchUserInfo(forUsername: "DehaanSolo",
                                                                                                compact: false)
                    presentJSONResponse(response, title: "user/info/{username}")
                } catch {
                    presentError(error)
                }
            }
        case 1:
            Task {
                do {
                    let response = try await CDUntappdKitManager.shared.apiClient.fetchUserWishList(forUsername: "DehaanSolo",
                                                                                                    offset: 0,
                                                                                                    limit: 10,
                                                                                                    sort: .highestABV)
                    presentJSONResponse(response, title: "user/wishlist/{username}")
                } catch {
                    presentError(error)
                }
            }
        case 2:
            Task {
                do {
                    let response = try await CDUntappdKitManager.shared.apiClient.fetchUserFriends(forUsername: "DehaanSolo",
                                                                                                   offset: 0,
                                                                                                   limit: 10)
                    presentJSONResponse(response, title: "user/friends/{username}")
                } catch {
                    presentError(error)
                }
            }
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.1
    }
}

private extension ViewController {

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
