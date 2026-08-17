import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdRetryConfiguration Tests")
struct CDUntappdRetryConfigurationTests {

    @Test
    func defaultInitUsesDocumentedDefaults() {
        let configuration = CDUntappdRetryConfiguration()
        #expect(configuration.retryLimit == 3)
        #expect(configuration.initialDelay == 0.5)
        #expect(configuration.retryableHTTPStatusCodes == [408, 429, 500, 502, 503, 504])
        #expect(configuration.retryableURLErrorCodes == [.networkConnectionLost, .notConnectedToInternet, .timedOut])
    }

    @Test
    func disabledHasZeroRetryLimit() {
        #expect(CDUntappdRetryConfiguration.disabled.retryLimit == 0)
    }
}
