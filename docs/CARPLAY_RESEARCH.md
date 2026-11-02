# CarPlay 视频技术调查

调查日期：2026-11-03。以下区分源码证据、官方文档和待实测假设。

## CarTube 源码证据

参考仓库：[Avangelista/CarTube](https://github.com/Avangelista/CarTube)，公开仓库已归档，README 宣称支持 iOS 14.0–15.4.1。

- `CarTube/CarTube.entitlements` 声明 `SBStarkCapable`、`platform-application`、`com.apple.private.security.no-container` 等特殊权限，未声明苹果新的 `com.apple.developer.carplay-video`。
- `CarTube/Info.plist` 用 `UIWindowSceneSessionRoleCarPlay` 注册 `CarPlaySceneDelegate`。该 delegate 的 `scene(_:willConnectTo:options:)` 从 `UIWindowScene` 创建 `UIWindow`，把 `CarPlayViewController` 设为根控制器。
- `CarTube/CarPlay/CarPlayViewController.swift` 将 `WKWebView` 加到控制器的 view。它不是 VLCKit 渲染实现，不能直接移植为 VLC 播放器。
- `CarTube/Headers/AVExternalDevice.h` 声明 `currentCarPlayExternalDevice`；`CarPlaySingleton.swift` 用它检测连接。这不是本项目可依赖的公开 CarPlay Framework API。
- `CarTube/Util/Utilities.swift` 的屏幕亮度及锁屏相关操作依赖特殊 entitlement，不能据此推断当前系统的车机窗口可用。
- `ipabuild.sh` 使用 `ldid` 给产物加 entitlement；这只是该项目的签名步骤，不能证明任意 iOS 版本会创建视频 Scene。

## 官方能力边界

- [Apple CarPlay 页面](https://developer.apple.com/carplay/)说明视频应用仅在支持的车辆、驻车且系统允许时工作。
- [CarPlay Video entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.carplay-video) 是独立类别，可与音频 entitlement 共存；[申请流程](https://developer.apple.com/documentation/carplay/requesting-carplay-entitlements)要求 Apple 授予受管能力。
- [WWDC26 官方介绍](https://developer.apple.com/videos/play/wwdc2026/212/)说明新视频应用能力属 iOS 27，车端必须支持 video in car；车端拒绝视频时应只播放音频。
- [CPWindow 文档](https://developer.apple.com/documentation/carplay/cpwindow)描述导航应用绘制地图的窗口，不能作为音频应用可自由绘制视频的证据。

## 路线比较

| 路线 | 系统与权限 | 窗口与集成 | 本环境可验证性 |
|---|---|---|---|
| A：扩展 VLC 现有音频 Scene | iOS 15+，现有 audio entitlement | 现有 `CPTemplateApplicationScene` 没有任意视频窗口；可复用播放服务和队列，不能直接把模板当视频画布 | 可编译，窗口需实机证据 |
| B：CarTube 式旧系统适配 | CarTube 公开范围 iOS 14–15.4.1，特殊权限及非公开机制 | 单独 `UIWindowSceneSessionRoleCarPlay`，需要证实系统是否创建 Scene；可复用 VLC 的 `videoOutputView` 迁移，不复用 WebView | 目标 iOS 版本未知；必须单独实验，不能宣称兼容 |
| C：苹果官方视频类别 | iOS 27、Apple 授予视频 entitlement、支持 video in car 的车辆 | 官方浏览与视频状态 API；需要按新版 SDK 和设备能力集成 | Windows 可写代码，CI 可编译；车端和授权无法代替实测 |

当前优先级：先完成 A 的构建基线与共享播放服务审计；随后建立独立能力探测层，分别验证 B/C 的 Scene 与窗口。没有窗口实测前不迁移真实视频渲染，也不添加臆测的私有 API。

目标 iPhone 已确认为 **iOS 16.5.1**。因此苹果在 iOS 27 引入的官方视频应用类别不适用于这台设备；后续窗口探测应针对旧系统实验路径独立进行，不能把 CarTube 在 iOS 14–15.4.1 的公开支持结论外推到 16.5.1。

阶段 B 已在 VLC 的 `Info.plist` 增加独立的 `UIWindowSceneSessionRoleCarPlay` 配置，并用 `VLCCarPlayVideoSceneDelegate` 记录 Scene 连接、窗口尺寸、测试视图绑定和断开。此代码没有加入特殊 entitlement，也没有启动视频；它只能探测系统在现有签名与配置下是否提供窗口。若 Scene 未连接，下一步需分别检查签名后 entitlement 和系统分派，不能据此认定 VLC 渲染失败。

## TrollStore

[TrollStore 源码](https://github.com/opa334/TrollStore)的安装和重签流程会处理 entitlement，但“IPA 可安装”、“CarPlay 图标出现”、“视频 Scene 创建”、“真实视频帧显示”是四个独立验收点。仍须对目标 iPhone 和具体 IPA 分别测试。
[TrollStore README](https://github.com/opa334/TrollStore/blob/main/README.md)列出的支持版本包含 iOS 16.5.1；这只确认系统版本在范围内，不能替代具体 IPA 的安装与权限测试。

## CarMovie

[CarMovie 仓库](https://github.com/Dcsyhi1998/CarMovie)仅公开 README，没有可移植的播放器源码。README 展示 CarPlay 视频效果，称需通过 TrollStore 安装，并列出 iOS 14–17 的部分支持信息及 iPhone XS/iOS 15.0.1、iPhone 14 Pro Max/iOS 16.0.2 测试机。它没有提供足以确认本项目目标设备、字幕、音轨或播放列表实现的代码证据，故只作功能参考。
