# VLC CarPlay 1.0.0

目标设备：已安装 TrollStore 的 iPhone，实机验证系统为 iOS 16.5.1。车辆驻车后使用。此版复用官方 VLC for iOS 的媒体库、解码、播放服务与手机界面，手机上选择媒体，车机显示同一播放实例的视频画面。

## 已实现

- 独立 CarPlay 窗口；点击“已驻车 · 开始显示”后接管 VLC 视频输出。
- 车机播放/暂停、上一项、下一项、进度显示和跳转。
- 循环切换当前媒体的已有字幕与音轨；无可用轨道时按钮禁用。
- 播放约 5 秒后自动隐藏控制栏；轻点视频画面重新显示或手动隐藏，暂停及拖动进度时保持可见。“停止显示”解除车机输出，手机播放器恢复时重新绑定。
- CarPlay 窗口停用或断开时解绑视频视图，避免保留失效的窗口引用。

本版沿用已能在车机播放的单实例视频路径，并提供车机控制界面。

## 构建与安装

1. 从 [v1.0.0 Release](https://github.com/mings365/VLC_Carplay/releases/tag/v1.0.0) 下载 `VLC-CarPlay-v1.0.0-TrollStore.ipa`，通过 TrollStore 安装。
2. `build-ios.yml` 中的 `vlc-ios-unsigned-ipa` 只是签名输入，**不要安装**。`sign-carplay-video.yml` 会确认源构建成功且 Git 提交一致，并检查 `SBStarkCapable`、arm64 与 IPA 结构。
3. 在 iPhone VLC 中选择并播放视频；驻车连接 CarPlay，打开 VLC CarPlay，点击“已驻车 · 开始显示”。

## 限制

- 这条 iOS 16.5.1 路径依赖 TrollStore 保留 `SBStarkCapable`，普通 Apple ID 侧载未验证可用。签名包没有 CarPlay audio entitlement，原有音频模板在此包中不可作为已验收功能；源码仍保留该模块。
- “已驻车”是人工确认，应用没有已验证的车辆运动状态接口，不能声称自动行驶锁定。系统或车辆不允许视频时应停止使用。
- 车机当前通过手机 VLC 选择媒体；车机最近播放列表、完整文件浏览、网络流/格式矩阵、字幕与音轨实机效果还未验收。
