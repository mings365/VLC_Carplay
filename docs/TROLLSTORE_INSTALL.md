# TrollStore 实机测试

目标设备为 iOS 16.5.1。**不要安装 `build-ios.yml` 运行中的 `vlc-ios-unsigned-ipa`**：它是供签名工作流使用的中间产物，没有 `SBStarkCapable`，车机上可能没有 VLC 入口。

本实验包目前依赖 TrollStore 保留 `SBStarkCapable`。普通 Apple ID 侧载可以安装某些 VLC 构建，但不能据此期待该 iOS 16.5.1 非官方 CarPlay 窗口路径可用。Apple 常规 CarPlay 类别权限须获批并纳入描述文件；官方 CarPlay 视频类别属于较新系统和支持视频的车辆，不能替代本机的旧版实验路径。

当前视频输出实验包来自[签名运行 41586471716](https://github.com/mings365/VLC_Carplay/actions/runs/41586471716)。在 Artifacts 中下载 `vlc-carplay-window-only-probe-trollstore-ipa`，解压外层 ZIP，得到 `VLC-CarPlay-window-only-probe-TrollStore.ipa`。此包含 `SBStarkCapable`，沿用已通过实机验证的独立 CarPlay 窗口路径。**真实视频帧尚未经实机验证。**

1. 用 TrollStore 安装 IPA，在 iPhone 启动 VLC，确认原有界面正常。
2. 车辆驻车时，用 iPhone VLC 选择并开始播放一个本地视频。保持 iPhone 解锁、亮屏。
3. 连接 CarPlay，在车机打开 VLC，点“已驻车 · 开始显示”。观察能否显示视频帧、字幕和声音；拍摄车机画面。
4. 从 iPhone“文件”App →“我的 iPhone”→ VLC 导出 `CarPlayProbe.log`。如果没有日志，也记录这一点。
5. 断开 CarPlay，检查视频能否返回手机显示，再重连并记录结果。

同一次签名运行还提供 `vlc-carplay-window-probe-trollstore-ipa`，含 CarPlay audio 与 `SBStarkCapable` 两项权限。它可能进入原有音频模板，适合作对照。两个包的 Bundle ID 都是 `com.example.vlc-ios`，安装后一个会替换前一个。源码中的原有 CarPlay 音频功能仍保留。

“已驻车”按钮是人工确认，并非自动车辆运动状态检测。此版本仅用于驻车实验；窗口停用或断开时会解绑视频输出。不修改车辆状态或安全联锁。请只分享车机照片、探测日志和必要的安装错误，不要分享完整媒体路径或私人媒体库。
