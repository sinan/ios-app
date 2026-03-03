#import <Foundation/Foundation.h>

/// Caches Lovelace dashboard configuration JSON with hash-based invalidation.
/// Per-dashboard storage: each dashboard path gets its own cache file.
@interface HADashboardConfigCache : NSObject

+ (instancetype)sharedCache;

/// Load cached dashboard config for the given dashboard path.
/// Pass nil for the default dashboard.
/// Returns the raw Lovelace config dict, or nil if no cache exists.
- (NSDictionary *)loadCachedConfigForDashboard:(NSString *)dashboardPath;

/// Cache a dashboard config. Computes a SHA256 hash of the JSON data.
/// Returns YES if the config changed (hash differs from cached version).
/// Returns NO if the config is identical to the cached version (skip re-render).
- (BOOL)cacheConfig:(NSDictionary *)config forDashboard:(NSString *)dashboardPath;

/// Whether there is a cached config file for the given dashboard path.
- (BOOL)hasCachedConfigForDashboard:(NSString *)dashboardPath;

/// Delete cached config for a specific dashboard.
- (void)clearCacheForDashboard:(NSString *)dashboardPath;

@end
