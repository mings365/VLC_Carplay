# VLC CarPlay

[简体中文](README.md) · [Download v1.0.0](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0)

VLC CarPlay is an unofficial fork of [VLC for iOS](https://code.videolan.org/videolan/vlc-ios/) that displays videos from the iPhone app on a CarPlay screen. It reuses VLC's media library, playback service, and decoder.

## Features

- Select a video or media source in VLC CarPlay on iPhone, then view the video and hear its audio through the car display.
- Play or pause, move between queue items, seek, and switch available subtitle and audio tracks on the car screen.
- Controls hide during playback and reappear when you tap the video. You can also stop video output to the car.
- Playback continues when the iPhone screen is off. The car video view is detached when its CarPlay scene disconnects.

## Installation requirements

This version uses a legacy iOS CarPlay window path. It requires **TrollStore**, or a **jailbroken installation environment** that preserves the `SBStarkCapable` entitlement. Ordinary Apple ID sideloading does not enable this car video window. Jailbroken devices require their own signing and entitlement setup.

Download `VLC-CarPlay-v1.0.0-TrollStore.ipa` from [Releases](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0) and install it with TrollStore. Do **not** install the `vlc-ios-unsigned-ipa` build artifact; it is an intermediate package for the signing workflow.

## Use and limitations

1. Select and start a video in VLC CarPlay on the iPhone.
2. While the vehicle is **parked**, connect to CarPlay, open VLC CarPlay on the car screen, and tap “已驻车 · 开始显示” (Parked · Start Display).
3. Tap the video to show the controls. Tap “停止显示” (Stop Display) when you no longer need video on the car screen.

The parked confirmation is manual; the app has no automatic vehicle-motion detection. Do not use video while driving or bypass vehicle or system safety restrictions. Media selection currently happens on the iPhone; the car screen has no full file browser. The video IPA does not include the CarPlay audio-template entitlement, although the original VLC audio module remains in the source. This legacy window approach is separate from Apple's newer official CarPlay video category.

## Build and license

Open `VLC.xcworkspace` in Xcode, or build an arm64 IPA with [build-ios.yml](.github/workflows/build-ios.yml) and sign it with [sign-carplay-video.yml](.github/workflows/sign-carplay-video.yml). See the [installation guide](docs/TROLLSTORE_INSTALL.md).

This is not an official VideoLAN release. See [COPYING](COPYING) for the source licenses and attribution to VideoLAN and VLC for iOS contributors.
