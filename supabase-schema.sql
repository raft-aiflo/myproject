-- 创建分类表
CREATE TABLE IF NOT EXISTS categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建文章表
CREATE TABLE IF NOT EXISTS articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  excerpt TEXT,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建评论表
CREATE TABLE IF NOT EXISTS comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  author TEXT NOT NULL,
  email TEXT NOT NULL,
  content TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有表创建更新时间触发器
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_articles_updated_at BEFORE UPDATE ON articles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_articles_category_id ON articles(category_id);
CREATE INDEX IF NOT EXISTS idx_articles_status ON articles(status);
CREATE INDEX IF NOT EXISTS idx_articles_created_at ON articles(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_article_id ON comments(article_id);
CREATE INDEX IF NOT EXISTS idx_comments_status ON comments(status);

-- 插入示例数据
INSERT INTO categories (name, description) VALUES
('前端开发', 'HTML、CSS、JavaScript、Vue、React等前端技术'),
('后端开发', 'Node.js、Python、Java、数据库等后端技术'),
('开发工具', 'Git、Docker、CI/CD等开发工具和流程'),
('技术分享', '技术学习心得、最佳实践、经验分享');

INSERT INTO articles (title, content, excerpt, category_id, status) VALUES
('Vue 3 组合式 API 入门指南', 
'Vue 3 引入了组合式 API，这是一种更灵活的方式来组织和复用逻辑...\n\n## 什么是组合式 API\n组合式 API 提供了一种基于函数的 API，让我们可以更灵活地组织组件逻辑。\n\n## 基本用法\n```javascript\nimport { ref, computed } from ''vue''\n\nexport default {\n  setup() {\n    const count = ref(0)\n    const doubled = computed(() => count.value * 2)\n    \n    return { count, doubled }\n  }\n}\n```',
'Vue 3 组合式 API 详解，包括基本概念、使用方法和最佳实践。',
(SELECT id FROM categories WHERE name = '前端开发' LIMIT 1),
'published'),

('Supabase 快速上手教程',
'Supabase 是一个开源的 Firebase 替代品，提供了数据库、认证、存储等功能...\n\n## 项目初始化\n1. 在 Supabase 控制台创建新项目\n2. 获取 API 密钥\n3. 配置环境变量\n\n## 数据库操作\n```javascript\nimport { createClient } from ''@supabase/supabase-js''\n\nconst supabase = createClient(url, key)\n\n// 查询数据\nconst { data } = await supabase\n  .from(''users'')\n  .select(''*'')\n```',
'学习如何使用 Supabase 构建现代化的全栈应用。',
(SELECT id FROM categories WHERE name = '后端开发' LIMIT 1),
'published'),

('Netlify 部署 Vue 应用',
'Netlify 是一个优秀的静态网站托管平台，特别适合 Vue 应用的部署...\n\n## 准备工作\n1. 构建生产版本：`npm run build`\n2. 配置 `netlify.toml` 文件\n3. 设置环境变量\n\n## 自动部署\n连接 GitHub 仓库后，Netlify 会在每次 push 时自动部署。',
'详细介绍如何将 Vue 应用部署到 Netlify 平台。',
(SELECT id FROM categories WHERE name = '开发工具' LIMIT 1),
'published');