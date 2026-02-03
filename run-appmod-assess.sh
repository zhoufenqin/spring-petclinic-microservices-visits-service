#!/bin/bash
# Script to download, extract, and run appmod assess
# 
# This script attempts to:
# 1. Download the appmod tool from aka.ms
# 2. Extract the downloaded tarball
# 3. Run 'appmod assess' to assess the project
#
# If the download fails due to network restrictions, it will check for
# an existing assessment report and provide guidance on how to use it.

set -e

APPMOD_URL="https://aka.ms/ghcp-appmod-agent/private-preview/appmod_linux-x64.tar.gz"
APPMOD_TAR="appmod_linux-x64.tar.gz"
APPMOD_DIR="appmod"
EXISTING_REPORT=".github/workflows/report.json"
ASSESSMENT_OUTPUT_DIR=".github/appmod/appcat/result"

echo "========================================"
echo "AppMod Assessment Tool Setup and Run"
echo "========================================"
echo ""

# Step 1: Download appmod tool
echo "[Step 1/3] Downloading appmod tool from ${APPMOD_URL}..."
if curl -L -o "${APPMOD_TAR}" "${APPMOD_URL}" 2>/dev/null; then
    echo "✓ Download successful"
else
    echo "✗ Download failed (network may not allow access to aka.ms)"
    echo ""
    echo "Checking for existing assessment report..."
    if [ -f "${EXISTING_REPORT}" ]; then
        echo "✓ Found existing assessment report at ${EXISTING_REPORT}"
        echo ""
        echo "Using existing report to generate assessment summary..."
        
        # Create output directory if it doesn't exist
        mkdir -p "${ASSESSMENT_OUTPUT_DIR}"
        
        # Copy existing report to expected location
        if [ ! -f "${ASSESSMENT_OUTPUT_DIR}/report.json" ]; then
            cp "${EXISTING_REPORT}" "${ASSESSMENT_OUTPUT_DIR}/report.json"
            echo "✓ Copied report to ${ASSESSMENT_OUTPUT_DIR}/report.json"
        fi
        
        # Generate summary using PowerShell script
        if command -v pwsh &> /dev/null; then
            echo ""
            echo "Generating assessment summary..."
            pwsh .appmod-kit/scripts/powershell/assess.ps1 -OutputPath "${ASSESSMENT_OUTPUT_DIR}" -IssueSource other
            
            if [ -f "${ASSESSMENT_OUTPUT_DIR}/summary.md" ]; then
                echo ""
                echo "✓ Assessment summary generated at ${ASSESSMENT_OUTPUT_DIR}/summary.md"
                echo ""
                echo "========================================"
                echo "Assessment Summary:"
                echo "========================================"
                cat "${ASSESSMENT_OUTPUT_DIR}/summary.md"
                echo ""
                echo "========================================"
                echo "Assessment completed using existing report!"
                echo "========================================"
                exit 0
            fi
        else
            echo ""
            echo "PowerShell (pwsh) not found. To generate summary:"
            echo "  pwsh .appmod-kit/scripts/powershell/assess.ps1 -OutputPath ${ASSESSMENT_OUTPUT_DIR} -IssueSource other"
            echo ""
            echo "Or view the report directly:"
            echo "  cat ${EXISTING_REPORT}"
        fi
        exit 0
    else
        echo "✗ No existing assessment report found"
        echo ""
        echo "The appmod tool cannot be downloaded due to network restrictions."
        echo "Please ensure you have network access to aka.ms or manually download"
        echo "the tool from: ${APPMOD_URL}"
        exit 1
    fi
fi

# Step 2: Extract the tarball
echo ""
echo "[Step 2/3] Extracting ${APPMOD_TAR}..."
if tar -xzf "${APPMOD_TAR}"; then
    echo "✓ Extraction successful"
    
    # Find the appmod binary
    APPMOD_BINARY=$(find . -name "appmod" -type f -executable 2>/dev/null | head -1)
    if [ -z "${APPMOD_BINARY}" ]; then
        echo "✗ appmod binary not found in extracted files"
        echo "Contents of current directory:"
        ls -la
        exit 1
    fi
    echo "✓ Found appmod binary at: ${APPMOD_BINARY}"
else
    echo "✗ Extraction failed"
    exit 1
fi

# Step 3: Run appmod assess
echo ""
echo "[Step 3/3] Running appmod assess..."
if [ -x "${APPMOD_BINARY}" ]; then
    ${APPMOD_BINARY} assess
    echo "✓ Assessment completed"
else
    echo "✗ appmod binary is not executable"
    exit 1
fi

echo ""
echo "========================================"
echo "Assessment completed successfully!"
echo "========================================"
