# 🔧 Netlify 部署问题修复

## 已解决的问题

### 1. Node.js 版本兼容性
- **问题**: Vite 7.x 需要 Node.js v20.19+，但 Netlify 默认使用 v18
- **解决**: 降级到 Vite 5.4.10，兼容 Node.js v18+

### 2. crypto.hash 错误
- **问题**: Vite 7.x 的已知兼容性问题
- **解决**: 使用稳定版本的 Vite 5.4.10

### 3. 构建环境配置
- **问题**: Netlify 环境变量和 Node 版本配置
- **解决**: 明确指定 Node.js v20 和 npm v10

## 当前配置

### package.json
```json
{
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.0.0",
    "vite": "^5.4.10"
  }
}
```

### netlify.toml
```toml
[build]
  publish = "dist"
  command = "npm run build"

[build.environment]
  NODE_VERSION = "20"
  NPM_VERSION = "10"
```

## 🚀 部署步骤

### 1. 强制清除 Netlify 缓存
在 Netlify 控制台：
- 进入 **Site settings** → **Build & deploy**
- 点击 **Clear build cache & retry deploy**

### 2. 提交代码到 Git
```bash
git add .
git commit -m "Fix Netlify build issues - force Node.js v20"
git push
```

### 3. 手动部署（备选）
```bash
npm run build
# 上传 dist 文件夹到 Netlify
```

### 4. Netlify 环境变量设置

在 Netlify 控制台的 **Site settings** → **Environment variables** 中设置：
- `VITE_SUPABASE_URL=https://your-project.supabase.co`
- `VITE_SUPABASE_ANON_KEY=your_anon_key`

### 5. 如果仍失败，手动触发构建

在 Netlify 控制台：
- 进入 **Deploys**
- 点击 **Trigger deploy**
- 选择分支并触发

## 验证部署

部署成功后，访问你的 Netlify 网址应该看到：
- ✅ 首页正常显示
- ✅ 个人主页正常显示  
- ✅ 文章详情页正常显示
- ✅ 管理后台正常显示

## 如果仍有问题

1. **检查构建日志** - 在 Netlify 控制台查看详细错误
2. **清理缓存** - 在 Netlify 设置中清理构建缓存
3. **重新触发部署** - 推送新的 commit 或手动触发

---

🎯 **现在应该可以成功部署到 Netlify 了！**