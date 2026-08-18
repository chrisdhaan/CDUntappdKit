import Testing
@testable import CDUntappdKit

@Suite("CDUntappdCacheConfiguration Tests")
struct CDUntappdCacheConfigurationTests {

    @Test
    func defaultConfigurationUsesFiveMinuteTTL() {
        let configuration = CDUntappdCacheConfiguration()
        #expect(configuration.ttl == 300)
        #expect(configuration.countLimit == 100)
        #expect(configuration.totalCostLimit == 0)
    }

    @Test
    func disabledConfigurationHasZeroTTL() {
        #expect(CDUntappdCacheConfiguration.disabled.ttl == 0)
    }
}
