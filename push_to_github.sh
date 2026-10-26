#!/bin/bash
# 一键推送 langya-503 到 GitHub
# 用法: GITHUB_USER=<你的用户名> GITHUB_TOKEN=<你的PAT> ./push_to_github.sh [仓库名]
# PAT 需要勾选 repo 权限（含 workflow 不需要）；在 https://github.com/settings/tokens 生成
set -euo pipefail

REPO="${1:-langya-503}"
: "${GITHUB_USER:?请设置 GITHUB_USER=你的GitHub用户名}"
: "${GITHUB_TOKEN:?请设置 GITHUB_TOKEN=你的Personal Access Token}"

cd "$(dirname "$0")"

echo ">>> 目标: https://github.com/${GITHUB_USER}/${REPO}"

# 1. 创建远端空仓库（已存在则忽略报错）
echo ">>> [1/3] 创建远端仓库 ..."
curl -sS -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/user/repos" \
  -d "$(printf '{"name":"%s","description":"%s","private":false,"auto_init":false}' \
      "${REPO}" \
      "琅琊榜·外传：一盏503 —— Canvas 三集连续短剧（植入吉普号503普洱茶）")" \
  | grep -oE '"full_name":"[^"]+"|"message":"[^"]+"' | head -3 || true

# 2. 关联远端（用 token 内联，避免交互输入）
echo ">>> [2/3] 关联远端并推送 ..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO}.git"
git branch -M main
git push -u origin main

# 3. 移除含 token 的 remote，改用干净地址
git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO}.git"

echo ">>> [3/3] 完成"
echo "仓库:   https://github.com/${GITHUB_USER}/${REPO}"
echo "第1集:  https://github.com/${GITHUB_USER}/${REPO}/blob/main/videos/preview/%E7%AC%AC1%E9%9B%86-%E5%8D%97%E8%8C%B6%E5%8C%97%E6%B8%A1-%E9%A2%84%E8%A7%88.mp4"
echo
echo "下一步：在仓库 Issues 中新建一条，粘贴 README 里的「三集在线观看」段落即可在线播放预览版。"
