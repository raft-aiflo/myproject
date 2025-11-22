<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { supabase } from '../supabase'

const articles = ref([])
const categories = ref([])
const loading = ref(true)
const selectedCategory = ref('all')

const fetchArticles = async () => {
  try {
    let query = supabase
      .from('articles')
      .select(`
        *,
        categories (
          id,
          name
        )
      `)
      .eq('status', 'published')
      .order('created_at', { ascending: false })

    if (selectedCategory.value !== 'all') {
      query = query.eq('category_id', selectedCategory.value)
    }

    const { data, error } = await query

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

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('zh-CN')
}

onMounted(async () => {
  await Promise.all([fetchArticles(), fetchCategories()])
  loading.value = false
})
</script>

<template>
  <div class="home">
    <div class="hero">
      <h1 class="hero-title">技术博客</h1>
      <p class="hero-subtitle">分享前端开发、后端技术和编程经验</p>
    </div>

    <div class="filters">
      <h3>分类筛选：</h3>
      <div class="category-filters">
        <button 
          @click="selectedCategory = 'all'; fetchArticles()"
          :class="['filter-btn', { active: selectedCategory === 'all' }]"
        >
          全部
        </button>
        <button 
          v-for="category in categories"
          :key="category.id"
          @click="selectedCategory = category.id; fetchArticles()"
          :class="['filter-btn', { active: selectedCategory === category.id }]"
        >
          {{ category.name }}
        </button>
      </div>
    </div>

    <div v-if="loading" class="loading">
      加载中...
    </div>

    <div v-else-if="articles.length === 0" class="empty">
      <p>暂无文章</p>
    </div>

    <div v-else>
      <div class="articles-container">
        <div class="articles-grid">
          <article v-for="article in articles" :key="article.id" class="article-card">
            <div class="article-meta">
              <span class="category">{{ article.categories?.name || '未分类' }}</span>
              <time class="date">{{ formatDate(article.created_at) }}</time>
            </div>
            <h2 class="article-title">
              <RouterLink :to="`/article/${article.id}`">
                {{ article.title }}
              </RouterLink>
            </h2>
            <p class="article-excerpt">{{ article.excerpt || article.content?.substring(0, 150) + '...' }}</p>
            <div class="article-footer">
              <span class="views">👁 {{ article.view_count || 0 }} 次浏览</span>
              <RouterLink :to="`/article/${article.id}`" class="read-more">
                阅读全文 →
              </RouterLink>
            </div>
          </article>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home {
  width: 100%;
}

.hero {
  text-align: center;
  margin: 0 -2rem 3rem -2rem;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.hero-title {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

.hero-subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
}

.filters {
  margin-bottom: 2rem;
}

.category-filters {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 1rem;
}

.filter-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s;
}

.filter-btn:hover {
  border-color: #3b82f6;
  color: #3b82f6;
}

.filter-btn.active {
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: #666;
}

.articles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 2rem;
}

.article-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s, box-shadow 0.3s;
}

.article-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}

.category {
  background: #e0f2fe;
  color: #0369a1;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-weight: 500;
}

.date {
  color: #6b7280;
}

.article-title {
  margin-bottom: 1rem;
}

.article-title a {
  text-decoration: none;
  color: #1f2937;
  font-weight: 600;
  font-size: 1.25rem;
  line-height: 1.4;
}

.article-title a:hover {
  color: #3b82f6;
}

.article-excerpt {
  color: #6b7280;
  margin-bottom: 1.5rem;
  line-height: 1.6;
}

.article-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.views {
  color: #9ca3af;
  font-size: 0.9rem;
}

.read-more {
  color: #3b82f6;
  text-decoration: none;
  font-weight: 500;
}

.read-more:hover {
  text-decoration: underline;
}

.articles-container {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin: 0 -2rem 0 -2rem;
}

@media (max-width: 768px) {
  .articles-grid {
    grid-template-columns: 1fr;
  }
  
  .hero-title {
    font-size: 2rem;
  }
  
  .articles-container {
    padding: 1.5rem;
  }
}
</style>