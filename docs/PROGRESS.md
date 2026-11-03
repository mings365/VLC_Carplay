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

用户的仅 Stark 探测包实机照片显示深蓝白字 `WINDOW CONNECTED`。`CarPlayProbe.log` 记录 `UIWindowSceneSessionRoleCarPlay` 成功连接、窗口尺寸 640×240、窗口可见且 Scene 激活；手机 Scene 随后进入后台。由此确认当前设备上的独立窗口路径可用，但尚未验证视频帧。下一阶段复用 `VLCPlaybackService` 的单一渲染视图，在用户驻车确认后将输出目标迁移至该窗口，并在 Scene 停用或断开时解绑、返回手机显示。此实验仍缺少系统车辆运动状态接口，不能当作自动驻车检测或正式安全能力。

视频输出实验代码的 [build run 41575627700](https://github.com/mings365/VLC_Carplay/actions/runs/41575627700) 成功，随后 [sign run 41586471716](https://github.com/mings365/VLC_Carplay/actions/runs/41586471716) 成功生成两个 TrollStore IPA。用户曾安装 build run 的 unsigned 中间 IPA，车机 VLC 图标消失；签名产物尚待实机验证。

用户报告安装签名视频实验包后，CarPlay 车机**可以播放视频**。这确认至少一条 VLC 视频渲染路径在 iOS 16.5.1 实机上可用。用户本次附带的 `D:\CarPlayProbe.log` 仍是旧静态探针日志（最后事件为 02:53:38Z 的 `video scene disconnected`，没有新版 `video output attach requested`），因此该文件无法验证本次播放绑定、声音或断开恢复；这些仍待新日志与实机结果确认。不得把用户报告扩展成字幕、音轨、协议、行驶状态或原 CarPlay 音频功能已验证。

用户补充确认：视频画面和声音均正常，iPhone 熄屏后仍继续播放；断开 CarPlay 后能否返回手机尚未测试。当前签名包依赖 TrollStore 保留 `SBStarkCapable`；普通 Apple ID 侧载和未装 TrollStore 的 iPhone 尚无可用的此旧版窗口安装路径。unsigned 包失去车机入口是本机对照观察，不等同于穷尽所有其他系统/签名方式。

功能试用版新增车机进度跳转、上一项/下一项、播放暂停、字幕与音轨循环切换、隐藏控制栏和主动停止显示，iPhone 应用显示名改为 `VLC CarPlay`。独立 [build run 41588800639](https://github.com/mings365/VLC_Carplay/actions/runs/41588800639) 和 [sign run 41589300332](https://github.com/mings365/VLC_Carplay/actions/runs/41589300332) 均成功；本地复检最终 IPA 完整、arm64、包含 VLCKit、显示名与 CarPlay Scene 正确。新增控制功能和断开回退待实机验收。

用户提供功能版实机照片：车机正常显示视频帧、进度条、当前/总时间及控制按钮，但控制条播放时持续覆盖画面。为此改为播放 5 秒后自动隐藏进度和按钮，暂停与拖动进度时保持可见；轻点画面手动切换可见状态。点击识别移到场景根视图，并过滤控制按钮和滑块触摸，避免被 VLC 视频子视图拦截或误触控制。等待新 CI 与实机验证。
