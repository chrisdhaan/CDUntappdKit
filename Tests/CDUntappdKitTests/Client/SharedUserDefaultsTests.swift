import Testing

/// Namespace grouping test suites that share global `UserDefaults.standard` state
/// (the `CDUntappdDefaults.accessToken` key), so Swift Testing serializes them
/// against each other — not just internally — preventing the cross-suite races that
/// a plain per-suite `.serialized` trait doesn't protect against (same class of bug
/// already fixed in `CDUntappdMockURLProtocol`, Task 6's fix round).
@Suite(.serialized)
enum SharedUserDefaultsTests {}
