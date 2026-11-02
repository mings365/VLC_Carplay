# TrollStore 安装测试

先取得 CI 生成且经过结构校验的 unsigned IPA。记录 iPhone 型号、iOS 版本、TrollStore 版本和安装失败时的原始错误；按 [TrollStore 官方仓库](https://github.com/opa334/TrollStore)核对该设备与系统组合是否受支持。勿把 unsigned IPA 直接视为已可安装。

逐项记录：

1. IPA 是否可经 TrollStore 安装和启动，签名后实际 entitlement 是什么。
2. 连接 CarPlay 后是否出现 VLC 入口，现有音频模板是否正常。
3. 系统是否创建视频 Scene，并提供可用显示窗口。
4. 驻车且系统允许时是否显示测试画面及真实 VLC 视频帧。

任一步失败都保留诊断日志，不修改车辆安全状态或绕过系统视频限制。
