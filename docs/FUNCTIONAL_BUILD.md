# VLC CarPlay 功能试用版

目标设备：已安装 TrollStore 的 iPhone，实机验证系统为 iOS 16.5.1。车辆驻车后使用。此版复用官方 VLC for iOS 的媒体库、解码、播放服务与手机界面，手机上选择媒体，车机显示同一播放实例的视频画面。

## 已实现

- 独立 CarPlay 窗口；点击“已驻车 · 开始显示”后接管 VLC 视频输出。
- 车机播放/暂停、上一项、下一项、进度显示和跳转。
- 循环切换当前媒体的已有字幕与音轨；无可用轨道时按钮禁用。
- 轻点视频画面隐藏或显示控制栏；“停止显示”解除车机输出，手机播放器恢复时重新绑定。
- CarPlay 窗口停用或断开时解绑视频视图，避免保留失效的窗口引用。

用户已验证前一版在车机显示视频和播放声音，iPhone 熄屏后继续播放。本版新增的进度、轨道和断开回退尚待实机验证。

## 构建与安装

1. 等待 `build-ios.yml` 的 macOS arm64 构建成功。其 `vlc-ios-unsigned-ipa` 只是签名输入，**不要安装**。
2. 用该构建运行 ID 手动启动 `sign-carplay-video.yml`。签名工作流确认源构建成功且 Git 提交一致，再用 `SBStarkCapable` 给主程序签名并检查 IPA。
3. 从签名运行的 `vlc-carplay-trollstore-ipa` artifact 下载 ZIP，解压得到 `VLC-CarPlay-TrollStore.ipa`，通过 TrollStore 安装。
4. 在 iPhone VLC 中选择并播放视频；驻车连接 CarPlay，打开 VLC CarPlay，点击“已驻车 · 开始显示”。

## 限制

- 这条 iOS 16.5.1 路径依赖 TrollStore 保留 `SBStarkCapable`，普通 Apple ID 侧载未验证可用。签名包没有 CarPlay audio entitlement，原有音频模板在此包中不可作为已验收功能；源码仍保留该模块。
- “已驻车”是人工确认，应用没有已验证的车辆运动状态接口，不能声称自动行驶锁定。系统或车辆不允许视频时应停止使用。
- 车机当前通过手机 VLC 选择媒体；车机最近播放列表、完整文件浏览、网络流/格式矩阵、字幕与音轨实机效果还未验收。
