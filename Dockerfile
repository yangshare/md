# 使用 Node 22 Alpine 作为基础镜像
FROM node:22-alpine

# 设置工作目录
WORKDIR /app

# 启用 pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# 复制项目配置文件
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml* .npmrc ./

# 复制 packages 和 apps 目录
# 注意：为了利用缓存，最好先复制 package.json，但由于是 monorepo，子包的 package.json 也在 packages/ 下
# 这里为了简单，先复制所有包描述文件稍微复杂，直接复制整个目录结构
COPY packages ./packages
COPY apps ./apps
COPY patches ./patches
COPY tsconfig.json ./

# 安装依赖 (包括 devDependencies 以支持 tsx)
RUN pnpm install --frozen-lockfile

# 暴露端口
EXPOSE 8800

# 启动命令
# 使用 pnpm 运行 md-cli 的 dev 脚本
CMD ["pnpm", "--filter", "@doocs/md-cli", "run", "dev"]
