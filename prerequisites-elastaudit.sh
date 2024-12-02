#!/bin/bash

# Prerequisite Installation Script for Elasticsearch Metrics Collector

# Color codes for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    echo -e "${GREEN}[✓] $1${NC}"
}

error_message() {
    echo -e "${RED}[✗] $1${NC}"
}

warning_message() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Check and install Python
check_python() {
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        log_message "Python 3 is installed (Version: $PYTHON_VERSION)"

        # Check Python version
        if printf '%s\n' "3.7" "$PYTHON_VERSION" | sort -V -C; then
            log_message "Python version meets minimum requirements"
        else
            error_message "Python version is too low. Upgrade recommended."
            return 1
        fi
    else
        error_message "Python 3 is not installed"
        return 1
    fi
}

# Install Python if not present
install_python() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Ubuntu/Debian
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv
        # CentOS/RHEL
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3 python3-pip python3-venv
        else
            error_message "Unsupported Linux distribution"
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install python
    else
        error_message "Unsupported operating system"
        return 1
    fi
}

# Create virtual environment
setup_virtual_environment() {
    local PROJECT_DIR="$1"

    # Create project directory if it doesn't exist
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR" || exit

    # Create virtual environment
    python3 -m venv elastic_metrics_env

    # Activate virtual environment
    source elastic_metrics_env/bin/activate

    log_message "Virtual environment created in $PROJECT_DIR/elastic_metrics_env"
}

# Install Python dependencies
install_dependencies() {
    # Ensure virtual environment is activated
    pip install --upgrade pip

    # Install required libraries
    pip install elasticsearch pandas

    # Verify installations
    pip list | grep -E "elasticsearch|pandas"

    log_message "Dependencies installed successfully"
}

# Main installation script
main() {
    echo -e "${GREEN}Elasticsearch Metrics Collector - Prerequisites Installer${NC}"

    # Check project directory (default: current user's home)
    PROJECT_DIR="${HOME}/elasticsearch-metrics"

    # Check Python
    if ! check_python; then
        warning_message "Python not found or version insufficient. Attempting installation..."
        install_python
    fi

    # Setup virtual environment
    setup_virtual_environment "$PROJECT_DIR"

    # Install dependencies
    install_dependencies

    # Provide next steps
    echo -e "\n${YELLOW}Next Steps:${NC}"
    echo -e "1. Activate virtual environment: source ${PROJECT_DIR}/elastic_metrics_env/bin/activate"
    echo -e "2. Run your Elasticsearch metrics collection script"
    echo -e "3. Deactivate virtual environment when done: deactivate"
}


main
