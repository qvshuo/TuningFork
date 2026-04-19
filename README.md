# TuningFork

TuningFork 是一个安静待在菜单栏里的 macOS 小工具。

它把几个零散但常用的动作放进同一个入口，让你不用反复切设置、开终端、找脚本。

## Features

- `Rounded Corners`：为屏幕补上圆角效果
- `Refresh Safari Tabs on Dark Mode`：系统切到深色模式时刷新 Safari 标签页
- `NaïveProxy`：一键启动代理

它没有 Dock 图标，不会弹出主窗口，也不打扰你当前的工作流。

## Default Behavior

- `Rounded Corners` 和 `Refresh Safari Tabs on Dark Mode` 会在启动时自动启用
- `NaïveProxy` 默认关闭，需要手动开启

## Compatibility

- macOS 26+
- Apple Silicon

## Build

```bash
./build.sh
```

构建完成后，应用位于 `./build/TuningFork.app`。

## Launch

```bash
open ./build/TuningFork.app
```

## NaïveProxy

如果要使用 `NaïveProxy`，请先准备好：

```bash
~/.config/naiveproxy/config.json
```

当配置文件不存在，或代理启动失败时，TuningFork 会通过系统通知直接告诉你。

## Permissions

首次使用 Safari 刷新功能时，macOS 可能会请求自动化权限。
