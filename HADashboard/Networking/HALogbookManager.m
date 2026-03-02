#import "HALogbookManager.h"
#import "HAAuthManager.h"
#import "NSMutableURLRequest+HAHelpers.h"

@implementation HALogbookManager

+ (instancetype)sharedManager {
    static HALogbookManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HALogbookManager alloc] init];
    });
    return instance;
}

- (void)fetchRecentEntries:(NSInteger)hours
                completion:(void (^)(NSArray *, NSError *))completion {
    [self fetchEntriesForEntityId:nil hoursBack:hours completion:completion];
}

- (void)fetchEntriesForEntityId:(NSString *)entityId
                      hoursBack:(NSInteger)hours
                     completion:(void (^)(NSArray *, NSError *))completion {
    if (!completion) return;

    NSString *serverURL = [[HAAuthManager sharedManager] serverURL];
    NSString *token = [[HAAuthManager sharedManager] accessToken];
    if (!serverURL || !token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, [NSError errorWithDomain:@"HALogbookManager" code:-1
                                           userInfo:@{NSLocalizedDescriptionKey: @"Not configured"}]);
        });
        return;
    }

    // Build timestamp for start time
    static NSDateFormatter *fmt;
    static dispatch_once_t fmtOnce;
    dispatch_once(&fmtOnce, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        fmt.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });

    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-hours * 3600];
    NSString *startStr = [fmt stringFromDate:startDate];

    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/api/logbook/%@", serverURL, startStr];
    if (entityId.length > 0) {
        [urlStr appendFormat:@"?entity=%@", entityId];
    }

    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, [NSError errorWithDomain:@"HALogbookManager" code:-2
                                           userInfo:@{NSLocalizedDescriptionKey: @"Invalid URL"}]);
        });
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request ha_setAuthHeaders:token];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error || !data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
                return;
            }

            NSArray *entries = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (![entries isKindOfClass:[NSArray class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(@[], nil);
                });
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(entries, nil);
            });
        }];
    [task resume];
}

@end
