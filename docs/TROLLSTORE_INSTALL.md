# TrollStore 安装测试

目标系统为 iOS 16.5.1，处于 [TrollStore 官方支持范围](https://github.com/opa334/TrollStore/blob/main/README.md)。记录 iPhone 型号、TrollStore 版本和安装失败时的原始错误。勿把 unsigned IPA 直接视为已可安装。

阶段 B 的 `sign-carplay-probe.yml` 从成功的 unsigned 构建运行下载 IPA，用 `ldid` 将 `.github/CarPlayVideoProbe.entitlements` 写入主可执行文件，再上传独立的 `VLC-CarPlay-window-probe-TrollStore.ipa`。该实验权限只有现有 CarPlay audio 与 CarTube 使用的 `SBStarkCapable`；不包含无沙盒或平台应用权限。它用于测试安装、图标和静态窗口 Scene，**不包含 CarPlay 视频播放**。签名命令通过只证明 entitlement 已写入，不证明 iOS 会接受权限或创建窗口。

逐项记录：

1. IPA 是否可经 TrollStore 安装和启动，签名后实际 entitlement 是什么。
2. 连接 CarPlay 后是否出现 VLC 入口，现有音频模板是否正常。
3. 系统是否创建视频 Scene，并提供可用显示窗口。
4. 驻车且系统允许时是否显示测试画面及真实 VLC 视频帧。

任一步失败都保留诊断日志，不修改车辆安全状态或绕过系统视频限制。
