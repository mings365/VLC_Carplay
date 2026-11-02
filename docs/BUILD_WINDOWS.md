# Windows 上使用 GitHub Actions 构建

当前 Windows 环境无 Xcode，无法在本机执行 iOS 编译。`.github/workflows/build-ios.yml` 是原版 VLC 基线构建任务。

1. 使用**独立的私有仓库** `mings365/VLC_Carplay`（不要使用公开 VLC 仓库的 Fork 按钮；GitHub 规定公开仓库的 Fork 仍为公开）。将当前修改提交并推送后运行 `Build unsigned VLC for iOS`。GitHub 的 `workflow_dispatch` 手动按钮要求工作流文件存在于默认分支；首次推送也可由本工作流的 `push` 触发。
2. 工作流用 `macos-26`、`VLC-iOS-no-watch` 共享 Scheme、CocoaPods 1.16.2、锁定的 SPM 依赖，编译 `generic/platform=iOS` 的 arm64 Release 产物，关闭代码签名。
3. 构建通过后校验 `.app` 的 `CFBundleExecutable`、Mach-O arm64 和 `Frameworks`，再压成 `Payload/*.app` 的 unsigned IPA。下载 `vlc-ios-unsigned-ipa` 和 `vlc-ios-build-diagnostics`。
4. 若失败，检查 `packages.log`、`build.log`、`build.xcresult`。构建步骤使用 `pipefail`，失败不会被日志管道掩盖。

基线构建已在私有仓库的 [Actions run 41481739294](https://github.com/mings365/VLC_Carplay/actions/runs/41481739294) 成功：arm64 Release 编译、可执行文件与 Frameworks 校验、IPA 打包和产物上传均通过。unsigned IPA 尚不是可安装的签名包；真实设备测试需单独签名、安装与运行记录。

阶段 B 提供独立的 `Sign CarPlay window probe for TrollStore` 手动工作流。输入一次成功的 unsigned 构建 run ID；它仅重新签名并打包已有 IPA，不重复编译 VLC。产物名为 `vlc-carplay-window-probe-trollstore-ipa`。这个包只验证旧系统窗口探测，不保证安装或视频显示。
