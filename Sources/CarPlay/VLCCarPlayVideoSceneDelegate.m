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

#import "VLCPlaybackService.h"
#import "VLCCarPlayProbeDiagnostics.h"

@interface VLCCarPlayVideoSceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *videoSurface;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *enableButton;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, assign) BOOL displayEnabled;

@end

@implementation VLCCarPlayVideoSceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
     options:(UISceneConnectionOptions *)connectionOptions
{
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video willConnect role=%@", session.role]);
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        VLCCarPlayProbeRecord(@"video scene type invalid");
        return;
    }

    UIWindowScene *windowScene = (UIWindowScene *)scene;
    CGRect bounds = windowScene.coordinateSpace.bounds;
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video window scene connected %.0fx%.0f", CGRectGetWidth(bounds), CGRectGetHeight(bounds)]);

    UIViewController *controller = [UIViewController new];
    controller.view.backgroundColor = UIColor.blackColor;

    self.videoSurface = [UIView new];
    self.videoSurface.backgroundColor = UIColor.blackColor;
    self.videoSurface.clipsToBounds = YES;
    self.videoSurface.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view addSubview:self.videoSurface];

    self.statusLabel = [UILabel new];
    self.statusLabel.text = @"仅在驻车时使用。请先在手机 VLC 中选择视频。";
    self.statusLabel.textColor = UIColor.whiteColor;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view addSubview:self.statusLabel];

    self.enableButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.enableButton setTitle:@"已驻车 · 开始显示" forState:UIControlStateNormal];
    [self.enableButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.enableButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    self.enableButton.backgroundColor = [UIColor colorWithRed:0.07 green:0.31 blue:0.68 alpha:1.0];
    self.enableButton.layer.cornerRadius = 12.0;
    self.enableButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.enableButton addTarget:self action:@selector(enableVideoOutput:) forControlEvents:UIControlEventTouchUpInside];
    [controller.view addSubview:self.enableButton];

    UIButton *previousButton = [self controlButtonWithTitle:@"上一项" action:@selector(previousMedia:)];
    self.playPauseButton = [self controlButtonWithTitle:@"播放/暂停" action:@selector(togglePlayback:)];
    UIButton *nextButton = [self controlButtonWithTitle:@"下一项" action:@selector(nextMedia:)];
    UIStackView *controls = [[UIStackView alloc] initWithArrangedSubviews:@[previousButton, self.playPauseButton, nextButton]];
    controls.axis = UILayoutConstraintAxisHorizontal;
    controls.distribution = UIStackViewDistributionFillEqually;
    controls.spacing = 8.0;
    controls.translatesAutoresizingMaskIntoConstraints = NO;
    controls.hidden = YES;
    controls.tag = 7001;
    [controller.view addSubview:controls];

    [NSLayoutConstraint activateConstraints:@[
        [self.videoSurface.topAnchor constraintEqualToAnchor:controller.view.topAnchor],
        [self.videoSurface.bottomAnchor constraintEqualToAnchor:controller.view.bottomAnchor],
        [self.videoSurface.leadingAnchor constraintEqualToAnchor:controller.view.leadingAnchor],
        [self.videoSurface.trailingAnchor constraintEqualToAnchor:controller.view.trailingAnchor],
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:controller.view.centerXAnchor],
        [self.statusLabel.centerYAnchor constraintEqualToAnchor:controller.view.centerYAnchor constant:-28.0],
        [self.statusLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:controller.view.leadingAnchor constant:20.0],
        [self.statusLabel.trailingAnchor constraintLessThanOrEqualToAnchor:controller.view.trailingAnchor constant:-20.0],
        [self.enableButton.centerXAnchor constraintEqualToAnchor:controller.view.centerXAnchor],
        [self.enableButton.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:12.0],
        [self.enableButton.widthAnchor constraintGreaterThanOrEqualToConstant:220.0],
        [self.enableButton.heightAnchor constraintEqualToConstant:52.0],
        [controls.leadingAnchor constraintEqualToAnchor:controller.view.leadingAnchor constant:16.0],
        [controls.trailingAnchor constraintEqualToAnchor:controller.view.trailingAnchor constant:-16.0],
        [controls.bottomAnchor constraintEqualToAnchor:controller.view.safeAreaLayoutGuide.bottomAnchor constant:-8.0],
        [controls.heightAnchor constraintEqualToConstant:48.0]
    ]];

    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];

    NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
    for (NSString *name in @[VLCPlaybackServicePlaybackDidStart,
                             VLCPlaybackServicePlaybackDidResume,
                             VLCPlaybackServicePlaybackDidPause,
                             VLCPlaybackServicePlaybackDidStop,
                             VLCPlaybackServicePlaybackDidFail]) {
        [notifications addObserver:self selector:@selector(playbackStateChanged:) name:name object:nil];
    }
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video player view ready hidden=%d", self.window.hidden]);
}

- (UIButton *)controlButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    button.backgroundColor = [UIColor colorWithWhite:0.18 alpha:0.8];
    button.layer.cornerRadius = 8.0;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)enableVideoOutput:(UIButton *)sender
{
    self.displayEnabled = YES;
    self.enableButton.hidden = YES;
    [self.window.rootViewController.view viewWithTag:7001].hidden = NO;
    [VLCPlaybackService sharedInstance].carPlayVideoOutputView = self.videoSurface;
    VLCCarPlayProbeRecord(@"video output attach requested");
    [self updatePlaybackState];
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatePlaybackState];
    });
}

- (void)updatePlaybackState
{
    VLCPlaybackService *playback = [VLCPlaybackService sharedInstance];
    if (!self.displayEnabled) {
        return;
    }
    self.statusLabel.hidden = playback.isPlaying;
    self.statusLabel.text = playback.currentlyPlayingMedia ? @"视频已暂停" : @"请在手机 VLC 中选择视频";
    [self.playPauseButton setTitle:playback.isPlaying ? @"暂停" : @"播放" forState:UIControlStateNormal];
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video playback state playing=%d media=%d output=%d", playback.isPlaying, playback.currentlyPlayingMedia != nil, playback.carPlayVideoOutputView != nil]);
}

- (void)togglePlayback:(UIButton *)sender
{
    [[VLCPlaybackService sharedInstance] playPause];
    [self updatePlaybackState];
}

- (void)previousMedia:(UIButton *)sender
{
    [[VLCPlaybackService sharedInstance] previous];
}

- (void)nextMedia:(UIButton *)sender
{
    [[VLCPlaybackService sharedInstance] next];
}

- (void)sceneDidBecomeActive:(UIScene *)scene
{
    [self.window makeKeyAndVisible];
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video scene active window=%d hidden=%d size=%.0fx%.0f", self.window != nil, self.window.hidden, CGRectGetWidth(self.window.bounds), CGRectGetHeight(self.window.bounds)]);
}

- (void)sceneWillResignActive:(UIScene *)scene
{
    VLCCarPlayProbeRecord(@"video scene resign active");
    if (self.displayEnabled) {
        [VLCPlaybackService sharedInstance].carPlayVideoOutputView = nil;
        self.displayEnabled = NO;
        self.enableButton.hidden = NO;
        [self.window.rootViewController.view viewWithTag:7001].hidden = YES;
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"仅在驻车时使用。请先在手机 VLC 中选择视频。";
        VLCCarPlayProbeRecord(@"video output detach requested on resign active");
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene
{
    [VLCPlaybackService sharedInstance].carPlayVideoOutputView = nil;
    VLCCarPlayProbeRecord(@"video output detach requested on disconnect");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.window.hidden = YES;
    self.window.rootViewController = nil;
    self.window = nil;
    self.videoSurface = nil;
    self.statusLabel = nil;
    self.enableButton = nil;
    self.playPauseButton = nil;
    self.displayEnabled = NO;
    VLCCarPlayProbeRecord(@"video scene disconnected");
}

@end
