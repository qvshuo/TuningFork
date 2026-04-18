# TuningFork

TuningFork 是一个纯 macOS 菜单栏应用，基于 SwiftUI 和 `MenuBarExtra` 实现。

它提供两个功能：

- `Rounded Corners`：为所有已连接屏幕绘制圆角遮罩
- `Refresh Safari Tabs on Dark Mode`：当系统从浅色模式切换到深色模式时，刷新 Safari 的所有标签页

应用没有 Dock 图标，也没有额外窗口。

## 系统要求

- macOS 26+
- Apple Silicon (`arm64`)
- 已安装 Xcode Command Line Tools，并可使用 `swiftc`

## 构建

执行：

```bash
./build.sh
```

产物输出到：

```bash
./build/TuningFork.app
```

## 运行

执行：

```bash
open ./build/TuningFork.app
```

## Safari 权限

Safari 刷新功能通过 `NSAppleScript` 控制 Safari 刷新所有标签页。

首次使用时，macOS 可能会请求自动化权限。打包产物中的 `Info.plist` 已包含 `NSAppleEventsUsageDescription`。

这个功能只会在系统从浅色模式切换到深色模式时触发，不会在每次主题通知时都执行。

## 项目文件

- `TuningForkApp.swift`：菜单栏 UI 和应用状态
- `RoundedCorners.swift`：屏幕圆角服务
- `SafariDarkModeRefresh.swift`：深色模式监听和 Safari 刷新服务
- `build.sh`：构建独立 `.app` 的脚本

## 说明

- `build.sh` 会在打包时生成 app bundle 内的 `Info.plist`
- 每次构建都会重建 `build` 目录
- 如果系统存在 `codesign`，脚本会自动执行 ad-hoc 签名
