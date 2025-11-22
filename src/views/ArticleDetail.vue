<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { supabase } from '../supabase'

const props = defineProps({
  id: {
    type: String,
    required: true
  }
})

const article = ref(null)
const comments = ref([])
const loading = ref(true)
const submittingComment = ref(false)

const commentForm = ref({
  author: '',
  email: '',
  content: ''
})

const fetchArticle = async () => {
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
      .eq('id', props.id)
      .single()

    if (error) throw error
    
    article.value = data
    
    // 增加浏览次数
    await supabase
      .from('articles')
      .update({ view_count: (data.view_count || 0) + 1 })
      .eq('id', props.id)
      
  } catch (error) {
    console.error('获取文章失败:', error)
  }
}

const fetchComments = async () => {
  try {
    const { data, error } = await supabase
      .from('comments')
      .select('*')
      .eq('article_id', props.id)
      .eq('status', 'approved')
      .order('created_at', { ascending: true })

    if (error) throw error
    comments.value = data || []
  } catch (error) {
    console.error('获取评论失败:', error)
  }
}

const submitComment = async () => {
  if (!commentForm.value.author.trim() || 
      !commentForm.value.email.trim() || 
      !commentForm.value.content.trim()) {
    alert('请填写完整信息')
    return
  }

  submittingComment.value = true
  
  try {
    const { error } = await supabase
      .from('comments')
      .insert({
        article_id: props.id,
        author: commentForm.value.author,
        email: commentForm.value.email,
        content: commentForm.value.content,
        status: 'pending'
      })

    if (error) throw error

    alert('评论已提交，等待审核')
    
    // 重置表单
    commentForm.value = {
      author: '',
      email: '',
      content: ''
    }
  } catch (error) {
    console.error('提交评论失败:', error)
    alert('提交失败，请重试')
  } finally {
    submittingComment.value = false
  }
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatContent = (content) => {
  if (!content) return ''
  return content.replace(/\n/g, '<br>')
}

onMounted(async () => {
  await Promise.all([fetchArticle(), fetchComments()])
  loading.value = false
})
</script>

<template>
  <div class="article-detail">
    <div v-if="loading" class="loading">
      加载中...
    </div>

    <div v-else-if="!article" class="not-found">
      <h1>文章不存在</h1>
      <RouterLink to="/" class="back-link">← 返回首页</RouterLink>
    </div>

    <article v-else class="article">
      <header class="article-header">
        <RouterLink to="/" class="back-link">← 返回首页</RouterLink>
        <h1 class="article-title">{{ article.title }}</h1>
        <div class="article-meta">
          <span class="category">{{ article.categories?.name || '未分类' }}</span>
          <time class="date">{{ formatDate(article.created_at) }}</time>
          <span class="views">👁 {{ article.view_count || 0 }} 次浏览</span>
        </div>
      </header>

      <div class="article-content" v-html="formatContent(article.content)"></div>

      <section class="comments-section">
        <h2>评论 ({{ comments.length }})</h2>
        
        <div v-if="comments.length === 0" class="no-comments">
          暂无评论，快来发表第一个评论吧！
        </div>

        <div v-else class="comments-list">
          <div v-for="comment in comments" :key="comment.id" class="comment">
            <div class="comment-header">
              <strong>{{ comment.author }}</strong>
              <time class="comment-date">{{ formatDate(comment.created_at) }}</time>
            </div>
            <div class="comment-content" v-html="formatContent(comment.content)"></div>
          </div>
        </div>

        <div class="comment-form">
          <h3>发表评论</h3>
          <form @submit.prevent="submitComment">
            <div class="form-group">
              <label for="author">姓名 *</label>
              <input
                id="author"
                v-model="commentForm.author"
                type="text"
                required
                placeholder="请输入您的姓名"
              />
            </div>
            
            <div class="form-group">
              <label for="email">邮箱 *</label>
              <input
                id="email"
                v-model="commentForm.email"
                type="email"
                required
                placeholder="请输入您的邮箱"
              />
            </div>
            
            <div class="form-group">
              <label for="content">评论内容 *</label>
              <textarea
                id="content"
                v-model="commentForm.content"
                required
                rows="4"
                placeholder="请输入您的评论..."
              ></textarea>
            </div>
            
            <button 
              type="submit" 
              :disabled="submittingComment"
              class="submit-btn"
            >
              {{ submittingComment ? '提交中...' : '提交评论' }}
            </button>
          </form>
        </div>
      </section>
    </article>
  </div>
</template>

<style scoped>
.loading {
  text-align: center;
  padding: 3rem;
  color: #666;
}

.not-found {
  text-align: center;
  padding: 3rem;
}

.back-link {
  color: #3b82f6;
  text-decoration: none;
  font-weight: 500;
  margin-bottom: 2rem;
  display: inline-block;
}

.back-link:hover {
  text-decoration: underline;
}

.article {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin: 0 -2rem 0 -2rem;
}

.article-header {
  margin-bottom: 2rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #e5e7eb;
}

.article-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #1f2937;
  margin: 1rem 0;
  line-height: 1.3;
}

.article-meta {
  display: flex;
  gap: 1rem;
  align-items: center;
  flex-wrap: wrap;
  color: #6b7280;
}

.category {
  background: #e0f2fe;
  color: #0369a1;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-weight: 500;
}

.article-content {
  line-height: 1.8;
  font-size: 1.1rem;
  color: #374151;
  margin-bottom: 3rem;
  white-space: pre-wrap;
}

.comments-section {
  border-top: 2px solid #e5e7eb;
  padding-top: 2rem;
}

.comments-section h2 {
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  color: #1f2937;
}

.no-comments {
  text-align: center;
  color: #9ca3af;
  padding: 2rem;
  background: #f9fafb;
  border-radius: 8px;
}

.comments-list {
  margin-bottom: 2rem;
}

.comment {
  background: #f9fafb;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1rem;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.comment-date {
  color: #9ca3af;
  font-size: 0.9rem;
}

.comment-content {
  line-height: 1.6;
  color: #4b5563;
  white-space: pre-wrap;
}

.comment-form {
  background: #f9fafb;
  border-radius: 8px;
  padding: 2rem;
}

.comment-form h3 {
  margin-bottom: 1.5rem;
  color: #1f2937;
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
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.submit-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.75rem 2rem;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.3s;
}

.submit-btn:hover:not(:disabled) {
  background: #2563eb;
}

.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .article {
    padding: 1.5rem;
  }
  
  .article-title {
    font-size: 2rem;
  }
  
  .article-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .comment-form {
    padding: 1.5rem;
  }
}
</style>