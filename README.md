<p align="center">
  <img width="128" height="128" src="src/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png">
</p>

# TuningFork

一个 macOS 菜单栏工具。

## Features

- `Rounded Corners`：屏幕圆角效果
- `Refresh Safari Tabs on Dark Mode`：系统切换到深色模式时自动刷新所有 Safari 标签页

## Default Behavior

- `Rounded Corners` 与 `Refresh Safari Tabs on Dark Mode` 在应用启动时默认启用

## Installation

### 下载最新预编译版本

从 [GitHub Releases](https://github.com/qvshuo/TuningFork/releases/latest) 下载预编译应用，解压后移至 **Applications** 文件夹。

首次启动前运行：

```bash
xattr -cr "/Applications/TuningFork.app"
```

### 从源代码构建

在 Xcode 中打开 `TuningFork.xcodeproj` 即可构建。

## Requirements

- macOS 26+
- Apple Silicon

## Permissions

首次使用 Safari 自动刷新功能时，macOS 将请求控制 Safari 的自动化权限，请在系统设置中允许。

同时，请先在 Safari **设置** → **高级**中启用**显示网页开发者功能**，再在**开发者**选项卡中启用**允许Apple 事件中的 JavaScript**。

## License

MIT
