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

# Create a temporary file for download errors and ensure it's cleaned up
DOWNLOAD_ERROR=$(mktemp)
trap 'rm -f "${DOWNLOAD_ERROR}"' EXIT

echo "========================================"
echo "AppMod Assessment Tool Setup and Run"
echo "========================================"
echo ""

# Step 1: Download appmod tool
echo "[Step 1/3] Downloading appmod tool from ${APPMOD_URL}..."
if curl -L -o "${APPMOD_TAR}" "${APPMOD_URL}" 2>"${DOWNLOAD_ERROR}"; then
    echo "✓ Download successful"
else
    DOWNLOAD_EXIT_CODE=$?
    echo "✗ Download failed (exit code: ${DOWNLOAD_EXIT_CODE})"
    
    # Display error details if available
    if [ -s "${DOWNLOAD_ERROR}" ]; then
        echo "Error details:"
        cat "${DOWNLOAD_ERROR}"
    fi
    echo ""
    echo "Common reasons for download failure:"
    echo "  - Network restrictions blocking access to aka.ms"
    echo "  - Authentication required for private-preview version"
    echo "  - Network connectivity issues"
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
        ASSESS_SCRIPT=".appmod-kit/scripts/powershell/assess.ps1"
        if [ ! -f "${ASSESS_SCRIPT}" ]; then
            echo "✗ PowerShell assessment script not found at ${ASSESS_SCRIPT}"
            echo "Cannot generate summary without the assessment script."
            exit 1
        fi
        
        if command -v pwsh &> /dev/null; then
            echo ""
            echo "Generating assessment summary..."
            pwsh "${ASSESS_SCRIPT}" -OutputPath "${ASSESSMENT_OUTPUT_DIR}" -IssueSource other
            
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
# Create extraction directory
mkdir -p "${APPMOD_DIR}"
if tar -xzf "${APPMOD_TAR}" -C "${APPMOD_DIR}"; then
    echo "✓ Extraction successful"
    
    # Find the appmod binary in the extraction directory
    APPMOD_BINARIES=$(find "${APPMOD_DIR}" -name "appmod" -type f 2>/dev/null)
    BINARY_COUNT=$(echo "${APPMOD_BINARIES}" | grep -c "appmod" || true)
    
    if [ "${BINARY_COUNT}" -eq 0 ]; then
        echo "✗ appmod binary not found in extracted files"
        echo "Contents of extraction directory:"
        ls -laR "${APPMOD_DIR}"
        exit 1
    elif [ "${BINARY_COUNT}" -gt 1 ]; then
        echo "⚠ Warning: Multiple appmod binaries found, using the first one:"
        echo "${APPMOD_BINARIES}"
        APPMOD_BINARY=$(echo "${APPMOD_BINARIES}" | head -1)
    else
        APPMOD_BINARY="${APPMOD_BINARIES}"
    fi
    
    # Make it executable if it's not already
    chmod +x "${APPMOD_BINARY}"
    echo "✓ Found appmod binary at: ${APPMOD_BINARY}"
else
    echo "✗ Extraction failed"
    exit 1
fi

# Step 3: Run appmod assess
echo ""
echo "[Step 3/3] Running appmod assess..."
if [ -x "${APPMOD_BINARY}" ]; then
    echo "Executing: ${APPMOD_BINARY} assess"
    if ${APPMOD_BINARY} assess; then
        echo "✓ Assessment completed successfully"
    else
        ASSESS_EXIT_CODE=$?
        echo "✗ Assessment failed (exit code: ${ASSESS_EXIT_CODE})"
        echo ""
        echo "Please check:"
        echo "  - The appmod tool version is compatible with this project"
        echo "  - Required dependencies are installed"
        echo "  - The project structure is valid"
        exit 1
    fi
else
    echo "✗ appmod binary is not executable at ${APPMOD_BINARY}"
    exit 1
fi

echo ""
echo "========================================"
echo "Assessment completed successfully!"
echo "========================================"
