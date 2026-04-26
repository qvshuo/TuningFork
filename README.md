# TuningFork

一个 macOS 菜单栏工具。

## Features

- `Rounded Corners`：屏幕圆角效果
- `Refresh Safari Tabs on Dark Mode`：系统切换到深色模式时自动刷新所有 Safari 标签页
- `Start Proxy`：一键启动 NaïveProxy 代理

## Default Behavior

- `Rounded Corners` 与 `Refresh Safari Tabs on Dark Mode` 在应用启动时默认启用
- `Start Proxy` 默认关闭，需手动开启

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

使用 `Start Proxy` 前需准备配置文件：

```bash
~/.config/naiveproxy/config.json
```

## Permissions

首次使用 Safari 自动刷新功能时，macOS 可能请求自动化权限。

## License

MIT
