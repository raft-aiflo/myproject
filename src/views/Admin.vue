<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'

const activeTab = ref('articles')
const articles = ref([])
const categories = ref([])
const comments = ref([])
const loading = ref(true)

// 文章表单
const articleForm = ref({
  id: null,
  title: '',
  content: '',
  excerpt: '',
  category_id: '',
  status: 'draft'
})

// 分类表单
const categoryForm = ref({
  id: null,
  name: '',
  description: ''
})

// 编辑模式
const isEditingArticle = ref(false)
const isEditingCategory = ref(false)

const fetchArticles = async () => {
  try {
    const { data, error } = await supabase
      .from('articles')
      .select(`
        *,
        categories (
          id,
          name
        )
      `)
      .order('created_at', { ascending: false })

    if (error) throw error
    articles.value = data || []
  } catch (error) {
    console.error('获取文章失败:', error)
  }
}

const fetchCategories = async () => {
  try {
    const { data, error } = await supabase
      .from('categories')
      .select('*')
      .order('name')

    if (error) throw error
    categories.value = data || []
  } catch (error) {
    console.error('获取分类失败:', error)
  }
}

const fetchComments = async () => {
  try {
    const { data, error } = await supabase
      .from('comments')
      .select(`
        *,
        articles (
          id,
          title
        )
      `)
      .order('created_at', { ascending: false })

    if (error) throw error
    comments.value = data || []
  } catch (error) {
    console.error('获取评论失败:', error)
  }
}

const saveArticle = async () => {
  try {
    if (!articleForm.value.title.trim() || !articleForm.value.content.trim()) {
      alert('请填写标题和内容')
      return
    }

    const articleData = {
      title: articleForm.value.title,
      content: articleForm.value.content,
      excerpt: articleForm.value.excerpt,
      category_id: articleForm.value.category_id || null,
      status: articleForm.value.status
    }

    let result
    if (articleForm.value.id) {
      // 更新文章
      result = await supabase
        .from('articles')
        .update(articleData)
        .eq('id', articleForm.value.id)
    } else {
      // 创建文章
      result = await supabase
        .from('articles')
        .insert(articleData)
    }

    if (result.error) throw result.error

    alert('文章保存成功')
    resetArticleForm()
    await fetchArticles()
  } catch (error) {
    console.error('保存文章失败:', error)
    alert('保存失败，请重试')
  }
}

const editArticle = (article) => {
  articleForm.value = {
    id: article.id,
    title: article.title,
    content: article.content,
    excerpt: article.excerpt,
    category_id: article.category_id,
    status: article.status
  }
  isEditingArticle.value = true
}

const deleteArticle = async (id) => {
  if (!confirm('确定要删除这篇文章吗？')) return

  try {
    const { error } = await supabase
      .from('articles')
      .delete()
      .eq('id', id)

    if (error) throw error
    alert('删除成功')
    await fetchArticles()
  } catch (error) {
    console.error('删除文章失败:', error)
    alert('删除失败，请重试')
  }
}

const saveCategory = async () => {
  try {
    if (!categoryForm.value.name.trim()) {
      alert('请填写分类名称')
      return
    }

    const categoryData = {
      name: categoryForm.value.name,
      description: categoryForm.value.description
    }

    let result
    if (categoryForm.value.id) {
      // 更新分类
      result = await supabase
        .from('categories')
        .update(categoryData)
        .eq('id', categoryForm.value.id)
    } else {
      // 创建分类
      result = await supabase
        .from('categories')
        .insert(categoryData)
    }

    if (result.error) throw result.error

    alert('分类保存成功')
    resetCategoryForm()
    await fetchCategories()
  } catch (error) {
    console.error('保存分类失败:', error)
    alert('保存失败，请重试')
  }
}

const editCategory = (category) => {
  categoryForm.value = {
    id: category.id,
    name: category.name,
    description: category.description
  }
  isEditingCategory.value = true
}

const deleteCategory = async (id) => {
  if (!confirm('确定要删除这个分类吗？')) return

  try {
    const { error } = await supabase
      .from('categories')
      .delete()
      .eq('id', id)

    if (error) throw error
    alert('删除成功')
    await fetchCategories()
  } catch (error) {
    console.error('删除分类失败:', error)
    alert('删除失败，请重试')
  }
}

const approveComment = async (id) => {
  try {
    const { error } = await supabase
      .from('comments')
      .update({ status: 'approved' })
      .eq('id', id)

    if (error) throw error
    alert('评论已通过审核')
    await fetchComments()
  } catch (error) {
    console.error('审核评论失败:', error)
    alert('操作失败，请重试')
  }
}

const deleteComment = async (id) => {
  if (!confirm('确定要删除这条评论吗？')) return

  try {
    const { error } = await supabase
      .from('comments')
      .delete()
      .eq('id', id)

    if (error) throw error
    alert('删除成功')
    await fetchComments()
  } catch (error) {
    console.error('删除评论失败:', error)
    alert('删除失败，请重试')
  }
}

const resetArticleForm = () => {
  articleForm.value = {
    id: null,
    title: '',
    content: '',
    excerpt: '',
    category_id: '',
    status: 'draft'
  }
  isEditingArticle.value = false
}

const resetCategoryForm = () => {
  categoryForm.value = {
    id: null,
    name: '',
    description: ''
  }
  isEditingCategory.value = false
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('zh-CN')
}

onMounted(async () => {
  await Promise.all([fetchArticles(), fetchCategories(), fetchComments()])
  loading.value = false
})
</script>

<template>
  <div class="admin">
    <h1 class="admin-title">博客管理后台</h1>

    <div v-if="loading" class="loading">
      加载中...
    </div>

    <div v-else class="admin-content">
      <!-- 标签页导航 -->
      <div class="tabs">
        <button 
          @click="activeTab = 'articles'"
          :class="['tab-btn', { active: activeTab === 'articles' }]"
        >
          文章管理
        </button>
        <button 
          @click="activeTab = 'categories'"
          :class="['tab-btn', { active: activeTab === 'categories' }]"
        >
          分类管理
        </button>
        <button 
          @click="activeTab = 'comments'"
          :class="['tab-btn', { active: activeTab === 'comments' }]"
        >
          评论管理
        </button>
      </div>

      <!-- 文章管理 -->
      <div v-if="activeTab === 'articles'" class="tab-content">
        <div class="section-header">
          <h2>文章管理</h2>
          <button @click="isEditingArticle = true" class="btn-primary">
            新建文章
          </button>
        </div>

        <!-- 文章表单 -->
        <div v-if="isEditingArticle" class="form-section">
          <h3>{{ articleForm.id ? '编辑文章' : '新建文章' }}</h3>
          <form @submit.prevent="saveArticle">
            <div class="form-group">
              <label>标题</label>
              <input v-model="articleForm.title" type="text" required />
            </div>
            
            <div class="form-group">
              <label>分类</label>
              <select v-model="articleForm.category_id">
                <option value="">请选择分类</option>
                <option v-for="category in categories" :key="category.id" :value="category.id">
                  {{ category.name }}
                </option>
              </select>
            </div>
            
            <div class="form-group">
              <label>摘要</label>
              <input v-model="articleForm.excerpt" type="text" placeholder="可选" />
            </div>
            
            <div class="form-group">
              <label>状态</label>
              <select v-model="articleForm.status">
                <option value="draft">草稿</option>
                <option value="published">已发布</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>内容</label>
              <textarea v-model="articleForm.content" rows="10" required></textarea>
            </div>
            
            <div class="form-actions">
              <button type="submit" class="btn-primary">保存</button>
              <button type="button" @click="resetArticleForm" class="btn-secondary">取消</button>
            </div>
          </form>
        </div>

        <!-- 文章列表 -->
        <div class="list-section">
          <div class="list-header">
            <span>标题</span>
            <span>分类</span>
            <span>状态</span>
            <span>浏览量</span>
            <span>操作</span>
          </div>
          <div v-for="article in articles" :key="article.id" class="list-item">
            <div class="item-title">{{ article.title }}</div>
            <div>{{ article.categories?.name || '未分类' }}</div>
            <div>
              <span :class="['status', article.status]">
                {{ article.status === 'published' ? '已发布' : '草稿' }}
              </span>
            </div>
            <div>{{ article.view_count || 0 }}</div>
            <div class="actions">
              <button @click="editArticle(article)" class="btn-edit">编辑</button>
              <button @click="deleteArticle(article.id)" class="btn-delete">删除</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 分类管理 -->
      <div v-if="activeTab === 'categories'" class="tab-content">
        <div class="section-header">
          <h2>分类管理</h2>
          <button @click="isEditingCategory = true" class="btn-primary">
            新建分类
          </button>
        </div>

        <!-- 分类表单 -->
        <div v-if="isEditingCategory" class="form-section">
          <h3>{{ categoryForm.id ? '编辑分类' : '新建分类' }}</h3>
          <form @submit.prevent="saveCategory">
            <div class="form-group">
              <label>分类名称</label>
              <input v-model="categoryForm.name" type="text" required />
            </div>
            
            <div class="form-group">
              <label>描述</label>
              <input v-model="categoryForm.description" type="text" placeholder="可选" />
            </div>
            
            <div class="form-actions">
              <button type="submit" class="btn-primary">保存</button>
              <button type="button" @click="resetCategoryForm" class="btn-secondary">取消</button>
            </div>
          </form>
        </div>

        <!-- 分类列表 -->
        <div class="list-section">
          <div class="list-header">
            <span>分类名称</span>
            <span>描述</span>
            <span>操作</span>
          </div>
          <div v-for="category in categories" :key="category.id" class="list-item">
            <div class="item-title">{{ category.name }}</div>
            <div>{{ category.description || '-' }}</div>
            <div class="actions">
              <button @click="editCategory(category)" class="btn-edit">编辑</button>
              <button @click="deleteCategory(category.id)" class="btn-delete">删除</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 评论管理 -->
      <div v-if="activeTab === 'comments'" class="tab-content">
        <h2>评论管理</h2>
        
        <div class="list-section">
          <div class="list-header">
            <span>评论者</span>
            <span>内容</span>
            <span>文章</span>
            <span>状态</span>
            <span>操作</span>
          </div>
          <div v-for="comment in comments" :key="comment.id" class="list-item">
            <div>
              <div class="comment-author">{{ comment.author }}</div>
              <div class="comment-date">{{ formatDate(comment.created_at) }}</div>
            </div>
            <div class="comment-content">{{ comment.content }}</div>
            <div>{{ comment.articles?.title || '已删除文章' }}</div>
            <div>
              <span :class="['status', comment.status]">
                {{ comment.status === 'approved' ? '已通过' : '待审核' }}
              </span>
            </div>
            <div class="actions">
              <button 
                v-if="comment.status === 'pending'" 
                @click="approveComment(comment.id)" 
                class="btn-approve"
              >
                通过
              </button>
              <button @click="deleteComment(comment.id)" class="btn-delete">删除</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin {
  width: 100%;
}

.admin-title {
  font-size: 2rem;
  margin-bottom: 2rem;
  color: #1f2937;
}

.loading {
  text-align: center;
  padding: 3rem;
  color: #666;
}

.admin-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  margin: 0 -2rem 0 -2rem;
}

.tabs {
  display: flex;
  border-bottom: 1px solid #e5e7eb;
}

.tab-btn {
  flex: 1;
  padding: 1rem;
  border: none;
  background: none;
  font-size: 1rem;
  cursor: pointer;
  border-bottom: 3px solid transparent;
  transition: all 0.3s;
}

.tab-btn:hover {
  background: #f9fafb;
}

.tab-btn.active {
  color: #3b82f6;
  border-bottom-color: #3b82f6;
}

.tab-content {
  padding: 2rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.form-section {
  background: #f9fafb;
  border-radius: 8px;
  padding: 2rem;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 1rem;
}

.form-group textarea {
  resize: vertical;
}

.form-actions {
  display: flex;
  gap: 1rem;
}

.btn-primary {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  font-size: 1rem;
  cursor: pointer;
}

.btn-primary:hover {
  background: #2563eb;
}

.btn-secondary {
  background: #6b7280;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  font-size: 1rem;
  cursor: pointer;
}

.btn-secondary:hover {
  background: #4b5563;
}

.list-section {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
}

.list-header {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 1.5fr;
  gap: 1rem;
  padding: 1rem;
  background: #f9fafb;
  font-weight: 600;
  color: #374151;
}

.list-item {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 1.5fr;
  gap: 1rem;
  padding: 1rem;
  border-bottom: 1px solid #e5e7eb;
  align-items: center;
}

.list-item:last-child {
  border-bottom: none;
}

.item-title {
  font-weight: 500;
  color: #1f2937;
}

.status {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 500;
}

.status.published,
.status.approved {
  background: #d1fae5;
  color: #065f46;
}

.status.draft,
.status.pending {
  background: #fed7aa;
  color: #92400e;
}

.actions {
  display: flex;
  gap: 0.5rem;
}

.btn-edit {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-size: 0.875rem;
  cursor: pointer;
}

.btn-edit:hover {
  background: #2563eb;
}

.btn-delete {
  background: #ef4444;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-size: 0.875rem;
  cursor: pointer;
}

.btn-delete:hover {
  background: #dc2626;
}

.btn-approve {
  background: #10b981;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-size: 0.875rem;
  cursor: pointer;
}

.btn-approve:hover {
  background: #059669;
}

.comment-author {
  font-weight: 500;
  color: #1f2937;
}

.comment-date {
  font-size: 0.875rem;
  color: #6b7280;
}

.comment-content {
  color: #4b5563;
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

@media (max-width: 768px) {
  .tabs {
    flex-direction: column;
  }
  
  .list-header,
  .list-item {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }
  
  .actions {
    justify-content: flex-start;
  }
}
</style>