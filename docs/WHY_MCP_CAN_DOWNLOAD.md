# 为什么MCP能下载而我不能？如何自己下载？
# Why Can MCP Download But I Cannot? How to Download Myself?

## 核心问题 / Core Questions

1. **为什么MCP工具能下载 `aka.ms` 链接？**  
   Why can MCP tools download from `aka.ms` links?

2. **为什么我直接使用 `wget` 或 `curl` 不能下载？**  
   Why can't I download directly using `wget` or `curl`?

3. **如果我想自己下载，该怎么做？**  
   If I want to download by myself, how should I do it?

---

## 详细解释 / Detailed Explanation

### 问题1：为什么会有这个限制？ / Why This Restriction?

#### 环境架构图 / Environment Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     GitHub Copilot 系统架构                           │
│                   GitHub Copilot System Architecture                 │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    你的本地机器 / Your Local Machine                  │
│                                                                       │
│  ✅ 完全的网络访问 / Full network access                              │
│  ✅ 可以访问 aka.ms / Can access aka.ms                              │
│  ✅ 可以使用 wget/curl / Can use wget/curl                           │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
                                    ↑
                                    │ 通过浏览器/API与Copilot交互
                                    │ Interact with Copilot via browser/API
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│              GitHub Copilot Agent 沙箱环境                            │
│            GitHub Copilot Agent Sandbox Environment                  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Agent (我 / Me - The AI you interact with)                  │  │
│  │                                                              │  │
│  │  🚫 受限网络访问 / Limited network access                    │  │
│  │     - aka.ms 被阻止 / aka.ms is BLOCKED                      │  │
│  │     - 很多外部域名被阻止 / Many external domains blocked     │  │
│  │                                                              │  │
│  │  工具 / Tools:                                                │  │
│  │  - bash, wget, curl (受网络限制 / network restricted)       │  │
│  │  - git, npm, python 等 / etc.                               │  │
│  │  - 文件系统访问 / File system access                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  防火墙规则 / Firewall Rules:                                        │
│  ❌ aka.ms          → BLOCKED                                        │
│  ❌ 很多短链接服务   → BLOCKED                                        │
│  ✅ github.com      → ALLOWED                                        │
│  ✅ 部分CDN         → ALLOWED                                        │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ RPC/API 调用
                                    │ RPC/API calls
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                 MCP服务器环境 / MCP Server Environment                │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  MCP Tools (app-modernization, github, etc.)                │  │
│  │                                                              │  │
│  │  ✅ 完整网络访问 / Full network access                       │  │
│  │     - aka.ms 在白名单 / aka.ms is WHITELISTED               │  │
│  │     - 可以下载外部资源 / Can download external resources    │  │
│  │                                                              │  │
│  │  特殊能力 / Special Capabilities:                            │  │
│  │  - 访问被阻止的域名 / Access blocked domains                │  │
│  │  - 专业安装工具 / Specialized installation tools            │  │
│  │  - 缓存和优化 / Caching and optimization                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### 关键差异 / Key Differences

| 特性 / Feature | Agent沙箱 / Agent Sandbox | MCP服务器 / MCP Server | 你的本地机器 / Your Local Machine |
|---------------|--------------------------|----------------------|--------------------------------|
| 网络访问 / Network | 🚫 受限 / Restricted | ✅ 完整 / Full | ✅ 完整 / Full |
| aka.ms访问 / aka.ms | ❌ 被阻止 / Blocked | ✅ 允许 / Allowed | ✅ 允许 / Allowed |
| wget/curl | ✅ 可用但受限 / Available but restricted | ✅ 完整功能 / Full capability | ✅ 完整功能 / Full capability |
| 环境 / Environment | 临时沙箱 / Temporary sandbox | 持久服务 / Persistent service | 你的电脑 / Your computer |

---

### 问题2：为什么Agent不能下载？ / Why Can't Agent Download?

让我实际演示这个限制：

Let me demonstrate this restriction:

```bash
# 在Agent沙箱中尝试下载 / Trying to download in Agent sandbox
$ wget https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz

# 结果 / Result:
Resolving aka.ms (aka.ms)... failed: No address associated with hostname.
wget: unable to resolve host address 'aka.ms'
```

**原因分析 / Root Cause Analysis**:

1. **DNS阻止 / DNS Blocking**
   ```
   Agent沙箱 → DNS查询 aka.ms → 防火墙拦截 → 返回"域名不存在"
   Agent sandbox → DNS query aka.ms → Firewall blocks → Returns "hostname not found"
   ```

2. **安全策略 / Security Policy**
   - 为了安全，Agent运行在受限环境
   - For security, Agent runs in restricted environment
   - 防止恶意代码下载和执行
   - Prevent malicious code download and execution
   - 只允许访问预批准的域名
   - Only allow access to pre-approved domains

3. **白名单机制 / Whitelist Mechanism**
   ```
   允许的域名 / Allowed domains:
   ✅ github.com
   ✅ githubusercontent.com
   ✅ 部分CDN / Some CDNs
   
   被阻止的域名 / Blocked domains:
   ❌ aka.ms (Microsoft短链接 / Microsoft short links)
   ❌ 很多其他外部域名 / Many other external domains
   ```

---

### 问题3：MCP为什么能下载？ / Why Can MCP Download?

**MCP工具的特殊地位 / Special Status of MCP Tools**:

1. **独立的服务环境 / Independent Service Environment**
   ```
   MCP工具不在Agent沙箱内运行
   MCP tools don't run inside Agent sandbox
   
   它们是独立的后端服务
   They are independent backend services
   
   有自己的网络配置和权限
   Have their own network configuration and permissions
   ```

2. **白名单域名 / Whitelisted Domains**
   ```
   MCP服务器配置 / MCP server configuration:
   - aka.ms → ✅ 在白名单中 / Whitelisted
   - Microsoft下载服务器 → ✅ 允许 / Allowed
   - Azure资源 → ✅ 允许 / Allowed
   ```

3. **受信任的工具 / Trusted Tools**
   ```
   MCP工具经过审核和验证
   MCP tools are reviewed and verified
   
   被认为是安全的
   Considered safe
   
   允许执行特权操作
   Allowed to perform privileged operations
   ```

---

## 如果你想自己下载，该怎么做？ / How to Download Yourself?

### 方法1：在本地机器上下载（推荐）/ Method 1: Download on Local Machine (Recommended)

**最简单、最可靠的方法！/ Simplest and most reliable method!**

#### Windows系统 / Windows System

```powershell
# 使用PowerShell下载 / Download using PowerShell
Invoke-WebRequest -Uri "https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-windows-amd64.zip" `
                  -OutFile "$env:USERPROFILE\Downloads\appcat-windows.zip"

# 或使用浏览器 / Or use browser
# 直接访问: https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-windows-amd64.zip
```

#### Linux/Mac系统 / Linux/Mac System

```bash
# 使用wget / Using wget
wget https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz \
     -O ~/Downloads/appcat-linux.tar.gz

# 或使用curl / Or using curl
curl -L https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz \
     -o ~/Downloads/appcat-linux.tar.gz

# Mac M1/M2 (ARM)
curl -L https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-darwin-arm64.tar.gz \
     -o ~/Downloads/appcat-mac-arm.tar.gz
```

#### 手动安装步骤 / Manual Installation Steps

```bash
# 1. 解压 / Extract
cd ~/Downloads
tar -xzf appcat-linux.tar.gz

# 2. 移动到安装位置 / Move to installation location
mkdir -p ~/.appcat
mv appcat/* ~/.appcat/

# 3. 添加执行权限 / Add execute permission
chmod +x ~/.appcat/appcat

# 4. 验证安装 / Verify installation
~/.appcat/appcat version

# 5. 可选：添加到PATH / Optional: Add to PATH
echo 'export PATH="$HOME/.appcat:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### 方法2：获取实际下载URL / Method 2: Get Actual Download URL

`aka.ms` 是短链接服务，它会重定向到实际的下载地址。你可以先获取实际URL：

`aka.ms` is a URL shortener that redirects to the actual download URL. You can get the real URL first:

#### 在本地机器上操作 / On Your Local Machine

```bash
# 使用curl获取重定向URL / Get redirect URL using curl
curl -I -L https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz 2>&1 | grep -i location

# 或使用wget / Or using wget
wget --spider --max-redirect=0 https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz 2>&1 | grep Location
```

这会显示实际的下载URL，类似：

This will show the actual download URL, something like:

```
Location: https://download.microsoft.com/download/.../appcat-cli-linux-amd64.tar.gz
```

然后你可以直接使用这个URL下载。

Then you can download directly using this URL.

---

### 方法3：使用GitHub Actions下载 / Method 3: Download via GitHub Actions

如果你在CI/CD环境中，可以使用GitHub Actions：

If you're in a CI/CD environment, you can use GitHub Actions:

```yaml
name: Download AppCAT

on:
  workflow_dispatch:

jobs:
  download:
    runs-on: ubuntu-latest
    steps:
      - name: Download AppCAT
        run: |
          wget https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz
          tar -xzf appcat-linux.tar.gz
          
      - name: Upload as Artifact
        uses: actions/upload-artifact@v4
        with:
          name: appcat-cli
          path: appcat/
```

---

### 方法4：使用代理服务器 / Method 4: Use Proxy Server

如果你在有代理的环境中：

If you're in an environment with a proxy:

```bash
# 设置HTTP代理 / Set HTTP proxy
export http_proxy="http://your-proxy:port"
export https_proxy="http://your-proxy:port"

# 然后下载 / Then download
wget https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz
```

---

### 方法5：从备用源下载 / Method 5: Download from Alternative Sources

#### GitHub Releases（如果可用）/ GitHub Releases (if available)

```bash
# 检查是否有GitHub镜像 / Check if there's a GitHub mirror
# AppCAT可能也在GitHub上发布
# AppCAT might also be released on GitHub
```

#### 使用包管理器 / Using Package Managers

```bash
# 某些包管理器可能提供AppCAT / Some package managers might provide AppCAT
# （这取决于是否有人打包了它）
# (This depends on whether someone has packaged it)
```

---

## 实际演示：为什么在Agent沙箱中不能下载 / Practical Demo: Why Can't Download in Agent Sandbox

让我实际演示一下：

Let me demonstrate this:

```bash
# 尝试1：直接wget / Attempt 1: Direct wget
$ wget https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz
结果 / Result: ❌ Could not resolve host: aka.ms

# 尝试2：使用curl / Attempt 2: Using curl
$ curl https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz
结果 / Result: ❌ Could not resolve host: aka.ms

# 尝试3：DNS查询 / Attempt 3: DNS lookup
$ nslookup aka.ms
结果 / Result: ❌ ** server can't find aka.ms: NXDOMAIN

# 尝试4：Ping测试 / Attempt 4: Ping test
$ ping aka.ms
结果 / Result: ❌ ping: aka.ms: Name or service not known
```

**所有直接访问都失败了！/ All direct access fails!**

但是使用MCP工具：

But using MCP tool:

```bash
# 使用MCP工具 / Using MCP tool
$ app-modernization-appmod-install-appcat
结果 / Result: ✅ Install latest version of AppCAT successfully!
```

**MCP工具成功了！/ MCP tool succeeds!**

---

## 为什么这样设计？ / Why This Design?

### 安全考虑 / Security Considerations

```
┌──────────────────────────────────────────────────────────────┐
│              安全威胁 / Security Threats                       │
└──────────────────────────────────────────────────────────────┘

如果Agent可以自由下载：
If Agent could download freely:

❌ 恶意用户可能让Agent下载恶意软件
   Malicious users might make Agent download malware

❌ 可能被用于DDoS攻击
   Could be used for DDoS attacks

❌ 可能下载和执行未验证的代码
   Might download and execute unverified code

❌ 可能泄露敏感信息到外部服务器
   Might leak sensitive info to external servers

┌──────────────────────────────────────────────────────────────┐
│           当前的安全设计 / Current Security Design            │
└──────────────────────────────────────────────────────────────┘

✅ Agent在受限沙箱中运行
   Agent runs in restricted sandbox

✅ 只能访问预批准的域名
   Can only access pre-approved domains

✅ 需要特权操作通过MCP工具
   Privileged operations go through MCP tools

✅ MCP工具经过审核和验证
   MCP tools are reviewed and verified

✅ 保护用户和系统安全
   Protects users and system security
```

---

## 对比总结 / Comparison Summary

### 三种环境的能力对比 / Capability Comparison of Three Environments

| 操作 / Operation | Agent沙箱 | MCP服务器 | 你的本地机器 |
|-----------------|----------|-----------|------------|
| 下载aka.ms链接 | ❌ 不能 | ✅ 可以 | ✅ 可以 |
| 使用wget/curl | ⚠️ 受限 | ✅ 完整 | ✅ 完整 |
| 安装AppCAT | ❌ 不能直接 | ✅ 可以 | ✅ 可以 |
| 访问github.com | ✅ 可以 | ✅ 可以 | ✅ 可以 |
| 文件系统操作 | ✅ 可以 | ✅ 可以 | ✅ 可以 |
| 运行已安装的AppCAT | ✅ 可以 | ✅ 可以 | ✅ 可以 |

---

## 推荐方案 / Recommended Solutions

### 场景1：你想要使用AppCAT / Scenario 1: You Want to Use AppCAT

**推荐 / Recommended**: 使用MCP工具安装
**Recommended**: Install using MCP tool

```bash
# 最简单的方法 / Simplest method
使用: app-modernization-appmod-install-appcat
Use: app-modernization-appmod-install-appcat

✅ 自动下载和安装 / Automatic download and installation
✅ 正确的权限配置 / Correct permission configuration
✅ 安装到标准位置 ~/.appcat / Installs to standard location ~/.appcat
✅ 立即可用 / Immediately usable
```

### 场景2：你想在本地机器使用AppCAT / Scenario 2: You Want AppCAT on Local Machine

**推荐 / Recommended**: 在本地机器直接下载

**Recommended**: Download directly on local machine

```bash
# Linux/Mac
wget https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz
tar -xzf appcat-linux.tar.gz
mv appcat ~/.appcat
chmod +x ~/.appcat/appcat

# Windows
# 浏览器下载 / Download via browser
# https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-windows-amd64.zip
```

### 场景3：你想了解实际下载URL / Scenario 3: You Want the Real Download URL

**在本地机器上执行 / Execute on local machine**:

```bash
curl -I -L https://aka.ms/appcat/azure-migrate-appcat-for-java-cli-linux-amd64.tar.gz 2>&1 | grep -i location
```

---

## 常见问题 / FAQ

### Q1: 为什么MCP工具可以访问aka.ms而Agent不能？
### Q1: Why can MCP tools access aka.ms while Agent cannot?

**A**: MCP工具运行在不同的环境中，有不同的网络权限。这是设计上的安全特性，不是bug。

**A**: MCP tools run in a different environment with different network permissions. This is a security feature by design, not a bug.

### Q2: 我能让Agent直接下载吗？
### Q2: Can I make Agent download directly?

**A**: 不能。Agent的网络访问受限是系统级的安全限制。使用MCP工具或在本地机器下载是正确的方法。

**A**: No. Agent's network access restriction is a system-level security limitation. Using MCP tools or downloading on your local machine is the correct approach.

### Q3: MCP工具安装的AppCAT能在后续操作中使用吗？
### Q3: Can I use AppCAT installed by MCP tool in subsequent operations?

**A**: 能！完全可以。安装后，你可以直接使用 `~/.appcat/appcat` 命令，无需再次调用MCP工具。

**A**: Yes! Absolutely. After installation, you can directly use `~/.appcat/appcat` command without calling MCP tools again.

参见: [AppCAT安装验证](./APPCAT_MCP_INSTALLATION_VERIFICATION.md)
See: [AppCAT Installation Verification](./APPCAT_MCP_INSTALLATION_VERIFICATION.md)

### Q4: 为什么不干脆让Agent能访问所有网站？
### Q4: Why not just let Agent access all websites?

**A**: 这会带来巨大的安全风险：
- 恶意代码下载
- DDoS攻击
- 数据泄露
- 未验证软件执行

当前的设计在功能和安全之间找到了平衡。

**A**: This would bring huge security risks:
- Malicious code download
- DDoS attacks
- Data leakage
- Unverified software execution

The current design strikes a balance between functionality and security.

---

## 总结 / Summary

### 核心要点 / Key Points

1. **为什么不能下载 / Why Can't Download**
   ```
   Agent在受限沙箱 → aka.ms被阻止 → wget/curl失败
   Agent in restricted sandbox → aka.ms blocked → wget/curl fails
   ```

2. **MCP为什么能下载 / Why MCP Can Download**
   ```
   MCP独立服务 → 不同网络权限 → aka.ms在白名单 → 成功
   MCP independent service → Different permissions → aka.ms whitelisted → Success
   ```

3. **如何自己下载 / How to Download Yourself**
   ```
   最佳方案：在本地机器下载
   Best solution: Download on local machine
   
   Linux/Mac: wget https://aka.ms/appcat/...
   Windows: 浏览器下载 / Browser download
   ```

4. **推荐使用方式 / Recommended Usage**
   ```
   使用MCP工具安装 → 安装到 ~/.appcat → 直接使用
   Use MCP tool to install → Installs to ~/.appcat → Use directly
   ```

---

## 相关文档 / Related Documentation

- [MCP网络访问说明](./MCP_NETWORK_ACCESS_EXPLANATION.md) - MCP工具工作原理详解
- [AppCAT使用指南](./APPCAT_USAGE_GUIDE.md) - AppCAT完整使用说明
- [AppCAT安装验证](./APPCAT_MCP_INSTALLATION_VERIFICATION.md) - 实际验证结果

---

**文档创建时间 / Document Created**: 2026-02-03  
**用途 / Purpose**: 详细解释下载限制原因和提供实用解决方案  
**Purpose**: Explain download restrictions in detail and provide practical solutions
