#!/bin/bash
#
# build.sh - 编译 NRD-Sample 项目
#
# 功能:
#   1. 编译 Release 版本
#   2. 编译 Debug 版本
#   3. 支持自定义编译选项
#
# 使用方法:
#   ./build.sh              # 编译 Release 和 Debug 版本
#   ./build.sh release      # 仅编译 Release 版本
#   ./build.sh debug        # 仅编译 Debug 版本
#   ./build.sh clean        # 清理构建目录
#

set -e  # 遇到错误立即退出

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取 CPU 核心数用于并行编译
CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}NRD-Sample 编译脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否在项目根目录
if [ ! -f "CMakeLists.txt" ]; then
    echo -e "${RED}错误: 请在项目根目录下运行此脚本${NC}"
    exit 1
fi

# 检查构建目录是否存在
if [ ! -d "_Build" ]; then
    echo -e "${RED}错误: 构建目录不存在${NC}"
    echo -e "${YELLOW}请先运行 ./update.sh 来初始化项目${NC}"
    exit 1
fi

# 清理函数
clean_build() {
    echo -e "${YELLOW}清理构建目录...${NC}"
    rm -rf "_Build"
    rm -rf "_Bin"
    rm -rf "_Shaders"
    echo -e "${GREEN}✓ 清理完成${NC}"
    echo ""
    echo -e "运行 ${YELLOW}./update.sh${NC} 来重新初始化项目"
}

# 编译函数
build_config() {
    local config=$1
    local config_upper=$(echo "$config" | tr '[:lower:]' '[:upper:]')

    echo -e "${YELLOW}编译 ${config_upper} 版本...${NC}"
    echo -e "${BLUE}使用 ${CORES} 个并行任务${NC}"

    cd "_Build"
    cmake --build . --config "$config_upper" -j "$CORES"
    cd ..

    echo -e "${GREEN}✓ ${config_upper} 版本编译完成${NC}"
    echo ""
}

# 解析命令行参数
BUILD_RELEASE=true
BUILD_DEBUG=true

if [ $# -gt 0 ]; then
    case "$1" in
        release|Release|RELEASE)
            BUILD_DEBUG=false
            ;;
        debug|Debug|DEBUG)
            BUILD_RELEASE=false
            ;;
        clean|Clean|CLEAN)
            clean_build
            exit 0
            ;;
        help|--help|-h)
            echo "使用方法:"
            echo "  ./build.sh              # 编译 Release 和 Debug 版本"
            echo "  ./build.sh release      # 仅编译 Release 版本"
            echo "  ./build.sh debug        # 仅编译 Debug 版本"
            echo "  ./build.sh clean        # 清理构建目录"
            echo "  ./build.sh help         # 显示此帮助信息"
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知参数 '$1'${NC}"
            echo "运行 './build.sh help' 查看使用方法"
            exit 1
            ;;
    esac
fi

# 开始编译
echo -e "${BLUE}准备编译项目...${NC}"
echo ""

# 编译 Release 版本
if [ "$BUILD_RELEASE" = true ]; then
    build_config "Release"
fi

# 编译 Debug 版本
if [ "$BUILD_DEBUG" = true ]; then
    build_config "Debug"
fi

# 完成
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ 编译完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "可执行文件位置: ${YELLOW}_Bin/${NC}"
if [ "$BUILD_RELEASE" = true ]; then
    echo -e "  - Release 版本: ${YELLOW}_Bin/Release/${NC}"
fi
if [ "$BUILD_DEBUG" = true ]; then
    echo -e "  - Debug 版本: ${YELLOW}_Bin/Debug/${NC}"
fi
echo ""
echo -e "运行示例:"
echo -e "  ${YELLOW}cd _Bin/Release && ./NRDSample${NC}"
echo ""
