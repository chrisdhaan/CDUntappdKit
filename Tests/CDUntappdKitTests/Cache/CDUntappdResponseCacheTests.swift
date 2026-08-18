import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdResponseCache Tests")
struct CDUntappdResponseCacheTests {

    @Test
    func returnsStoredDataForKey() {
        let cache = CDUntappdResponseCache(configuration: CDUntappdCacheConfiguration(ttl: 300))
        let data = Data("hello".utf8)
        cache.set(data: data, forKey: "key")
        #expect(cache.data(forKey: "key") == data)
    }

    @Test
    func returnsNilForMissingKey() {
        let cache = CDUntappdResponseCache(configuration: CDUntappdCacheConfiguration(ttl: 300))
        #expect(cache.data(forKey: "missing") == nil)
    }

    @Test
    func returnsNilForAnExpiredEntry() async throws {
        let cache = CDUntappdResponseCache(configuration: CDUntappdCacheConfiguration(ttl: 0.01))
        cache.set(data: Data("hello".utf8), forKey: "key")
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(cache.data(forKey: "key") == nil)
    }

    @Test
    func doesNotStoreWhenTTLIsZero() {
        let cache = CDUntappdResponseCache(configuration: .disabled)
        cache.set(data: Data("hello".utf8), forKey: "key")
        #expect(cache.data(forKey: "key") == nil)
    }

    @Test
    func removeEvictsASpecificKey() {
        let cache = CDUntappdResponseCache(configuration: CDUntappdCacheConfiguration(ttl: 300))
        cache.set(data: Data("hello".utf8), forKey: "key")
        cache.remove(forKey: "key")
        #expect(cache.data(forKey: "key") == nil)
    }

    @Test
    func removeAllEvictsEveryKey() {
        let cache = CDUntappdResponseCache(configuration: CDUntappdCacheConfiguration(ttl: 300))
        cache.set(data: Data("a".utf8), forKey: "key-a")
        cache.set(data: Data("b".utf8), forKey: "key-b")
        cache.removeAll()
        #expect(cache.data(forKey: "key-a") == nil)
        #expect(cache.data(forKey: "key-b") == nil)
    }
}
