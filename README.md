# kcli

`kcli` 是一个基于 Ruby 构建的模块化运维工具命令行框架。它旨在为运维团队提供一个灵活、可扩展的工具箱，支持使用 Ruby 文件作为动态配置。

## 特性

- **模块化设计**：插件式的模块加载机制，易于扩展。
- **Ruby 动态配置**：配置文件即 Ruby 代码，支持逻辑判断、环境变量及动态逻辑。
- **自动加载**：基于 `Zeitwerk` 实现的高效代码加载。
- **精美输出**：内置表格化输出支持。

## 安装指南

### 1. 安装 Ruby

`kcli` 要求 Ruby 版本 >= 3.0.0。

#### macOS
推荐使用 [Homebrew](https://brew.sh/) 安装：
```bash
brew install ruby
```
如果你需要管理多个 Ruby 版本，建议使用 [rbenv](https://github.com/rbenv/rbenv) 或 [rvm](https://rvm.io/)。

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install ruby-full build-essential zlib1g-dev
```

#### Linux (CentOS/RHEL)
```bash
sudo yum install ruby ruby-devel
```
*注意：如果系统自带版本过低，建议通过 `rbenv` 或源码编译安装 Ruby 3.0+。*

#### Windows
推荐从 [RubyInstaller](https://rubyinstaller.org/) 下载并运行安装程序（建议选择 **Ruby+Devkit** 版本以方便编译依赖）。

### 2. 安装 kcli

目前支持从源码克隆并安装为本地 Gem。

```bash
# 克隆仓库
git clone https://github.com/kevin197011/kcli.git
cd kcli

# 安装依赖
bundle install

# 编译并安装为 Gem
gem build kcli.gemspec
gem install ./kcli-0.1.0.gem
```

安装完成后，你可以验证是否安装成功：
```bash
kcli help
```

**从 GitHub 安装 (Gemfile)：**

```ruby
gem 'kcli', github: 'kevin197011/kcli'
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
