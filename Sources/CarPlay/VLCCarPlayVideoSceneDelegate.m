/*****************************************************************************
 * VLCCarPlayVideoSceneDelegate.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2026 VLC CarPlay contributors
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import <UIKit/UIKit.h>
#import "VLCPlaybackService.h"
#import "VLCCarPlayProbeDiagnostics.h"

@interface VLCCarPlayVideoSceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *videoSurface;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *enableButton;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *subtitleButton;
@property (nonatomic, strong) UIButton *audioButton;
@property (nonatomic, strong) UIStackView *controls;
@property (nonatomic, strong) UIStackView *progressRow;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *elapsedLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, assign) BOOL displayEnabled;
@property (nonatomic, assign) BOOL seeking;

- (void)updatePlaybackState;
- (void)updateTrackButtonsWithPlayback:(VLCPlaybackService *)playback;
- (void)updateProgress;

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
    UITapGestureRecognizer *toggleControlsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls:)];
    [self.videoSurface addGestureRecognizer:toggleControlsTap];
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
    self.subtitleButton = [self controlButtonWithTitle:@"字幕" action:@selector(nextSubtitle:)];
    self.audioButton = [self controlButtonWithTitle:@"音轨" action:@selector(nextAudioTrack:)];
    UIButton *stopButton = [self controlButtonWithTitle:@"停止显示" action:@selector(stopVideoOutput:)];
    self.controls = [[UIStackView alloc] initWithArrangedSubviews:@[previousButton, self.playPauseButton, nextButton, self.subtitleButton, self.audioButton, stopButton]];
    self.controls.axis = UILayoutConstraintAxisHorizontal;
    self.controls.distribution = UIStackViewDistributionFillEqually;
    self.controls.spacing = 6.0;
    self.controls.translatesAutoresizingMaskIntoConstraints = NO;
    self.controls.hidden = YES;
    [controller.view addSubview:self.controls];

    self.elapsedLabel = [self timeLabel];
    self.durationLabel = [self timeLabel];
    self.elapsedLabel.text = @"00:00";
    self.durationLabel.text = @"00:00";
    self.progressSlider = [UISlider new];
    self.progressSlider.minimumValue = 0.0f;
    self.progressSlider.maximumValue = 1.0f;
    self.progressSlider.minimumTrackTintColor = UIColor.whiteColor;
    self.progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressSlider addTarget:self action:@selector(beginSeeking:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(previewSeek:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(commitSeek:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    self.progressRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.elapsedLabel, self.progressSlider, self.durationLabel]];
    self.progressRow.axis = UILayoutConstraintAxisHorizontal;
    self.progressRow.spacing = 10.0;
    self.progressRow.alignment = UIStackViewAlignmentCenter;
    self.progressRow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
    self.progressRow.layer.cornerRadius = 8.0;
    self.progressRow.layoutMargins = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
    self.progressRow.layoutMarginsRelativeArrangement = YES;
    self.progressRow.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressRow.hidden = YES;
    [controller.view addSubview:self.progressRow];

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
        [self.controls.leadingAnchor constraintEqualToAnchor:controller.view.leadingAnchor constant:12.0],
        [self.controls.trailingAnchor constraintEqualToAnchor:controller.view.trailingAnchor constant:-12.0],
        [self.controls.bottomAnchor constraintEqualToAnchor:controller.view.safeAreaLayoutGuide.bottomAnchor constant:-8.0],
        [self.controls.heightAnchor constraintEqualToConstant:48.0],
        [self.progressRow.leadingAnchor constraintEqualToAnchor:self.controls.leadingAnchor],
        [self.progressRow.trailingAnchor constraintEqualToAnchor:self.controls.trailingAnchor],
        [self.progressRow.bottomAnchor constraintEqualToAnchor:self.controls.topAnchor constant:-8.0],
        [self.progressRow.heightAnchor constraintEqualToConstant:34.0],
        [self.elapsedLabel.widthAnchor constraintEqualToConstant:54.0],
        [self.durationLabel.widthAnchor constraintEqualToConstant:54.0]
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
    [notifications addObserver:self selector:@selector(playbackPositionChanged:) name:VLCPlaybackServicePlaybackPositionUpdated object:nil];
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video player view ready hidden=%d", self.window.hidden]);
}

- (UIButton *)controlButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    button.backgroundColor = [UIColor colorWithWhite:0.18 alpha:0.8];
    button.layer.cornerRadius = 8.0;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)timeLabel
{
    UILabel *label = [UILabel new];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont monospacedDigitSystemFontOfSize:14.0 weight:UIFontWeightMedium];
    return label;
}

- (void)enableVideoOutput:(UIButton *)sender
{
    self.displayEnabled = YES;
    self.enableButton.hidden = YES;
    self.controls.hidden = NO;
    self.progressRow.hidden = NO;
    [VLCPlaybackService sharedInstance].carPlayVideoOutputView = self.videoSurface;
    VLCCarPlayProbeRecord(@"video output attach requested");
    [self updatePlaybackState];
}

- (void)stopVideoOutput:(UIButton *)sender
{
    [VLCPlaybackService sharedInstance].carPlayVideoOutputView = nil;
    self.displayEnabled = NO;
    self.enableButton.hidden = NO;
    self.controls.hidden = YES;
    self.progressRow.hidden = YES;
    self.statusLabel.hidden = NO;
    self.statusLabel.text = @"仅在驻车时使用。请先在手机 VLC 中选择视频。";
    VLCCarPlayProbeRecord(@"video output detach requested by user");
}

- (void)toggleControls:(UITapGestureRecognizer *)recognizer
{
    if (!self.displayEnabled) {
        return;
    }
    self.controls.hidden = !self.controls.hidden;
    self.progressRow.hidden = self.controls.hidden;
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatePlaybackState];
    });
}

- (void)playbackPositionChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateProgress];
        if (self.displayEnabled) {
            [self updateTrackButtonsWithPlayback:[VLCPlaybackService sharedInstance]];
        }
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
    [self updateTrackButtonsWithPlayback:playback];
    [self updateProgress];
    VLCCarPlayProbeRecord([NSString stringWithFormat:@"video playback state playing=%d media=%d output=%d", playback.isPlaying, playback.currentlyPlayingMedia != nil, playback.carPlayVideoOutputView != nil]);
}

- (void)updateTrackButtonsWithPlayback:(VLCPlaybackService *)playback
{
    NSInteger subtitleCount = playback.textTracks.count;
    NSInteger subtitleIndex = playback.indexOfCurrentPrimaryVideoSubtitleTrack;
    self.subtitleButton.enabled = subtitleCount > 0;
    [self.subtitleButton setTitle:subtitleCount == 0 ? @"无字幕" : (subtitleIndex < 0 ? @"字幕关" : [NSString stringWithFormat:@"字幕 %ld/%ld", (long)(subtitleIndex + 1), (long)subtitleCount]) forState:UIControlStateNormal];
    NSInteger audioCount = playback.audioTracks.count;
    NSInteger audioIndex = playback.indexOfCurrentAudioTrack;
    self.audioButton.enabled = audioCount > 1;
    [self.audioButton setTitle:audioCount == 0 ? @"无音轨" : (audioIndex < 0 ? @"音轨" : [NSString stringWithFormat:@"音轨 %ld/%ld", (long)(audioIndex + 1), (long)audioCount]) forState:UIControlStateNormal];
}

- (NSString *)timeStringForMilliseconds:(NSInteger)milliseconds
{
    NSInteger seconds = MAX(0, milliseconds / 1000);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(seconds / 60), (long)(seconds % 60)];
}

- (void)updateProgress
{
    if (!self.displayEnabled || self.seeking) {
        return;
    }
    VLCPlaybackService *playback = [VLCPlaybackService sharedInstance];
    NSInteger duration = playback.mediaDuration;
    self.progressSlider.enabled = duration > 0 && playback.isSeekable;
    self.progressSlider.value = playback.playbackPosition;
    self.elapsedLabel.text = [self timeStringForMilliseconds:playback.playbackTime.integerValue];
    self.durationLabel.text = [self timeStringForMilliseconds:duration];
}

- (void)beginSeeking:(UISlider *)slider
{
    self.seeking = YES;
}

- (void)previewSeek:(UISlider *)slider
{
    NSInteger duration = [VLCPlaybackService sharedInstance].mediaDuration;
    self.elapsedLabel.text = [self timeStringForMilliseconds:(NSInteger)(duration * slider.value)];
}

- (void)commitSeek:(UISlider *)slider
{
    self.seeking = NO;
    VLCPlaybackService *playback = [VLCPlaybackService sharedInstance];
    if (playback.isSeekable) {
        playback.playbackPosition = slider.value;
        VLCCarPlayProbeRecord(@"video seek requested");
    }
    [self updateProgress];
}

- (void)nextSubtitle:(UIButton *)sender
{
    VLCPlaybackService *playback = [VLCPlaybackService sharedInstance];
    NSInteger count = playback.textTracks.count;
    if (count == 0) {
        return;
    }
    NSInteger nextIndex = playback.indexOfCurrentPrimaryVideoSubtitleTrack + 1;
    if (nextIndex >= count) {
        [playback disablePrimaryVideoSubtitle];
    } else {
        [playback selectPrimaryVideoSubtitleAtIndex:nextIndex];
    }
    VLCCarPlayProbeRecord(@"video subtitle selection changed");
    [self updatePlaybackState];
}

- (void)nextAudioTrack:(UIButton *)sender
{
    VLCPlaybackService *playback = [VLCPlaybackService sharedInstance];
    NSInteger count = playback.audioTracks.count;
    if (count < 2) {
        return;
    }
    NSInteger nextIndex = (playback.indexOfCurrentAudioTrack + 1) % count;
    [playback selectAudioTrackAtIndex:nextIndex];
    VLCCarPlayProbeRecord(@"video audio track selection changed");
    [self updatePlaybackState];
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
        [self stopVideoOutput:nil];
        VLCCarPlayProbeRecord(@"video output detached on resign active");
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
    self.subtitleButton = nil;
    self.audioButton = nil;
    self.controls = nil;
    self.progressRow = nil;
    self.progressSlider = nil;
    self.elapsedLabel = nil;
    self.durationLabel = nil;
    self.displayEnabled = NO;
    VLCCarPlayProbeRecord(@"video scene disconnected");
}

@end
