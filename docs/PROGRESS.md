# 开发进度

2026-11-03：

- 工作区原为空 Git 仓库；取官方 `vlc-ios` 提交 `04d738d...` 作为未改动源码基线，并建立 `codex/carplay-video` 分支。
- 已审计入口、CarPlay 音频 Scene、单实例播放服务、视频输出容器切换、依赖锁定与共享 Scheme。
- 已调查 CarTube 的旧式 Scene、特殊 entitlement、WebView 和非公开连接检测；已核对苹果新版视频类别的设备与授权条件。
- 新增 GitHub Actions arm64 unsigned IPA 基线构建及文档。

2026-11-03 补充验证：使用 `actionlint` 检查工作流，发现并修复 job 级 `env` 不能引用 `runner.temp` 的错误；复检通过。YAML 解析、Scheme 路径、锁文件和 plist 静态检查通过。已取得用户独立私有仓库 `mings365/VLC_Carplay` 并设为 `origin`。公开上游的普通 GitHub Fork 仍为公开。

私有仓库已由完整源码快照初始化，提交 `9d1d279`；本地工作区已切换到跟踪该私有仓库的 `codex/carplay-private` 分支。该私有仓库保留官方源码内容及许可证，但作为独立仓库不继承上游 Git 历史。

2026-11-03 私有 CI 首次运行：[run 41479690974](https://github.com/mings365/VLC_Carplay/actions/runs/41479690974)。CocoaPods 安装与 `xcodebuild` arm64 Release 编译通过，日志明确出现 `BUILD SUCCEEDED`；IPA 校验阶段失败，原因是 `lipo -verify_arch` 的参数顺序写反。已修正工作流，待重跑确认完整 IPA。

2026-11-03 私有 CI 第二次运行：[run 41481739294](https://github.com/mings365/VLC_Carplay/actions/runs/41481739294) 完整成功。诊断产物记录 arm64 Mach-O 可执行文件，以及 `VLCKit.framework`、`VLCMediaLibraryKit.framework`；`vlc-ios-unsigned-ipa` 与诊断产物均已上传。Bundle ID 为基线值 `com.example.vlc-ios`。此结果仅证明编译与打包，不证明 TrollStore 安装、CarPlay 视频窗口或真实视频播放。

下一步：在独立适配层验证窗口/视频可用性，再决定是否迁移 VLC 的现有渲染视图。

2026-11-03：目标 iPhone 为 iOS 16.5.1。已加入独立 `UIWindowSceneSessionRoleCarPlay` 探测 Scene、静态测试视图与生命周期日志；现有音频模板 Scene 加入连接/断开日志。未加入特殊 entitlement，未接入 VLC 渲染，待 CI 与实机确认窗口是否实际可用。

另增独立的 TrollStore 探测包签名工作流，只给主可执行文件写入 audio 与 `SBStarkCapable` 两项 entitlement；该包是否可安装、Scene 是否连接仍待分别测试。

探测版 [build run 41545593078](https://github.com/mings365/VLC_Carplay/actions/runs/41545593078) 成功；[sign run 41546362321](https://github.com/mings365/VLC_Carplay/actions/runs/41546362321) 成功并上传 `vlc-carplay-window-probe-trollstore-ipa`。签名日志确认两项 entitlement 为 `true`、主可执行文件仍是 arm64 Mach-O、IPA 压缩结构校验通过。实机安装、CarPlay Scene 和静态画面均未验证。

用户实机反馈：iOS 16.5.1 上安装后车机有 VLC 图标，但打开全黑；CarTube 同机同车正常，VLC 黑屏时似乎不在手机前台。已开始第二轮诊断：将测试窗口背景改为深蓝、文字改为大号，并把手机、音频模板、视频 Scene 生命周期和窗口状态写入 Documents 的 `CarPlayProbe.log`。当前尚不能判断黑屏是 Scene 未连接、窗口未显示还是前台状态造成。

用户随后提供的车机照片表明：实际出现的是 VLC 原有音频模板（艺术家、流派、网络、播放列表），深色区域是音频列表内容区；新增的视频窗口 Scene 没有可见呈现。为排除音频类别优先被系统选择的问题，签名流程增加第二个仅含 `SBStarkCapable` 的独立对照 IPA，正式工程的 CarPlay 音频源码和原 entitlement 保持不变。

第二轮诊断代码的 [build run 41555116850](https://github.com/mings365/VLC_Carplay/actions/runs/41555116850) 成功；[sign run 41555816429](https://github.com/mings365/VLC_Carplay/actions/runs/41555816429) 成功上传 audio+Stark 和仅 Stark 两个对照 IPA。仅 Stark 包的签名脚本确认没有 CarPlay audio entitlement。等待用户实机比较及 `CarPlayProbe.log`。
