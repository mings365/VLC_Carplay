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

@interface VLCCarPlayVideoSceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (nonatomic, strong) UIWindow *window;

@end

@implementation VLCCarPlayVideoSceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
     options:(UISceneConnectionOptions *)connectionOptions
{
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        os_log_error(OS_LOG_DEFAULT, "VLC CarPlay video probe: scene is not a UIWindowScene");
        return;
    }

    UIWindowScene *windowScene = (UIWindowScene *)scene;
    CGRect bounds = windowScene.coordinateSpace.bounds;
    os_log_info(OS_LOG_DEFAULT, "VLC CarPlay video probe: scene connected, window bounds %{public}.0fx%{public}.0f", CGRectGetWidth(bounds), CGRectGetHeight(bounds));

    UIViewController *controller = [UIViewController new];
    controller.view.backgroundColor = [UIColor blackColor];

    UILabel *message = [UILabel new];
    message.text = @"VLC CarPlay display probe\nVideo capability not verified";
    message.textColor = [UIColor whiteColor];
    message.textAlignment = NSTextAlignmentCenter;
    message.numberOfLines = 0;
    message.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
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
}

- (void)sceneDidDisconnect:(UIScene *)scene
{
    os_log_info(OS_LOG_DEFAULT, "VLC CarPlay video probe: scene disconnected");
    self.window.hidden = YES;
    self.window.rootViewController = nil;
    self.window = nil;
}

@end
