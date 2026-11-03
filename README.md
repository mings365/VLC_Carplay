# VLC CarPlay

[English](README.en.md) · [下载 v1.0.0](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0)

基于 [VLC for iOS](https://code.videolan.org/videolan/vlc-ios/) 开发的非官方分支，让 iPhone 中的 VLC 视频在 CarPlay 车机屏幕上播放。沿用 VLC 的媒体库、播放服务和解码能力，不另建播放器。

## 功能

- 在 iPhone VLC CarPlay 中选择本地视频或媒体来源，在车机上显示画面并输出声音。
- 车机上播放/暂停、切换上一项和下一项、查看及跳转进度、切换已有字幕和音轨。
- 播放时自动收起控制栏，轻点画面可再次显示；也可主动停止车机显示。
- iPhone 熄屏后继续播放，CarPlay 窗口断开时释放车机视频视图。

## 安装条件

此版本使用 iOS 旧版 CarPlay 窗口路径，需要 **TrollStore**，或能保留 `SBStarkCapable` 权限的**越狱安装环境**。普通 Apple ID 侧载无法按此方式启用车机视频窗口。越狱环境的签名和权限配置需由使用者自行处理。

从 [Releases](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0) 下载 `VLC-CarPlay-v1.0.0-TrollStore.ipa`，用 TrollStore 安装。`build-ios.yml` 中的 `vlc-ios-unsigned-ipa` 是构建中间产物，**不要直接安装**。

## 使用与限制

1. 在 iPhone 的 VLC CarPlay 中选择并播放视频。
2. 车辆**驻车**时连接 CarPlay，在车机打开 VLC CarPlay，点“已驻车 · 开始显示”。
3. 轻点视频画面唤出控制栏；不再需要车机画面时点“停止显示”。

“已驻车”是人工确认，应用不提供自动车辆运动状态检测；请勿在行驶中使用视频功能，也不要绕过车辆或系统的安全限制。车机端目前从手机选择媒体，不提供完整文件浏览。视频签名包不含 CarPlay 音频模板权限；源码仍保留 VLC 原有音频模块。此旧版窗口方案不是 Apple 新系统的官方 CarPlay 视频类别。

## 构建与许可

使用 Xcode 打开 `VLC.xcworkspace`，或通过 [build-ios.yml](.github/workflows/build-ios.yml) 构建 arm64 IPA，再通过 [sign-carplay-video.yml](.github/workflows/sign-carplay-video.yml) 签名。详细步骤见 [安装说明](docs/TROLLSTORE_INSTALL.md)。

本项目不是 VideoLAN 官方发布。原项目与本分支保留的源码和许可信息见 [COPYING](COPYING)；感谢 VideoLAN 与 VLC for iOS 贡献者。
