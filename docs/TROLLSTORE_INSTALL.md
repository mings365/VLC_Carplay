# TrollStore 实机探测

目标设备为 iOS 16.5.1。最新的两个探测包来自[签名运行 41555816429](https://github.com/mings365/VLC_Carplay/actions/runs/41555816429)，均已在 CI 中完成签名和 IPA 完整性检查。它们只用于确认 CarPlay 窗口是否被系统创建，**尚不包含视频播放**。

| 外层 ZIP | 解压后的 IPA | 主程序实验权限 |
| --- | --- | --- |
| `vlc-carplay-window-only-probe-trollstore-ipa.zip` | `VLC-CarPlay-window-only-probe-TrollStore.ipa` | `SBStarkCapable` |
| `vlc-carplay-window-probe-trollstore-ipa.zip` | `VLC-CarPlay-window-probe-TrollStore.ipa` | CarPlay audio、`SBStarkCapable` |

两包的 Bundle ID 都是 `com.example.vlc-ios`，一次只能安装一个。源码中的音频 CarPlay 功能仍保留；仅窗口权限包用于比较系统对两种权限组合的分派结果。

1. 先解压 **window-only** ZIP，通过 TrollStore 安装其中的 IPA；在 iPhone 上打开 VLC，确认应用能启动。
2. 车辆驻车、iPhone 解锁且屏幕点亮时连接 CarPlay，从车机打开 VLC。拍摄车机画面，记录图标是否出现，以及是否看到深蓝底白字 `VLC CARPLAY PROBE / WINDOW CONNECTED`。
3. 打开 iPhone“文件”App →“我的 iPhone”→ VLC，导出 `CarPlayProbe.log`。如果没有该文件，也记录这一点。
4. 再解压并安装 **window-probe** ZIP 中的 IPA，重复步骤 1–3。第二次安装会替换第一次的包。

若车机显示原有“艺术家 / 流派 / 网络 / 播放列表”页面，那是音频模板，并非视频窗口。若打开后无内容，保持 VLC 在 iPhone 前台再试一次。分别记录安装错误、崩溃、重连后的变化；分享车机照片和 `CarPlayProbe.log` 即可，不需要导出媒体库或完整系统日志。

静态探测字样出现只证明窗口可绘制。真实 VLC 视频帧与驻车条件下的系统视频许可仍需后续验证；不修改车辆安全状态或绕过系统限制。
