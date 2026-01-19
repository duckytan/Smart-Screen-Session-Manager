#!/bin/bash
# 清理重复screen会话脚本（备份）

echo "检查重复screen会话..."

# 获取所有会话
sessions=$(screen -ls | awk 'NR>1 {print $1}' | cut -d'.' -f2)

# 查找重复
for session in $(echo "$sessions" | sort | uniq -d); do
    echo "发现重复会话: $session"
    count=$(echo "$sessions" | grep -c "^$session")
    echo "数量: $count"
done
