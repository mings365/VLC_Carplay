# 开发进度

2026-11-03：

- 工作区原为空 Git 仓库；取官方 `vlc-ios` 提交 `04d738d...` 作为未改动源码基线，并建立 `codex/carplay-video` 分支。未创建提交、未推送。
- 已审计入口、CarPlay 音频 Scene、单实例播放服务、视频输出容器切换、依赖锁定与共享 Scheme。
- 已调查 CarTube 的旧式 Scene、特殊 entitlement、WebView 和非公开连接检测；已核对苹果新版视频类别的设备与授权条件。
- 新增 GitHub Actions arm64 unsigned IPA 基线构建及文档。Windows 静态检查待执行；CI 和实机验证尚未执行。

2026-11-03 补充验证：使用 `actionlint` 检查工作流，发现并修复 job 级 `env` 不能引用 `runner.temp` 的错误；复检通过。YAML 解析、Scheme 路径、锁文件和 plist 静态检查通过。已取得用户独立私有仓库 `mings365/VLC_Carplay` 并设为 `origin`。公开上游的普通 GitHub Fork 仍为公开。

下一步：先运行 CI 并修复真实构建错误。基线通过后，在独立适配层实现窗口/视频可用性诊断，再决定是否迁移 VLC 的现有渲染视图。

建议提交信息（仅供用户执行）：`build: add iOS baseline CI and CarPlay research notes`。
