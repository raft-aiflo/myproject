# 博客系统部署指南

这是一个基于 Vue 3 + Vite + Supabase 的博客系统，支持文章管理、分类功能和评论系统。

## 项目特点

- **前端框架**: Vue 3 + Composition API
- **路由管理**: Vue Router
- **后端服务**: Supabase (PostgreSQL + 实时订阅)
- **部署平台**: Netlify
- **响应式设计**: 支持移动端和桌面端

## 功能模块

### 4 个独立页面

1. **首页 (`/`)**
   - 文章列表展示
   - 分类筛选
   - 响应式卡片布局

2. **文章详情页 (`/article/:id`)**
   - 文章内容展示
   - 浏览量统计
   - 评论系统
   - 评论审核功能

3. **个人主页 (`/about`)**
   - 个人信息展示
   - 博客统计数据
   - 技能栈展示
   - 开发历程时间线
   - 联系方式

4. **管理后台 (`/admin`)**
   - 文章管理 (创建、编辑、删除)
   - 分类管理 (创建、编辑、删除)
   - 评论管理 (审核、删除)

### 3 张数据表

1. **categories** (分类表)
   - `id`: UUID 主键
   - `name`: 分类名称
   - `description`: 分类描述
   - `created_at/updated_at`: 时间戳

2. **articles** (文章表)
   - `id`: UUID 主键
   - `title`: 文章标题
   - `content`: 文章内容
   - `excerpt`: 文章摘要
   - `category_id`: 外键关联分类
   - `status`: 状态 (draft/published)
   - `view_count`: 浏览次数

3. **comments** (评论表)
   - `id`: UUID 主键
   - `article_id`: 外键关联文章
   - `author`: 评论者姓名
   - `email`: 评论者邮箱
   - `content`: 评论内容
   - `status`: 状态 (pending/approved)

## 部署步骤

### 1. Supabase 设置

1. 访问 [Supabase](https://supabase.com) 并创建账户
2. 创建新项目
3. 在 SQL 编辑器中执行 `supabase-schema.sql` 中的 SQL 语句
4. 在 Settings → API 中获取以下信息：
   - Project URL
   - `anon` public API key

### 2. 环境变量配置

1. 复制 `.env.example` 为 `.env`
2. 填入 Supabase 配置：
   ```bash
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

### 3. Netlify 部署

#### 方法一: Git 集成部署

1. 将代码推送到 GitHub/GitLab 仓库
2. 访问 [Netlify](https://netlify.com) 并连接账户
3. 点击 "New site from Git"
4. 选择代码仓库
5. 配置构建设置：
   - Build command: `npm run build`
   - Publish directory: `dist`
6. 在 Environment variables 中设置：
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

#### 方法二: 手动部署

1. 本地构建项目：
   ```bash
   npm install
   npm run build
   ```

2. 将 `dist` 文件夹拖拽到 Netlify 部署页面

### 4. 域名配置 (可选)

在 Netlify 中可以：
- 使用免费的 `*.netlify.app` 域名
- 绑定自定义域名
- 配置 HTTPS 证书

## 开发和调试

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

### 数据库管理

通过 Supabase 控制台可以：
- 查看和编辑数据
- 执行 SQL 查询
- 监控数据库性能
- 设置行级安全策略

## 项目结构

```
myproject10/
├── public/                 # 静态资源
├── src/
│   ├── components/        # 组件目录
│   ├── views/            # 页面组件
│   │   ├── Home.vue      # 首页
│   │   ├── About.vue     # 个人主页
│   │   ├── ArticleDetail.vue # 文章详情
│   │   └── Admin.vue     # 管理后台
│   ├── router/           # 路由配置
│   ├── supabase.js       # Supabase 客户端配置
│   ├── App.vue           # 根组件
│   └── main.js           # 入口文件
├── netlify.toml          # Netlify 配置
├── supabase-schema.sql   # 数据库结构
├── .env.example         # 环境变量模板
└── README-DEPLOYMENT.md # 部署指南
```

## 常见问题

### 1. CORS 错误
在 Supabase 控制台的 Settings → API 中添加你的 Netlify 域名到 CORS 允许列表。

### 2. 构建失败
检查 Node.js 版本是否匹配（建议 v18+），确保所有依赖都已正确安装。

### 3. 数据库连接失败
验证环境变量是否正确设置，确保 Supabase API 密钥有效。

## 扩展功能建议

- 用户认证系统
- 文章标签功能
- 搜索功能
- 图片上传
- 邮件通知
- SEO 优化
- 社交媒体分享

## 许可证

MIT License