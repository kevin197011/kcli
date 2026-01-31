# kcli

`kcli` 是一个基于 Ruby 构建的模块化运维工具命令行框架。它旨在为运维团队提供一个灵活、可扩展的工具箱，支持使用 Ruby 文件作为动态配置。

## 特性

- **模块化设计**：插件式的模块加载机制，易于扩展。
- **Ruby 动态配置**：配置文件即 Ruby 代码，支持逻辑判断、环境变量及动态逻辑。
- **自动加载**：基于 `Zeitwerk` 实现的高效代码加载。
- **精美输出**：内置表格化输出支持。

## 快速开始

### 安装依赖

首先确保你安装了 Ruby (>= 3.0.0)，然后运行：

```bash
bundle install
```

### 使用本地命令

你可以直接从源码运行命令：

```bash
./bin/kcli help
```

### 安装为 Gem

**本地安装：**

```bash
gem build kcli.gemspec
gem install ./kcli-0.1.0.gem
```

**从 GitHub 安装 (Gemfile)：**

```ruby
gem 'kcli', github: 'your-user/kcli'
```

## 配置说明

`kcli` 会自动加载以下路径的 Ruby 配置文件：
1. `~/.kcli/*.rb` (全局配置)
2. `./.kcli/*.rb` (当前目录配置)

### 示例：GCP 模块配置

创建 `~/.kcli/gcp.rb`:

```ruby
Kcli.configure(:gcp) do |config|
  config.project_id = "your-gcp-project-id"
end
```

## 模块介绍

### GCP 模块

支持查看 GCP 资源清单。

**列出所有 Compute 实例：**

```bash
kcli gcp compute list
```

## 扩展与开发

### 添加新模块

1. 在 `lib/kcli/modules/` 下创建新的 Ruby 文件，例如 `aws.rb`。
2. 定义一个继承自 `Kcli::Module` 的类：

```ruby
module Kcli
  module Modules
    class Aws < Kcli::Module
      desc "s3 [COMMAND]", "AWS S3 commands"
      subcommand "s3", S3Module # 如果需要子命令
    end
  end
end
```

## License

MIT
