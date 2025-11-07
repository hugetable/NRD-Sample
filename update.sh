#!/bin/bash
#
# update.sh - 初始化和更新 NRD-Sample 项目依赖
#
# 功能:
#   1. 更新 git 子模块
#   2. 配置 CMake 构建系统
#   3. 准备项目构建环境
#

set -e  # 遇到错误立即退出

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}NRD-Sample 依赖更新脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否在项目根目录
if [ ! -f "CMakeLists.txt" ]; then
    echo -e "${RED}错误: 请在项目根目录下运行此脚本${NC}"
    exit 1
fi

# 步骤 1: 更新 git 子模块
echo -e "${YELLOW}[1/3] 更新 git 子模块...${NC}"
git submodule update --init --recursive
echo -e "${GREEN}✓ Git 子模块更新完成${NC}"
echo ""

# 步骤 2: 创建构建目录
echo -e "${YELLOW}[2/3] 创建构建目录...${NC}"
mkdir -p "_Build"
echo -e "${GREEN}✓ 构建目录创建完成${NC}"
echo ""

# 步骤 3: 配置 CMake
echo -e "${YELLOW}[3/3] 配置 CMake 构建系统...${NC}"
cd "_Build"

# 传递所有命令行参数给 CMake
cmake .. "$@"

cd ..

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ 更新完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "下一步: 运行 ${YELLOW}./build.sh${NC} 来编译项目"
echo ""
