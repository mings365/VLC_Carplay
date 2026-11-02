# TrollStore 安装测试

目标系统为 iOS 16.5.1，处于 [TrollStore 官方支持范围](https://github.com/opa334/TrollStore/blob/main/README.md)。记录 iPhone 型号、TrollStore 版本和安装失败时的原始错误。勿把 unsigned IPA 直接视为已可安装。

阶段 B 的 `sign-carplay-probe.yml` 从成功的 unsigned 构建运行下载 IPA，用 `ldid` 将 `.github/CarPlayVideoProbe.entitlements` 写入主可执行文件，再上传独立的 `VLC-CarPlay-window-probe-TrollStore.ipa`。该实验权限只有现有 CarPlay audio 与 CarTube 使用的 `SBStarkCapable`；不包含无沙盒或平台应用权限。它用于测试安装、图标和静态窗口 Scene，**不包含 CarPlay 视频播放**。签名命令通过只证明 entitlement 已写入，不证明 iOS 会接受权限或创建窗口。

已在 [签名运行 41546362321](https://github.com/mings365/VLC_Carplay/actions/runs/41546362321) 生成探测包。进入该私有 Actions 运行页面，在 Artifacts 下载 `vlc-carplay-window-probe-trollstore-ipa`，解压外层 ZIP 后得到 IPA。仅在车辆驻车时测试：

1. 用 TrollStore 安装 IPA，记录成功或完整错误信息；在 iPhone 启动应用，确认原有 VLC 界面出现。
2. 连接 CarPlay，记录 VLC 图标是否出现、现有音频模板是否可打开，以及车机上是否出现 `VLC CarPlay display probe` 静态字样。分别测试有线和无线。
3. 断开、重连一次，记录有无闪退、黑屏或重复窗口。若可以取得 iPhone 系统日志，筛选 `VLC CarPlay` 和 `VLC CarPlay video probe` 相关行；不要上传完整媒体 URL 或私人文件路径。

请返回 iPhone 型号、TrollStore 版本、安装结果、车机照片或截图，以及出现问题的准确步骤。静态字样出现仅说明窗口可绘制，不说明系统允许视频或 VLC 已输出视频帧。

逐项记录：

1. IPA 是否可经 TrollStore 安装和启动，签名后实际 entitlement 是什么。
2. 连接 CarPlay 后是否出现 VLC 入口，现有音频模板是否正常。
3. 系统是否创建视频 Scene，并提供可用显示窗口。
4. 驻车且系统允许时是否显示测试画面及真实 VLC 视频帧。

任一步失败都保留诊断日志，不修改车辆安全状态或绕过系统视频限制。
