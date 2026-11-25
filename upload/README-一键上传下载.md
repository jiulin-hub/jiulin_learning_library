# LuckyTeam_maxREL 一键上传 / 下载

## 一键上传

双击 `一键上传.bat`。上传脚本会把本目录中的发行 ZIP、校验文件和这套脚本提交到 GitHub 仓库 `jiulin-hub/jiulin_learning_library` 的 `upload/` 目录。

首次推送时，Git Credential Manager 会打开 GitHub 登录授权流程。完成一次后，再双击即可上传新版本。每次上传都会重新计算 ZIP 的 SHA-256；若内容没有变化，则不会重复提交。

## 一键下载

双击 `一键下载.bat`。脚本会从公开仓库下载 `upload/` 中的 ZIP 和 SHA-256 文件到本地 `downloaded/`，并校验文件完整性。

ZIP 直链：
https://github.com/jiulin-hub/jiulin_learning_library/raw/refs/heads/main/upload/LuckyTeam_maxREL.zip

## 当前发布包

- 文件：`LuckyTeam_maxREL.zip`
- 来源：`LuckyTeam_maxREL`
- 上传脚本只发布 ZIP，不会重新编译或重新压缩 REL 目录。
