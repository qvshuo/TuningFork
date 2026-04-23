# TuningFork

一个 macOS 菜单栏工具。

## Features

- `Rounded Corners`：屏幕圆角效果
- `Refresh Safari Tabs on Dark Mode`：系统切换到深色模式时刷新 Safari 标签页
- `NaïveProxy`：一键启动代理

应用无 Dock 图标，不弹出主窗口。

## Default Behavior

- `Rounded Corners` 与 `Refresh Safari Tabs on Dark Mode` 在启动时自动启用
- `NaïveProxy` 默认关闭，需手动开启

## Compatibility

- macOS 26+
- Apple Silicon

## Build

```bash
./build.sh
```

构建产物位于 `./build/TuningFork.app`。

## Launch

```bash
open ./build/TuningFork.app
```

## Requirements

使用 `NaïveProxy` 前需准备配置文件：

```bash
~/.config/naiveproxy/config.json
```

配置文件缺失或代理启动失败时，将通过系统通知提示。

## Permissions

首次使用 Safari 刷新功能时，macOS 可能请求自动化权限。
