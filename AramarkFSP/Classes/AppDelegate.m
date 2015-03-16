/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
#import "InitialViewController.h"
#import "RootViewController.h"
#import "SFAccountManager.h"
#import "SFAuthenticationManager.h"
#import "SFPushNotificationManager.h"
#import "SFOAuthInfo.h"
#import "SFLogger.h"
#import "GAI.h"

#import "AMMainViewController.h"

// Fill these in when creating a new Connected Application on Force.com
//********************For DEMO Env**********************
//static NSString * const RemoteAccessConsumerKey = @"3MVG9zJJ_hX_0bb8bbB0r7e33HXzBRWTamcv9zSc2wW8gMERluM8grJuMTJHA606Ux3AEivEA9zs9hRFcWbhk";


//********************For QA Env**********************
static NSString * const RemoteAccessConsumerKey =  @"3MVG9dPGzpc3kWydfI4DxT5RFMPqIifMnvkFkRBIDwEndjlmhi5UCzcO.thPHx2Tl0jeSdBbZt1HIXpMCAU2p";

static NSString * const OAuthRedirectURI        = @"sfdc://success";

@interface AppDelegate ()

/**
 * Success block to call when authentication completes.
 */
@property (nonatomic, copy) SFOAuthFlowSuccessCallbackBlock initialLoginSuccessBlock;

/**
 * Failure block to calls if authentication fails.
 */
@property (nonatomic, copy) SFOAuthFlowFailureCallbackBlock initialLoginFailureBlock;

@property (nonatomic, strong) NSArray *testAccounts;
@property (nonatomic, weak) UIWebView *loginWebView;
@property (nonatomic, strong) AMMainViewController *mainVC;

/**
 * Handles the notification from SFAuthenticationManager that a logout has been initiated.
 * @param notification The notification containing the details of the logout.
 */
- (void)logoutInitiated:(NSNotification *)notification;

/**
 * Handles the notification from SFAuthenticationManager that the login host has changed in
 * the Settings application for this app.
 * @param The notification whose userInfo dictionary contains:
 *        - kSFLoginHostChangedNotificationOriginalHostKey: The original host, prior to host change.
 *        - kSFLoginHostChangedNotificationUpdatedHostKey: The updated (new) login host.
 */
- (void)loginHostChanged:(NSNotification *)notification;

/**
 * Convenience method for setting up the main UIViewController and setting self.window's rootViewController
 * property accordingly.
 */
- (void)setupRootViewController;

/**
 * (Re-)sets the view state when the app first loads (or post-logout).
 */
- (void)initializeAppViewState;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize initialLoginSuccessBlock = _initialLoginSuccessBlock;
@synthesize initialLoginFailureBlock = _initialLoginFailureBlock;
@synthesize woCount;

- (id)init
{
    self = [super init];
    woCount = 0;
    if (self) {
        [SFLogger setLogLevel:SFLogLevelDebug];
        
        // These SFAccountManager settings are the minimum required to identify the Connected App.
//        [SFAccountManager setClientId:RemoteAccessConsumerKey];
//        [SFAccountManager setRedirectUri:OAuthRedirectURI];
        
        [SFAccountManager setClientId:kSF_CONNECTED_APP_CONSUMER_KEY];
        [SFAccountManager setRedirectUri:kSF_CONNECTED_APP_SUCCESS_CALLBACK];
        [SFAccountManager setScopes:[NSSet setWithObjects:@"api", nil]];
        
        // Logout and login host change handlers.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutInitiated:) name:kSFUserLogoutNotification object:[SFAuthenticationManager sharedManager]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHostChanged:) name:kSFLoginHostChangedNotification object:[SFAuthenticationManager sharedManager]];
        
        [[SFAuthenticationManager sharedManager] setUseSnapshotView:NO];
        
        // Blocks to execute once authentication has completed.  You could define these at the different boundaries where
        // authentication is initiated, if you have specific logic for each case.
        __weak AppDelegate *weakSelf = self;
        self.initialLoginSuccessBlock = ^(SFOAuthInfo *info) {
            BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable]; //Don't remove this, trying to fix issue for sometimes the [[AMLogicCore sharedInstance] isNetWorkReachable] in MainViewController returns NO when firstly install the app.
            isNetworkReachable = isNetworkReachable; //remove warning
            DLog(@"Network is %@", isNetworkReachable ? @"available" : @"not available");
    
            [weakSelf setupRootViewController];
        };
        self.initialLoginFailureBlock = ^(SFOAuthInfo *info, NSError *error) {
            [AMUtilities logout];
        };
        
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:USER_DEFAULT_IN_INITIALIZATION];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFUserLogoutNotification object:[SFAuthenticationManager sharedManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFLoginHostChangedNotification object:[SFAuthenticationManager sharedManager]];
}

#pragma mark - App delegate lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #if TARGET_IPHONE_SIMULATOR
        // where are you?
        NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    #endif
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
//    [self populateRegistrationDomain];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
#if DEBUG
//    [self changeHostToSandbox];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowed) name:UIKeyboardDidShowNotification object:nil];
#endif

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self initializeAppViewState];
    
    //
    // If you wish to register for push notifications, uncomment the line below.  Note that,
    // if you want to receive push notifications from Salesforce, you will also need to
    // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
    //
    //[[SFPushNotificationManager sharedInstance] registerForRemoteNotifications];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
    
    //For Google Analytics
    NSDictionary *allowTracking = @{kAMGOOGLE_AYALYTICS_ALLOWING_TRACKING: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:allowTracking];
    // User must be able to opt out of tracking
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAMGOOGLE_AYALYTICS_ALLOWING_TRACKING];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:kAMGOOGLE_AYALYTICS_TRACKING_ID];
    [GAI sharedInstance].dispatchInterval = 20.0;
    
    return YES;
}

-(void)keyboardShowed
{
    id webBrowserView = [self findFirstResonder:self.window];
    id webScrollView = [webBrowserView superview];
    UIWebView *webView = (UIWebView *)[webScrollView superview];
    
//    NSURLRequest *request = webView.request;
    
    if ([webView isKindOfClass:[UIWebView class]]) {
        self.loginWebView = webView;
        self.testAccounts = @[];
        
        [self addAccountButtons];
        
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    }
}

-(void)addAccountButtons
{
    for (NSDictionary *account in self.testAccounts) {
        NSInteger index = [self.testAccounts indexOfObject:account];
        NSString *userName = account.allKeys.firstObject;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 20+index*50, 280, 40)];
        button.layer.cornerRadius = 5.0;
        button.backgroundColor = [UIColor lightGrayColor];
        [button setTitle:userName forState:UIControlStateNormal];
        [button addTarget:self action:@selector(accountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.loginWebView addSubview:button];
    }
}

-(void)accountButtonPressed:(UIButton *)button
{
    NSString *pressedAcccount = [button titleForState:UIControlStateNormal];
    
    NSString *pwd = @"";
    
    for (NSDictionary *account in self.testAccounts) {
        NSString *accountName = account.allKeys.firstObject;
        if ([accountName isEqualToString:pressedAcccount]) {
            pwd = account[accountName];
        }
    }
    
    NSString *jsString = [NSString stringWithFormat:@"var field = document.getElementById('username');"
                          "field.value='%@';"
                          "var field = document.getElementById('password');"
                          "field.value='%@';", pressedAcccount, pwd];
    
    [self.loginWebView stringByEvaluatingJavaScriptFromString:jsString];
}



- (UIView *)findFirstResonder:(UIView*)root
{
    if ([root isFirstResponder])
    {
        return root;
    }
    
    for (UIView *subView in root.subviews)
    {
        UIView *firstResponder = [self findFirstResonder:subView];
        if (firstResponder != nil)
        {
            return firstResponder;
        }
    }
    return nil;
}

-(void)changeHostToSandbox
{
    [[NSUserDefaults standardUserDefaults] setValue:@"test.salesforce.com" forKey:@"login_host_pref"];
    [[NSUserDefaults standardUserDefaults] setValue:@"test.salesforce.com" forKey:@"primary_login_host_pref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //
    // Uncomment the code below to register your device token with the push notification manager
    //
    //[[SFPushNotificationManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    //if ([SFAccountManager sharedInstance].credentials.accessToken != nil) {
    //    [[SFPushNotificationManager sharedInstance] registerForSalesforceNotifications];
    //}
    //
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // Respond to any push notification registration errors here.
}

#pragma mark - Private methods

- (void)initializeAppViewState
{
    if (self.window.rootViewController) {
        self.window.rootViewController = nil;
        _mainVC = nil;
    }
    self.window.rootViewController = [[InitialViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
}

- (void)setupRootViewController
{
    if (self.window.rootViewController) {
        self.window.rootViewController = nil;
    }
    _mainVC = [[AMMainViewController alloc] initWithNibName:@"AMMainViewController" bundle:nil];

    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:_mainVC];
    
    self.window.rootViewController = navVC;
}

- (void)logoutInitiated:(NSNotification *)notification
{
    [self log:SFLogLevelDebug msg:@"Logout notification received.  Resetting app."];
    [self initializeAppViewState];
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
}

- (void)loginHostChanged:(NSNotification *)notification
{
    [self log:SFLogLevelDebug msg:@"Login host changed notification received.  Resetting app."];
    [self initializeAppViewState];
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
}

- (void)populateRegistrationDomain
{
    NSURL *settingsBundleURL = [[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"bundle"];

    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
    
    [self loadDefaults:appDefaults fromSettingsPage:@"Root.plist" inSettingsBundleAtURL:settingsBundleURL];

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// -------------------------------------------------------------------------------
//	loadDefaults:fromSettingsPage:inSettingsBundleAtURL:
//  Helper function that parses a Settings page file, extracts each preference
//  defined within along with its default value, and adds it to a mutable
//  dictionary.  If the page contains a 'Child Pane Element', this method will
//  recurs on the referenced page file.
// -------------------------------------------------------------------------------
- (void)loadDefaults:(NSMutableDictionary*)appDefaults fromSettingsPage:(NSString*)plistName inSettingsBundleAtURL:(NSURL*)settingsBundleURL
{
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfURL:[settingsBundleURL URLByAppendingPathComponent:plistName]];
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
    for (NSDictionary *prefItem in prefSpecifierArray)
        // Each element is itself a dictionary.
    {
        NSString *prefItemType = prefItem[@"Type"];

        NSString *prefItemKey = prefItem[@"Key"];

        NSString *prefItemDefaultValue = prefItem[@"DefaultValue"];
        
        if ([prefItemType isEqualToString:@"PSChildPaneSpecifier"])
        {
            NSString *prefItemFile = prefItem[@"File"];
            [self loadDefaults:appDefaults fromSettingsPage:prefItemFile inSettingsBundleAtURL:settingsBundleURL];
        }
        else if (prefItemKey != nil && prefItemDefaultValue != nil)
        {
            [appDefaults setObject:prefItemDefaultValue forKey:prefItemKey];
        }
    }
}

@end
