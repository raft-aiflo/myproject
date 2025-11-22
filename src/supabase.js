import { createClient } from '@supabase/supabase-js'

// 从环境变量读取配置
const supabaseUrl =  'https://qtttybsitxumshugqnld.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0dHR5YnNpdHh1bXNodWdxbmxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MjcyNTYsImV4cCI6MjA3OTMwMzI1Nn0.6vobHJGep3xwCXUzrnA6AIMqpYe6WsvnCl_YLJf-76I'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// 数据库表结构
// categories (分类表)
// - id: uuid (primary key)
// - name: text (分类名称)
// - description: text (分类描述)
// - created_at: timestamp
// - updated_at: timestamp

// articles (文章表)
// - id: uuid (primary key)
// - title: text (文章标题)
// - content: text (文章内容)
// - excerpt: text (文章摘要)
// - category_id: uuid (外键，关联categories)
// - status: text (draft, published)
// - view_count: integer (浏览次数)
// - created_at: timestamp
// - updated_at: timestamp

// comments (评论表)
// - id: uuid (primary key)
// - article_id: uuid (外键，关联articles)
// - author: text (评论者姓名)
// - email: text (评论者邮箱)
// - content: text (评论内容)
// - status: text (pending, approved)
// - created_at: timestamp
// - updated_at: timestamp