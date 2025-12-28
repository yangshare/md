---
alwaysApply: false
description: 项目规则（doocs/md）
---
# 项目规则（doocs/md）

## 项目定位

- 产品：微信 Markdown 编辑器（Web + 浏览器扩展 + VSCode 插件 + uTools 插件 + CLI）
- 仓库形态：pnpm monorepo（workspace）

## 开发环境与基础命令

- Node：>= 22.16.0
- 包管理：pnpm（workspace）
- 常用命令（仓库根目录）
  - 安装依赖：pnpm i
  - Web 开发：pnpm web dev（默认访问 http://localhost:5173/md/）
  - Web 构建（部署在 /md）：pnpm web build
  - Web 构建（部署在根目录/Netlify）：pnpm web build:h5-netlify
  - Lint：pnpm run lint
  - 类型检查：pnpm run type-check

## Monorepo 结构与职责边界

- apps/
  - web：主站与浏览器扩展（Vue 3 + Vite）
  - vscode：VSCode 插件（webpack 构建）
  - utools：uTools 插件壳（前端产物来自 apps/web 的 utools 构建）
- packages/
  - core：Markdown 渲染与扩展（renderer / extensions / theme / utils）
  - shared：跨端共享的配置、常量、类型、编辑器相关工具
  - config：tsconfig 等项目级配置（供各包 extends/exports）
  - md-cli：本地预览 CLI（Node/Express）
  - example：示例服务（用于对接公众号 openapi 的代理示例）

变更放置建议：
- 仅 Web UI/交互：优先放 apps/web
- 多端复用（Web/VSCode/CLI）：优先放 packages/shared
- Markdown 解析、渲染、扩展与主题能力：放 packages/core

## Web 应用技术栈与约定（apps/web）

- 框架：Vue 3（SFC）+ TypeScript
- 构建：Vite
- 状态管理：Pinia（store 位于 apps/web/src/stores）
- 样式：Tailwind CSS v4 + Less（主题相关 less 位于 apps/web/src/assets/less）
- UI 组件：shadcn-vue 风格组件（位于 apps/web/src/components/ui）
- 图标：lucide-vue-next

### 入口与路径

- 入口：[main.ts](file:///e:/开源项目/makedown转html/md/apps/web/src/main.ts)
- 默认部署 base：/md/（在 Netlify / Cloudflare Workers / CF Pages 下为 /；在 uTools 下为相对路径 ./）
- 路径别名：@ 指向 apps/web/src（见 Vite resolve.alias）

### 自动导入（重要）

apps/web 使用自动导入以减少样板代码：
- 自动导入的包：vue、pinia、@vueuse/core
- 自动扫描目录：apps/web/src/stores、apps/web/src/utils/toast、apps/web/src/composables

约定：
- 业务代码可直接使用 `ref`/`computed`/`defineStore`/`storeToRefs`/`toast` 等，无需手写 import
- 类型只在需要时用 `import type` 显式导入

### 组件与模块放置

- 视图级页面：apps/web/src/views
- 业务组件：apps/web/src/components（按领域分目录，如 components/ai、components/editor、components/ui）
- 复用逻辑：apps/web/src/composables
- 运行时工具：apps/web/src/utils、apps/web/src/lib
- 状态：apps/web/src/stores（Pinia setup store 风格）

## 共享包与核心包约定

- @md/core：提供渲染器、扩展、主题处理与工具函数（供 Web/VSCode 等端使用）
- @md/shared：沉淀共享类型（types/）、配置（configs/）、编辑器能力（editor/）与通用工具（utils/）

新增能力建议：
- 新增 Markdown 扩展：packages/core/src/extensions
- 新增主题能力：packages/core/src/theme 或 packages/shared/src/configs/theme-css
- 新增跨端类型定义：packages/shared/src/types

## 代码风格与质量门禁

- ESLint：@antfu/eslint-config（启用 vue + typescript + formatters）
- 约定风格：
  - 缩进 2 空格、LF 换行（见 .editorconfig）
  - 默认不使用分号（semi: never）
  - 字符串倾向使用单引号（TS/JS），模板字符串使用反引号
  - TypeScript 严格模式（strict: true），构建前需通过 vue-tsc

提交/合并前最低要求：
- pnpm run lint
- pnpm run type-check
- 针对 apps/web 的变更建议额外运行：pnpm web build

## 构建与发布要点（按需）

- 浏览器扩展：apps/web 使用 wxt（dev: pnpm web ext:dev，zip: pnpm web ext:zip / firefox:zip）
- uTools：pnpm utools:package（产物位于 apps/utools/release）
- CLI：packages/md-cli（Express 服务），打包流程见根目录 build:cli 脚本
- Docker：docker/latest 目录提供构建与静态资源打包方案

