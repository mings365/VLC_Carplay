# VLC CarPlay 架构审计

基线：VideoLAN `vlc-ios` 提交 `04d738d84b07300f4108b97e61d607700c19791e`。当前工作区最初只有空 Git 仓库，源码取自官方 GitHub 镜像的该提交；用户的独立私有仓库为 `mings365/VLC_Carplay`。

## 已核实的调用链

- `Sources/App/iOS/main.m` 调用 `UIApplicationMain`，委托为 `VLCAppDelegate`。
- `Resources/iOS/Info.plist` 的 `UIApplicationSceneManifest` 为手机注册 `VLCAppSceneDelegate`，为 `CPTemplateApplicationSceneSessionRoleApplication` 注册 `VLCCarPlaySceneDelegate`。
- `Sources/CarPlay/VLCCarPlaySceneDelegate.m` 在 `didConnectInterfaceController:` 创建媒体库、播放列表、广播等音频模板，并引用 `[VLCPlaybackService sharedInstance]`；断开时移除观察者和模板对象。现有 CarPlay 入口只使用模板，不提供视频窗口。
- `Sources/Playback/Control/VLCPlaybackService.m` 的 `setupPlayer` 创建一个 `VLCMediaListPlayer`，通过 `initWithDrawable:self` 将服务本身作为 VLCKit drawable；`_mediaPlayer = _listPlayer.mediaPlayer`。播放队列和播放状态集中在此服务及 `VLCPlaybackService+MediaLibrary.m`。
- 同文件的 `setVideoOutputView:` 在主线程把 `_actualVideoOutputView` 从旧容器移除，放入新容器。`Sources/Playback/Player/VideoPlayer-iOS/VideoPlayerViewController.swift` 创建手机容器，并在 `changeVideoOutput(to:)` 处理现有外屏迁移。因此单实例迁移有源码依据，但尚未证明 CarPlay 窗口可用或 VLCKit 在其中正常渲染。
- 媒体库在 `Sources/Media Library/MediaLibraryService.swift` 及其模型目录；播放队列 UI 在 `Sources/Playback/Queue/QueueViewController.swift`。字幕、音轨、进度和倍速 API 已由 `VLCPlaybackService.h` 暴露。

## 构建组成

- `VLC.xcworkspace` 与 `VLC.xcodeproj`；共享 Scheme 包含 `VLC-iOS`、`VLC-iOS-no-watch`。CI 选用后者，避免 Watch 扩展签名问题。
- `Podfile` 使用 CocoaPods，锁文件要求 1.16.2。VLCKit 不是 Podfile 依赖，而由 Swift Package Manager 从 VideoLAN GitLab 获取；`Package.resolved` 锁定 VLCKit `4.0.0-a25` (`8f5ce02f...`) 与 VLCMediaLibraryKit `0.15.0-b3` (`e698aba8...`)。
- iOS target 为 15.0。正式 Entitlements 位于 `Resources/iOS/VLC.entitlements`，目前有 `com.apple.developer.carplay-audio`；Scene 配置在 `Resources/iOS/Info.plist`。

## 后续边界

原版 VLC 基线已在 CI 编译通过。阶段 B 新增 `Sources/CarPlay/VLCCarPlayVideoSceneDelegate.m`：它对应 `UIWindowSceneSessionRoleCarPlay`，只在系统真正连接该 Scene 时创建测试窗口并记录窗口尺寸；现有 `CPTemplateApplicationSceneSessionRoleApplication` 音频模板仍由原 delegate 管理。测试窗口不接入播放器，也不显示视频。只有设备确认窗口和系统视频可用状态后才迁移现有渲染目标；不得仅以 entitlement 或外接屏存在作为视频可用的证明。
