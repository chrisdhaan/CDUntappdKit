import Testing

/// Namespace grouping test suites that share global `UserDefaults.standard` state
/// (the `CDUntappdDefaults.accessToken` key), so Swift Testing serializes them
/// against each other — not just internally — preventing the cross-suite races that
/// a plain per-suite `.serialized` trait doesn't protect against (the same class of
/// shared-mutable-state race `CDUntappdMockURLProtocol` avoids by not using a
/// `static var` at all).
@Suite(.serialized)
enum SharedUserDefaultsTests {}
