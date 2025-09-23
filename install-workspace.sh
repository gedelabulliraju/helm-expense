#!/bin/bash
set -e  # Exit immediately if a command fails

# Ensure PATH includes common bin directories
export PATH=$PATH:/usr/bin:/usr/local/bin:/home/ec2-user/.local/bin

echo "============================================"
echo "🌟 Kubernetes Workspace Setup Script (EC2 Friendly)"
echo "============================================"

# ============================
# Function to check command
# ============================
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================
# Install kubectl
# ============================
if command_exists kubectl; then
    echo "✅ kubectl is already installed:"
    kubectl version --client
else
    echo "Installing kubectl..."
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.3/2025-08-03/bin/linux/amd64/kubectl
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.3/2025-08-03/bin/linux/amd64/kubectl.sha256
    sha256sum -c kubectl.sha256
    chmod +x kubectl
    sudo mv kubectl /usr/bin/kubectl
    echo "✅ kubectl installed successfully."
fi

# ============================
# Install eksctl
# ============================
if command_exists eksctl; then
    echo "✅ eksctl is already installed: $(eksctl version)"
else
    echo "Installing eksctl..."
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    sudo mv /tmp/eksctl /usr/bin/eksctl
    echo "✅ eksctl installed successfully."
fi

# ============================
# Install Helm
# ============================
if command_exists helm; then
    echo "✅ helm is already installed:"
    helm version
else
    echo "Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod +x get_helm.sh
    ./get_helm.sh
    if [ -f /usr/local/bin/helm ]; then
        sudo mv /usr/local/bin/helm /usr/bin/helm
    fi
    echo "✅ helm installed successfully."
fi


# ==========================
# Install k9s
# ==========================
    echo "Installing k9s..."
    
    # Download and install using webinstall.dev
    curl -sSL https://webinstall.dev/k9s | bash

    # Verify installation
    if command_exists k9s; then
        echo "✅ k9s installed successfully: $(k9s version | head -n1)"
    else
        echo "❌ k9s installation failed"
        exit 1
    fi
fi

# ===========================
# Usage tip
# ===========================
echo "You can now run 'k9s' as normal user. Do NOT use 'sudo k9s'."
# ============================
# Final Verification
# ============================
echo "============================================"
echo "🌟 Verifying installations..."
kubectl version --client
eksctl version
helm version
k9s version
echo "🎉 Workspace setup complete!"
echo "============================================"