# AppCAT安装位置和使用指南
# AppCAT Installation Location and Usage Guide

## 问题 / Question

MCP工具将AppCAT下载到 `~/.appcat` 路径，我后续其他操作还能用这个地址吗？

After MCP tool downloads AppCAT to `~/.appcat` path, can I use this path in my subsequent operations?

---

## 答案 / Answer

**是的！你完全可以使用这个路径。** / **Yes! You can absolutely use this path.**

当MCP工具 `app-modernization-appmod-install-appcat` 成功安装AppCAT后，它会被安装到 `~/.appcat` 目录，你可以通过多种方式使用它。

When the MCP tool `app-modernization-appmod-install-appcat` successfully installs AppCAT, it will be installed to the `~/.appcat` directory, and you can use it in multiple ways.

---

## 安装位置详情 / Installation Location Details

### 目录结构 / Directory Structure

```
~/.appcat/
├── bin/
│   └── appcat              # 可执行文件 / Executable binary
├── rulesets/               # 规则集 / Rulesets
│   ├── azure/
│   ├── cloud-readiness/
│   └── ...
└── ...
```

### 验证安装 / Verify Installation

检查AppCAT是否已安装：

Check if AppCAT is installed:

```bash
# 检查目录是否存在 / Check if directory exists
ls -la ~/.appcat

# 查看可执行文件 / View executable
ls -la ~/.appcat/bin/appcat

# 检查版本 / Check version
~/.appcat/bin/appcat --version
```

---

## 使用方法 / Usage Methods

### 方法1：直接使用完整路径 / Method 1: Use Full Path Directly

你可以直接使用完整路径运行AppCAT：

You can run AppCAT directly using the full path:

```bash
# 运行AppCAT评估 / Run AppCAT assessment
~/.appcat/bin/appcat analyze /path/to/your/project

# 查看帮助 / View help
~/.appcat/bin/appcat --help

# 指定目标平台 / Specify target platform
~/.appcat/bin/appcat analyze /path/to/project \
  --target azure-aks \
  --target azure-appservice \
  --mode issue-only
```

### 方法2：添加到PATH（推荐）/ Method 2: Add to PATH (Recommended)

将AppCAT添加到系统PATH，这样你就可以在任何位置直接使用 `appcat` 命令：

Add AppCAT to your system PATH so you can use the `appcat` command from anywhere:

#### Bash用户 / For Bash Users

编辑 `~/.bashrc` 或 `~/.bash_profile`：

Edit `~/.bashrc` or `~/.bash_profile`:

```bash
# 添加到文件末尾 / Add to end of file
export PATH="$HOME/.appcat/bin:$PATH"
```

然后重新加载配置：

Then reload the configuration:

```bash
source ~/.bashrc
# 或 / or
source ~/.bash_profile
```

#### Zsh用户 / For Zsh Users

编辑 `~/.zshrc`：

Edit `~/.zshrc`:

```bash
# 添加到文件末尾 / Add to end of file
export PATH="$HOME/.appcat/bin:$PATH"
```

然后重新加载：

Then reload:

```bash
source ~/.zshrc
```

#### 验证PATH配置 / Verify PATH Configuration

```bash
# 检查appcat是否在PATH中 / Check if appcat is in PATH
which appcat

# 应该显示 / Should show:
# /home/username/.appcat/bin/appcat

# 直接运行 / Run directly
appcat --version
```

### 方法3：创建别名 / Method 3: Create Alias

如果不想修改PATH，可以创建一个别名：

If you don't want to modify PATH, create an alias:

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc / Add to ~/.bashrc or ~/.zshrc
alias appcat="$HOME/.appcat/bin/appcat"

# 重新加载配置后使用 / Use after reloading config
appcat --version
```

### 方法4：创建符号链接 / Method 4: Create Symbolic Link

创建符号链接到系统PATH中的目录：

Create a symbolic link to a directory in system PATH:

```bash
# 创建符号链接到 /usr/local/bin / Create symlink to /usr/local/bin
sudo ln -s ~/.appcat/bin/appcat /usr/local/bin/appcat

# 或创建到用户本地bin目录 / Or create to user local bin
mkdir -p ~/bin
ln -s ~/.appcat/bin/appcat ~/bin/appcat
export PATH="$HOME/bin:$PATH"  # 添加到 ~/.bashrc

# 验证 / Verify
which appcat
appcat --version
```

---

## 常用AppCAT命令 / Common AppCAT Commands

### 基本评估 / Basic Assessment

```bash
# 分析当前项目 / Analyze current project
appcat analyze .

# 分析指定项目 / Analyze specific project
appcat analyze /path/to/your/java/project

# 指定输出目录 / Specify output directory
appcat analyze . --output-dir ./assessment-results
```

### 指定目标平台 / Specify Target Platforms

```bash
# Azure Kubernetes Service
appcat analyze . --target azure-aks

# Azure App Service
appcat analyze . --target azure-appservice

# Azure Container Apps
appcat analyze . --target azure-container-apps

# 多个目标 / Multiple targets
appcat analyze . \
  --target azure-aks \
  --target azure-appservice \
  --target azure-container-apps
```

### 指定分析模式 / Specify Analysis Mode

```bash
# 仅问题检测 / Issue detection only
appcat analyze . --mode issue-only

# 源码和技术分析 / Source code and technology analysis
appcat analyze . --mode source-only

# 完整分析（包括依赖） / Full analysis (including dependencies)
appcat analyze . --mode full
```

### 指定技术能力 / Specify Capabilities

```bash
# OpenJDK升级 / OpenJDK upgrade
appcat analyze . --capability openjdk17
appcat analyze . --capability openjdk21

# 容器化 / Containerization
appcat analyze . --capability containerization
```

### 组合使用 / Combined Usage

```bash
# 完整的评估命令示例 / Complete assessment command example
appcat analyze /path/to/spring-boot-app \
  --target azure-aks \
  --target azure-container-apps \
  --mode issue-only \
  --output-dir ./results
```

---

## 在脚本中使用 / Using in Scripts

你可以在自动化脚本中使用AppCAT：

You can use AppCAT in automation scripts:

### Bash脚本示例 / Bash Script Example

```bash
#!/bin/bash

# 设置AppCAT路径 / Set AppCAT path
APPCAT_BIN="$HOME/.appcat/bin/appcat"

# 检查AppCAT是否安装 / Check if AppCAT is installed
if [ ! -f "$APPCAT_BIN" ]; then
    echo "AppCAT not found at $APPCAT_BIN"
    echo "Please install AppCAT first"
    exit 1
fi

# 项目路径 / Project path
PROJECT_PATH="/path/to/your/project"
OUTPUT_DIR="./assessment-output"

# 运行评估 / Run assessment
echo "Running AppCAT assessment..."
$APPCAT_BIN analyze "$PROJECT_PATH" \
    --target azure-aks \
    --target azure-appservice \
    --mode issue-only \
    --output-dir "$OUTPUT_DIR"

# 检查结果 / Check results
if [ $? -eq 0 ]; then
    echo "Assessment completed successfully!"
    echo "Results saved to: $OUTPUT_DIR"
else
    echo "Assessment failed!"
    exit 1
fi
```

### Makefile示例 / Makefile Example

```makefile
# Makefile for AppCAT assessment

APPCAT := $(HOME)/.appcat/bin/appcat
PROJECT_DIR := .
OUTPUT_DIR := assessment-results

.PHONY: assess
assess:
	@echo "Running AppCAT assessment..."
	@$(APPCAT) analyze $(PROJECT_DIR) \
		--target azure-aks \
		--target azure-container-apps \
		--mode issue-only \
		--output-dir $(OUTPUT_DIR)
	@echo "Assessment complete! Check $(OUTPUT_DIR) for results"

.PHONY: clean
clean:
	@rm -rf $(OUTPUT_DIR)
	@echo "Cleaned assessment results"
```

使用：

Usage:

```bash
make assess
make clean
```

---

## CI/CD集成 / CI/CD Integration

### GitHub Actions示例 / GitHub Actions Example

```yaml
name: AppCAT Assessment

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  assess:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Install AppCAT
        run: |
          # 下载并安装AppCAT / Download and install AppCAT
          mkdir -p ~/.appcat/bin
          wget -O appcat.tar.gz https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz
          tar -xzf appcat.tar.gz -C ~/.appcat
          chmod +x ~/.appcat/bin/appcat
      
      - name: Run AppCAT Assessment
        run: |
          ~/.appcat/bin/appcat analyze . \
            --target azure-aks \
            --target azure-container-apps \
            --mode issue-only \
            --output-dir ./results
      
      - name: Upload Assessment Results
        uses: actions/upload-artifact@v4
        with:
          name: appcat-results
          path: results/
```

### Jenkins示例 / Jenkins Example

```groovy
pipeline {
    agent any
    
    environment {
        APPCAT_BIN = "${HOME}/.appcat/bin/appcat"
    }
    
    stages {
        stage('AppCAT Assessment') {
            steps {
                script {
                    sh """
                        ${APPCAT_BIN} analyze . \
                            --target azure-aks \
                            --mode issue-only \
                            --output-dir assessment-results
                    """
                }
            }
        }
        
        stage('Publish Results') {
            steps {
                publishHTML([
                    reportDir: 'assessment-results',
                    reportFiles: 'report.html',
                    reportName: 'AppCAT Assessment'
                ])
            }
        }
    }
}
```

---

## 配置文件使用 / Using Configuration Files

你可以创建配置文件来简化AppCAT使用：

You can create configuration files to simplify AppCAT usage:

### 配置文件示例 `appcat-config.yaml` / Config File Example

```yaml
# AppCAT配置文件 / AppCAT Configuration File

targets:
  - azure-aks
  - azure-appservice
  - azure-container-apps

mode: issue-only

output:
  directory: ./assessment-results
  format: json

# 可选：操作系统 / Optional: Operating System
os:
  - linux

# 可选：能力 / Optional: Capabilities
capabilities:
  - containerization
```

### 使用配置文件 / Using Config File

```bash
# 使用配置文件运行 / Run with config file
appcat analyze . --config appcat-config.yaml
```

---

## 重要提示 / Important Notes

### ✅ 可以做的 / What You CAN Do

1. **直接使用安装的AppCAT** / **Use installed AppCAT directly**
   - 使用完整路径 `~/.appcat/bin/appcat`
   - Use full path `~/.appcat/bin/appcat`

2. **添加到PATH** / **Add to PATH**
   - 更方便地使用 `appcat` 命令
   - Use `appcat` command more conveniently

3. **在脚本和自动化中使用** / **Use in scripts and automation**
   - Shell脚本 / Shell scripts
   - CI/CD管道 / CI/CD pipelines
   - Makefiles

4. **多次运行评估** / **Run assessments multiple times**
   - 对不同项目 / On different projects
   - 使用不同配置 / With different configurations

### ⚠️ 注意事项 / Cautions

1. **会话持久性** / **Session Persistence**
   - 在当前会话中可以使用
   - Can be used in current session
   - 新会话需要重新配置PATH（如果使用PATH方法）
   - New sessions need PATH reconfiguration (if using PATH method)

2. **权限** / **Permissions**
   - 确保 `~/.appcat/bin/appcat` 有执行权限
   - Ensure `~/.appcat/bin/appcat` has execute permission
   - 使用 `chmod +x ~/.appcat/bin/appcat` 如果需要
   - Use `chmod +x ~/.appcat/bin/appcat` if needed

3. **版本管理** / **Version Management**
   - MCP工具安装的是特定版本
   - MCP tool installs a specific version
   - 检查版本：`~/.appcat/bin/appcat --version`
   - Check version: `~/.appcat/bin/appcat --version`

---

## 快速参考 / Quick Reference

### 常用命令速查 / Common Commands Cheat Sheet

```bash
# 检查安装 / Check installation
ls ~/.appcat/bin/appcat

# 查看版本 / View version
~/.appcat/bin/appcat --version

# 基本评估 / Basic assessment
~/.appcat/bin/appcat analyze .

# 添加到PATH（临时）/ Add to PATH (temporary)
export PATH="$HOME/.appcat/bin:$PATH"

# 添加到PATH（永久）/ Add to PATH (permanent)
echo 'export PATH="$HOME/.appcat/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 创建别名 / Create alias
alias appcat="$HOME/.appcat/bin/appcat"

# Azure评估 / Azure assessment
~/.appcat/bin/appcat analyze . \
  --target azure-aks \
  --target azure-container-apps \
  --mode issue-only
```

---

## 故障排查 / Troubleshooting

### 问题1：找不到AppCAT / Problem 1: AppCAT Not Found

```bash
# 检查是否安装 / Check if installed
ls -la ~/.appcat/bin/appcat

# 如果不存在，重新安装 / If not exists, reinstall
# 使用MCP工具或手动下载
```

### 问题2：权限被拒绝 / Problem 2: Permission Denied

```bash
# 添加执行权限 / Add execute permission
chmod +x ~/.appcat/bin/appcat

# 验证权限 / Verify permissions
ls -la ~/.appcat/bin/appcat
# 应该显示 -rwxr-xr-x / Should show -rwxr-xr-x
```

### 问题3：PATH未生效 / Problem 3: PATH Not Working

```bash
# 检查PATH / Check PATH
echo $PATH

# 确保包含 ~/.appcat/bin / Ensure it contains ~/.appcat/bin

# 重新加载配置 / Reload configuration
source ~/.bashrc  # 或 ~/.zshrc
```

---

## 总结 / Summary

**关键要点 / Key Points:**

1. ✅ **可以使用** `~/.appcat` 路径中的AppCAT
   - **You CAN use** AppCAT from `~/.appcat` path

2. 🔧 **多种使用方式**：直接路径、PATH、别名、符号链接
   - **Multiple usage methods**: direct path, PATH, alias, symlink

3. 🚀 **适用于各种场景**：手动、脚本、CI/CD
   - **Works in various scenarios**: manual, scripts, CI/CD

4. 📦 **持久安装**：安装后可重复使用
   - **Persistent installation**: reusable after installation

---

**更多信息 / More Information:**

- [AppCAT官方文档](https://aka.ms/appcat-java)
- [Azure迁移指南](https://learn.microsoft.com/azure/developer/java/migration/)
- [云就绪性评估报告](../CLOUD_READINESS_ASSESSMENT.md)

---

**文档创建时间 / Document Created**: 2026-02-03  
**用途 / Purpose**: 指导用户如何使用MCP工具安装的AppCAT / Guide users on how to use AppCAT installed by MCP tools
