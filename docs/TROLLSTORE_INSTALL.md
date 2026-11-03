# TrollStore 安装与实机测试

1. 从[功能包签名运行 41589300332](https://github.com/mings365/VLC_Carplay/actions/runs/41589300332) 下载 `vlc-carplay-trollstore-ipa`，解压外层 ZIP，得到 `VLC-CarPlay-TrollStore.ipa`。
2. 用 TrollStore 安装 IPA。在 iPhone 上打开 **VLC CarPlay**，确认原有 VLC 媒体库和播放界面正常。安装新包会替换同 Bundle ID `com.example.vlc-ios` 的旧探测包。
3. 车辆驻车时，在 iPhone VLC CarPlay 选择并开始播放视频；连接车机，打开 VLC CarPlay，点“已驻车 · 开始显示”。
4. 车机控制栏可播放/暂停、切换队列项目、跳转进度、循环选择已有字幕和音轨、停止显示。轻点画面隐藏或唤出控制栏。
5. 检查手机熄屏、CarPlay 断开及重连后的表现。出错时从 iPhone“文件”App →“我的 iPhone”→ VLC 导出新的 `CarPlayProbe.log`；只分享该日志与车机照片，不要导出私人媒体库。

**不要安装 `build-ios.yml` 中的 `vlc-ios-unsigned-ipa`。**它仅供签名工作流使用，没有已验证的 CarPlay 窗口权限；用户曾安装此包后车机 VLC 图标消失。

此 iOS 16.5.1 实验路径依赖 TrollStore 保留 `SBStarkCapable`；普通 Apple ID 侧载不可视为可用。按钮是人工驻车确认，不是自动车辆运动状态检测；不修改车辆状态或安全联锁。视频和声音在上一版经用户实机验证，本版新增控制、字幕和断开回退仍待验收。[功能与限制](FUNCTIONAL_BUILD.md)。
