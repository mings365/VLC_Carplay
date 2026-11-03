# VLC CarPlay

[English](#english) · [简体中文](#zh-cn) · [Download / 下载 v1.0.0](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0)

<a id="english"></a>

## English

VLC CarPlay is an unofficial fork of [VLC for iOS](https://code.videolan.org/videolan/vlc-ios/) that brings video playback to CarPlay on **iOS versions before 27** through a legacy window path. It reuses VLC's media library, playback service, and decoder.

### Features

- Select media in VLC CarPlay on iPhone, then watch and hear it on the car screen.
- Play or pause, switch queue items, seek, and choose available subtitle and audio tracks.
- Controls hide during playback and reappear when you tap the video. You can stop video output to the car at any time.
- Playback continues when the iPhone screen is off; the car video view is detached when CarPlay disconnects.

### Install

This legacy CarPlay window path requires **TrollStore** or a **jailbroken installation environment** that preserves the `SBStarkCapable` entitlement. Ordinary Apple ID sideloading cannot enable this car video window. A jailbreak alone does not guarantee compatibility; its signing setup and the connected car must also allow the window.

Download `VLC-CarPlay-v1.0.0-TrollStore.ipa` from [Releases](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0) and install it with TrollStore. Do **not** install the `vlc-ios-unsigned-ipa` build artifact; it is only used by the signing workflow.

### Use and limitations

1. Select and start a video in VLC CarPlay on the iPhone.
2. While **parked**, connect to CarPlay, open VLC CarPlay on the car screen, and tap “已驻车 · 开始显示” (Parked · Start Display).
3. Tap the video to show the controls. Tap “停止显示” (Stop Display) to end car video output.

The parked confirmation is manual; the app does not detect vehicle motion. Do not use video while driving or bypass vehicle or system safety restrictions. Media selection currently happens on the iPhone. The video IPA does not include the CarPlay audio-template entitlement, although VLC's original audio module remains in the source. Compatibility with every iOS version below 27 or every car is not guaranteed.

Starting with **iOS 27**, Apple introduced an [official CarPlay video app category](https://developer.apple.com/videos/play/wwdc2026/212/) for supported vehicles when video is available while parked. It requires AirPlay video streaming and official CarPlay integration, and is separate from this project's legacy window path.

### Build and license

Open `VLC.xcworkspace` in Xcode, or build an arm64 IPA with [build-ios.yml](.github/workflows/build-ios.yml) and sign it with [sign-carplay-video.yml](.github/workflows/sign-carplay-video.yml). See the [installation guide](docs/TROLLSTORE_INSTALL.md).

This is not an official VideoLAN release. See [COPYING](COPYING) for source licenses and attribution to VideoLAN and VLC for iOS contributors.

[Back to top](#vlc-carplay)

<a id="zh-cn"></a>

## 简体中文

VLC CarPlay 是基于 [VLC for iOS](https://code.videolan.org/videolan/vlc-ios/) 开发的非官方分支，主要面向 **iOS 27 以前的系统**，通过旧版窗口路径让 VLC 视频显示在 CarPlay 车机屏幕上。它沿用 VLC 的媒体库、播放服务和解码能力。

### 功能

- 在 iPhone VLC CarPlay 中选择媒体，在车机上播放画面和声音。
- 车机上播放/暂停、切换队列项目、跳转进度，以及选择已有字幕和音轨。
- 播放时自动收起控制栏，轻点画面再次显示；可随时停止车机视频输出。
- iPhone 熄屏后继续播放，CarPlay 断开时解除车机视频视图绑定。

### 安装

此旧版 CarPlay 窗口路径需要 **TrollStore**，或能保留 `SBStarkCapable` 权限的**越狱安装环境**。普通 Apple ID 侧载无法启用该车机视频窗口。仅有越狱并不保证可用，还取决于签名权限及车机是否提供窗口。

从 [Releases](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0) 下载 `VLC-CarPlay-v1.0.0-TrollStore.ipa`，用 TrollStore 安装。`vlc-ios-unsigned-ipa` 只是签名工作流的中间产物，**不要直接安装**。

### 使用与限制

1. 在 iPhone VLC CarPlay 中选择并开始播放视频。
2. 车辆**驻车**时连接 CarPlay，在车机打开 VLC CarPlay，点“已驻车 · 开始显示”。
3. 轻点画面唤出控制栏；不再需要车机画面时点“停止显示”。

“已驻车”是人工确认，应用没有自动车辆运动状态检测。请勿在行驶中使用视频功能，也不要绕过车辆或系统安全限制。媒体目前通过手机选择。视频 IPA 不含 CarPlay 音频模板权限，但源码仍保留 VLC 原有音频模块。不能保证所有低于 iOS 27 的系统和车型都适用。

Apple 从 **iOS 27** 开始提供[官方 CarPlay 视频应用类别](https://developer.apple.com/videos/play/wwdc2026/212/)，仅在支持车载视频且允许驻车播放的车辆上使用，应用还需支持 AirPlay 视频流及官方 CarPlay 集成。本项目使用的是与之不同的旧版窗口路径。

### 构建与许可

用 Xcode 打开 `VLC.xcworkspace`，或通过 [build-ios.yml](.github/workflows/build-ios.yml) 构建 arm64 IPA，再通过 [sign-carplay-video.yml](.github/workflows/sign-carplay-video.yml) 签名。详见[安装说明](docs/TROLLSTORE_INSTALL.md)。

本项目不是 VideoLAN 官方发布。源码许可与致谢见 [COPYING](COPYING)。

[返回顶部](#vlc-carplay)
