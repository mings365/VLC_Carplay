/*****************************************************************************
 * VLCCarPlayVideoSceneDelegate.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2026 VLC CarPlay contributors
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import <UIKit/UIKit.h>
#import <os/log.h>

#import "VLCCarPlayProbeDiagnostics.h"

@interface VLCCarPlayVideoSceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (nonatomic, strong) UIWindow *window;

@end

@implementation VLCCarPlayVideoSceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
     options:(UISceneConnectionOptions *)connectionOptions
{
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video willConnect role=%@", session.role]);
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        os_log_error(OS_LOG_DEFAULT, "VLC CarPlay video probe: scene is not a UIWindowScene");
        VLCCarPlayProbeRecord(@"video scene type invalid");
        return;
    }

    UIWindowScene *windowScene = (UIWindowScene *)scene;
    CGRect bounds = windowScene.coordinateSpace.bounds;
    os_log_info(OS_LOG_DEFAULT, "VLC CarPlay video probe: scene connected, window bounds %{public}.0fx%{public}.0f", CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video window scene connected %.0fx%.0f", CGRectGetWidth(bounds), CGRectGetHeight(bounds)]);

    UIViewController *controller = [UIViewController new];
    controller.view.backgroundColor = [UIColor colorWithRed:0.07 green:0.21 blue:0.55 alpha:1.0];

    UILabel *message = [UILabel new];
    message.text = @"VLC CARPLAY PROBE\nWINDOW CONNECTED";
    message.textColor = [UIColor whiteColor];
    message.textAlignment = NSTextAlignmentCenter;
    message.numberOfLines = 0;
    message.font = [UIFont boldSystemFontOfSize:30.0];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view addSubview:message];
    [NSLayoutConstraint activateConstraints:@[
        [message.centerXAnchor constraintEqualToAnchor:controller.view.centerXAnchor],
        [message.centerYAnchor constraintEqualToAnchor:controller.view.centerYAnchor],
        [message.leadingAnchor constraintGreaterThanOrEqualToAnchor:controller.view.leadingAnchor constant:24.0],
        [message.trailingAnchor constraintLessThanOrEqualToAnchor:controller.view.trailingAnchor constant:-24.0]
    ]];

    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    os_log_info(OS_LOG_DEFAULT, "VLC CarPlay video probe: test view attached");
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video test view attached hidden=%d", self.window.hidden]);
}

- (void)sceneDidBecomeActive:(UIScene *)scene
{
    [self.window makeKeyAndVisible];
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video scene active window=%d hidden=%d size=%.0fx%.0f root=%d", self.window != nil, self.window.hidden, CGRectGetWidth(self.window.bounds), CGRectGetHeight(self.window.bounds), self.window.rootViewController != nil]);
}

- (void)sceneWillResignActive:(UIScene *)scene
{
    VLCCarPlayProbeRecord(@"video scene resign active");
}

- (void)sceneDidDisconnect:(UIScene *)scene
{
    os_log_info(OS_LOG_DEFAULT, "VLC CarPlay video probe: scene disconnected");
    VLCCarPlayProbeRecord(@"video scene disconnected");
    self.window.hidden = YES;
    self.window.rootViewController = nil;
    self.window = nil;
}

@end
