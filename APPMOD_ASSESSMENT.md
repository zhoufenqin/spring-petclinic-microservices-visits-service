# AppMod Assessment

This document describes the AppMod assessment process for the Spring PetClinic Visits Service.

## Overview

The AppMod (Application Modernization) assessment tool evaluates applications for migration to Azure services. It identifies potential issues, migration blockers, and provides recommendations for successful cloud migration.

## Assessment Execution

### Automated Script

A bash script `run-appmod-assess.sh` has been created to automate the assessment process:

```bash
./run-appmod-assess.sh
```

### What the Script Does

1. **Download AppMod Tool**: Attempts to download the latest appmod tool from:
   ```
   https://aka.ms/ghcp-appmod-agent/private-preview/appmod_linux-x64.tar.gz
   ```
   
   > **Note**: This URL points to a private preview version of the appmod tool. Access may require 
   > special permissions or credentials. If you encounter access issues, please contact your 
   > Azure representative or check the [GitHub Copilot App Modernization](https://aka.ms/ghcp-appmod) 
   > documentation for the latest download instructions.

2. **Extract Tool**: Extracts the downloaded tarball to access the `appmod` binary

3. **Run Assessment**: Executes `appmod assess` to analyze the project

4. **Fallback Strategy**: If download fails (e.g., network restrictions), the script:
   - Checks for existing assessment report at `.github/workflows/report.json`
   - Copies it to `.github/appmod/appcat/result/report.json`
   - Generates a summary using the PowerShell script at `.appmod-kit/scripts/powershell/assess.ps1`

## Assessment Results

The assessment generates the following files in `.github/appmod/appcat/result/`:

- **report.json**: Full detailed assessment report in JSON format
- **summary.md**: Human-readable summary of key findings

### Current Assessment Summary

**Target Azure Services**: 
- Azure Kubernetes Service
- Azure Container Apps
- Azure App Service

**Project**: visits-service
- **JDK Version**: 17
- **Frameworks**: Spring Boot, Spring Cloud, Spring
- **Languages**: Java, JavaScript
- **Build Tools**: Maven

**Key Findings**:
- **Mandatory Issues**: 6 issues (525 total locations)
  - Use of unsecured network protocols
  - AWS credential configuration
  - Google Container Registry usage
  - Missing Dockerfile
  - Caching configuration
  - JDBC-ODBC Bridge usage

- **Potential Issues**: 18 issues (28 total locations)
  - Database compatibility (MariaDB, SQL, Oracle, PostgreSQL, MongoDB)
  - Service discovery (Eureka Client)
  - Service bindings
  - Configuration management (Spring Cloud Config)

- **Optional Issues**: 4 issues (3074 total locations)
  - Hardcoded URLs
  - Localhost usage
  - Message queue dependencies
  - Database reliability considerations

## Manual Assessment

If you need to run the assessment manually:

### Prerequisites

- PowerShell Core (pwsh)
- Access to aka.ms for downloading the appmod tool (or manual download)

### Steps

1. Download and extract appmod tool:
   ```bash
   curl -L -o appmod_linux-x64.tar.gz https://aka.ms/ghcp-appmod-agent/private-preview/appmod_linux-x64.tar.gz
   tar -xzf appmod_linux-x64.tar.gz
   ```

2. Run the assessment:
   ```bash
   ./appmod assess
   ```

3. Generate summary (if using existing report):
   ```bash
   pwsh .appmod-kit/scripts/powershell/assess.ps1 -OutputPath .github/appmod/appcat/result -IssueSource other
   ```

## Next Steps

For comprehensive migration guidance and best practices, visit:
- [GitHub Copilot App Modernization](https://aka.ms/ghcp-appmod)

## Troubleshooting

### Network Access Issues

If you cannot access aka.ms due to network restrictions:
1. Download the tool manually from a machine with internet access
2. Transfer the tarball to this environment
3. Run the extraction and assessment steps manually

### PowerShell Not Available

If PowerShell is not installed:
```bash
# Install PowerShell on Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y powershell
```

### Viewing Assessment Results

You can view the assessment results directly:
```bash
# View full report
cat .github/appmod/appcat/result/report.json | jq

# View summary
cat .github/appmod/appcat/result/summary.md
```
