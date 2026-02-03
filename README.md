# Spring PetClinic Visits Service

独立的 Spring PetClinic Visits 微服务。

## 📋 项目信息

- **Group ID**: `org.springframework.samples.petclinic.visits`
- **Artifact ID**: `visits-service`
- **Version**: `3.4.1`
- **Java Version**: `17`
- **Spring Boot**: `3.4.1`
- **Spring Cloud**: `2024.0.0`

## 🚀 快速开始

### 前置要求

- JDK 17 或更高版本
- Maven 3.6+
- MySQL 8.0+ (可选，默认使用 HSQLDB)

### 构建项目

```bash
# 编译并打包
mvn clean package

# 跳过测试构建
mvn clean package -DskipTests
```

### 运行服务

```bash
# 使用 Maven 运行
mvn spring-boot:run

# 或者运行打包后的 JAR
java -jar target/visits-service-3.4.1.jar
```

服务默认运行在 **http://localhost:8081**

## 🔧 配置

### 数据库配置

#### 使用 HSQLDB (默认)

无需额外配置，应用会自动使用内存数据库。

#### 使用 MySQL

在 `src/main/resources/application.yml` 或环境变量中配置：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/petclinic?useSSL=false
    username: root
    password: your_password
  jpa:
    hibernate:
      ddl-auto: update
```

或使用环境变量：

```bash
export SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/petclinic
export SPRING_DATASOURCE_USERNAME=root
export SPRING_DATASOURCE_PASSWORD=your_password
```

### Azure MySQL 配置

如果使用 Azure MySQL，已集成 `spring-cloud-azure-starter-jdbc-mysql`：

```yaml
spring:
  cloud:
    azure:
      credential:
        managed-identity-enabled: true
  datasource:
    url: jdbc:mysql://your-server.mysql.database.azure.com:3306/petclinic
```

## 📦 依赖说明

主要依赖：

- **Spring Boot Starter Web**: REST API 支持
- **Spring Boot Starter Data JPA**: 数据持久化
- **Spring Boot Starter Actuator**: 健康检查和监控
- **Spring Cloud Config**: 配置管理
- **Spring Cloud Netflix Eureka**: 服务注册与发现
- **Azure MySQL Connector**: Azure MySQL 支持
- **Lombok**: 简化代码
- **Micrometer Prometheus**: 指标监控
- **Chaos Monkey**: 混沌工程支持

## 🧪 测试

```bash
# 运行所有测试
mvn test

# 运行指定测试
mvn test -Dtest=VisitsControllerTest
```

## 📊 监控端点

应用启用了 Spring Boot Actuator，可以访问以下端点：

- **健康检查**: http://localhost:8081/actuator/health
- **应用信息**: http://localhost:8081/actuator/info
- **指标数据**: http://localhost:8081/actuator/prometheus
- **所有端点**: http://localhost:8081/actuator

## 🐳 Docker 支持

```bash
# 构建 Docker 镜像
docker build -t visits-service:latest .

# 运行容器
docker run -p 8081:8081 visits-service:latest
```

## 🔗 API 端点

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/visits` | 获取所有就诊记录 |
| GET | `/visits/{id}` | 获取指定就诊记录 |
| POST | `/visits` | 创建新的就诊记录 |
| GET | `/pets/{petId}/visits` | 获取指定宠物的就诊记录 |

## 🛠️ 开发

### IDE 配置

#### IntelliJ IDEA

1. `File` → `Open` → 选择项目根目录
2. 等待 Maven 导入完成
3. 确保 SDK 设置为 Java 17
4. 运行 `VisitsServiceApplication` 主类

#### VS Code

1. 安装 Java Extension Pack
2. 打开项目文件夹
3. 使用 Spring Boot Dashboard 运行应用

### 代码风格

项目使用 Lombok 简化代码，确保 IDE 安装了 Lombok 插件。

## 📊 Azure 迁移评估

本项目包含 Azure 应用现代化评估工具和文档：

- **[QUICK_ANSWER.md](QUICK_ANSWER.md)** - 快速解答
  - aka.ms 下载是否可行？
  - 为什么无法下载？
  - 如何解决？
  
- **[APPMOD_ASSESSMENT.md](APPMOD_ASSESSMENT.md)** - Azure 迁移评估指南
  - 自动化评估流程
  - 当前评估结果摘要
  - 手动执行说明
  
- **[NETWORK_DIAGNOSTICS.md](NETWORK_DIAGNOSTICS.md)** - 网络诊断详解
  - 下载失败的详细技术分析
  - DNS 解析问题诊断
  - 沙箱环境限制说明
  - 问题排查命令
  - 多个 URL 测试结果对比

- **[run-appmod-assess.sh](run-appmod-assess.sh)** - 自动化评估脚本
  - 一键运行评估
  - 自动降级到现有报告
  - 完善的错误处理

运行评估：
```bash
./run-appmod-assess.sh
```

## 📝 许可证

本项目基于原 Spring PetClinic 项目，遵循 Apache License 2.0。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

- **原项目**: https://github.com/spring-petclinic/spring-petclinic-microservices
- **当前仓库**: https://github.com/zhoufenqin/spring-petclinic-microservices-visits-service
