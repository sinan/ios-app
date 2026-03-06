#import <XCTest/XCTest.h>
#import "HAOAuthClient.h"

/// Regression tests for HAOAuthClient lifetime management.
///
/// HAOAuthClient is always created as a local variable at call sites.
/// The in-flight NSURLSessionDataTask must keep the client alive through
/// the completion block's strong self capture.  If someone adds weak self
/// with early-return-on-nil, these tests will time out because the client
/// deallocates before the response (or connection error) arrives.
@interface HAOAuthClientTests : XCTestCase
@end

@implementation HAOAuthClientTests

/// Core regression test: completion must fire even with no external strong reference.
/// Uses a bogus URL that will immediately fail with a connection error — the point
/// is that the completion fires AT ALL, not that it succeeds.
- (void)testFetchAuthProvidersFiresCompletionWhenClientIsLocal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion fires"];

    // Client is a LOCAL variable — no ivar keeps it alive.
    HAOAuthClient *oauth = [[HAOAuthClient alloc] initWithServerURL:@"http://127.0.0.1:1"];
    [oauth fetchAuthProviders:^(NSArray *providers, NSError *error) {
        // Connection will fail (port 1) — that's fine.
        // The key assertion: this block executes, proving the client survived.
        [expectation fulfill];
    }];
    // oauth goes out of scope — only the task's block retains it.

    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

/// Same test for the login flow (exercises different code path).
- (void)testLoginFlowFiresCompletionWhenClientIsLocal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"login completion fires"];

    HAOAuthClient *oauth = [[HAOAuthClient alloc] initWithServerURL:@"http://127.0.0.1:1"];
    [oauth loginWithUsername:@"test" password:@"test" completion:^(NSString *authCode, NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

/// Same test for token exchange.
- (void)testTokenExchangeFiresCompletionWhenClientIsLocal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"exchange completion fires"];

    HAOAuthClient *oauth = [[HAOAuthClient alloc] initWithServerURL:@"http://127.0.0.1:1"];
    [oauth exchangeAuthCode:@"test-code" completion:^(NSDictionary *tokenResponse, NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

/// Same test for token refresh.
- (void)testRefreshTokenFiresCompletionWhenClientIsLocal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"refresh completion fires"];

    HAOAuthClient *oauth = [[HAOAuthClient alloc] initWithServerURL:@"http://127.0.0.1:1"];
    [oauth refreshWithToken:@"test-refresh" completion:^(NSDictionary *tokenResponse, NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

/// Same test for trusted network login.
- (void)testTrustedNetworkLoginFiresCompletionWhenClientIsLocal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"trusted network completion fires"];

    HAOAuthClient *oauth = [[HAOAuthClient alloc] initWithServerURL:@"http://127.0.0.1:1"];
    [oauth loginWithTrustedNetworkUser:nil flowId:nil completion:^(NSString *authCode, NSDictionary *users, NSString *flowId, NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

@end
