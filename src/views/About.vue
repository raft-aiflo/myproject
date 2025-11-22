<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'

const stats = ref({
  totalArticles: 0,
  publishedArticles: 0,
  totalComments: 0,
  categories: 0
})

const loading = ref(true)

// 个人信息
const profile = ref({
  name: '技术博主',
  title: '全栈开发工程师',
  avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&h=150&q=80',
  bio: '热爱编程，专注于前端和后端技术分享。擅长 Vue.js、Node.js、数据库设计等技术领域，致力于通过博客记录学习心得和技术分享。',
  email: 'contact@techblog.com',
  github: 'https://github.com/techblogger',
  linkedin: 'https://linkedin.com/in/techblogger',
  twitter: 'https://twitter.com/techblogger'
})

// 技能标签
const skills = ref([
  { name: 'JavaScript', level: 95 },
  { name: 'Vue.js', level: 90 },
  { name: 'Node.js', level: 85 },
  { name: 'Python', level: 80 },
  { name: 'PostgreSQL', level: 85 },
  { name: 'Docker', level: 75 }
])

// 获取统计数据
const fetchStats = async () => {
  try {
    // 获取文章统计
    const { data: articles, error: articlesError } = await supabase
      .from('articles')
      .select('status')

    if (articlesError) throw articlesError
    
    stats.value.totalArticles = articles?.length || 0
    stats.value.publishedArticles = articles?.filter(a => a.status === 'published').length || 0

    // 获取评论统计
    const { count: commentsCount, error: commentsError } = await supabase
      .from('comments')
      .select('*', { count: 'exact' })

    if (commentsError) throw commentsError
    stats.value.totalComments = commentsCount || 0

    // 获取分类统计
    const { count: categoriesCount, error: categoriesError } = await supabase
      .from('categories')
      .select('*', { count: 'exact' })

    if (categoriesError) throw categoriesError
    stats.value.categories = categoriesCount || 0

  } catch (error) {
    console.error('获取统计数据失败:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchStats()
})
</script>

<template>
  <div class="about-page">
    <!-- 个人信息卡片 -->
    <section class="profile-section">
      <div class="profile-card">
        <div class="avatar-container">
          <img :src="profile.avatar" :alt="profile.name" class="avatar" />
          <div class="status-indicator">✨ 在线</div>
        </div>
        
        <div class="profile-info">
          <h1 class="name">{{ profile.name }}</h1>
          <p class="title">{{ profile.title }}</p>
          <p class="bio">{{ profile.bio }}</p>
          
          <div class="social-links">
            <a :href="profile.email" class="social-link email" title="邮箱">
              📧 contact@techblog.com
            </a>
            <a :href="profile.github" target="_blank" class="social-link github" title="GitHub">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
              GitHub
            </a>
            <a :href="profile.linkedin" target="_blank" class="social-link linkedin" title="LinkedIn">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
              </svg>
              LinkedIn
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- 统计数据 -->
    <section class="stats-section">
      <h2>📊 博客统计</h2>
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-number">{{ loading ? '...' : stats.totalArticles }}</div>
          <div class="stat-label">总文章数</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">{{ loading ? '...' : stats.publishedArticles }}</div>
          <div class="stat-label">已发布</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">{{ loading ? '...' : stats.totalComments }}</div>
          <div class="stat-label">评论数</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">{{ loading ? '...' : stats.categories }}</div>
          <div class="stat-label">分类数</div>
        </div>
      </div>
    </section>

    <!-- 技能展示 -->
    <section class="skills-section">
      <h2>🛠️ 技能栈</h2>
      <div class="skills-grid">
        <div v-for="skill in skills" :key="skill.name" class="skill-item">
          <div class="skill-header">
            <span class="skill-name">{{ skill.name }}</span>
            <span class="skill-level">{{ skill.level }}%</span>
          </div>
          <div class="skill-bar">
            <div 
              class="skill-progress" 
              :style="{ width: skill.level + '%' }"
            ></div>
          </div>
        </div>
      </div>
    </section>

    <!-- 时间线 -->
    <section class="timeline-section">
      <h2>📅 开发历程</h2>
      <div class="timeline">
        <div class="timeline-item">
          <div class="timeline-marker">🚀</div>
          <div class="timeline-content">
            <div class="timeline-date">2024年11月</div>
            <div class="timeline-title">博客系统上线</div>
            <div class="timeline-description">使用 Vue 3 + Supabase + Netlify 构建的现代化博客系统正式上线</div>
          </div>
        </div>
        
        <div class="timeline-item">
          <div class="timeline-marker">💡</div>
          <div class="timeline-content">
            <div class="timeline-date">2024年</div>
            <div class="timeline-title">技术栈升级</div>
            <div class="timeline-description">深入学习 Vue 3、TypeScript、微前端架构等前沿技术</div>
          </div>
        </div>
        
        <div class="timeline-item">
          <div class="timeline-marker">🌱</div>
          <div class="timeline-content">
            <div class="timeline-date">2023年</div>
            <div class="timeline-title">全栈开发</div>
            <div class="timeline-description">专注于前后端技术栈整合，深入数据库设计和优化</div>
          </div>
        </div>
        
        <div class="timeline-item">
          <div class="timeline-marker">🎯</div>
          <div class="timeline-content">
            <div class="timeline-date">2022年</div>
            <div class="timeline-title">前端进阶</div>
            <div class="timeline-description">深入学习 React、Vue 等现代前端框架</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 联系方式 -->
    <section class="contact-section">
      <h2>📬 联系方式</h2>
      <div class="contact-grid">
        <div class="contact-item">
          <div class="contact-icon">📧</div>
          <div class="contact-info">
            <div class="contact-label">邮箱</div>
            <div class="contact-value">contact@techblog.com</div>
          </div>
        </div>
        
        <div class="contact-item">
          <div class="contact-icon">💼</div>
          <div class="contact-info">
            <div class="contact-label">GitHub</div>
            <div class="contact-value">@techblogger</div>
          </div>
        </div>
        
        <div class="contact-item">
          <div class="contact-icon">🌐</div>
          <div class="contact-info">
            <div class="contact-label">LinkedIn</div>
            <div class="contact-value">/in/techblogger</div>
          </div>
        </div>
        
        <div class="contact-item">
          <div class="contact-icon">🐦</div>
          <div class="contact-info">
            <div class="contact-label">Twitter</div>
            <div class="contact-value">@techblogger</div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.about-page {
  width: 100%;
}

/* 个人信息卡片 */
.profile-section {
  margin: 0 -2rem 3rem -2rem;
  padding: 3rem 2rem;
}

.profile-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 3rem;
  color: white;
  display: flex;
  align-items: center;
  gap: 3rem;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
}

.avatar-container {
  position: relative;
}

.avatar {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  border: 4px solid rgba(255, 255, 255, 0.2);
  object-fit: cover;
}

.status-indicator {
  position: absolute;
  bottom: 10px;
  right: 10px;
  background: #10b981;
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 500;
}

.profile-info {
  flex: 1;
}

.name {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.title {
  font-size: 1.25rem;
  opacity: 0.9;
  margin-bottom: 1.5rem;
}

.bio {
  line-height: 1.6;
  font-size: 1.1rem;
  margin-bottom: 2rem;
  opacity: 0.95;
}

.social-links {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.social-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  color: white;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s;
}

.social-link:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

/* 统计数据 */
.stats-section {
  margin: 0 0 3rem -2rem;
  padding: 0 2rem;
}

.stats-section h2 {
  margin-bottom: 2rem;
  color: #1f2937;
  font-size: 1.5rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  text-align: center;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s, box-shadow 0.3s;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.stat-number {
  font-size: 2.5rem;
  font-weight: 700;
  color: #3b82f6;
  margin-bottom: 0.5rem;
}

.stat-label {
  color: #6b7280;
  font-weight: 500;
}

/* 技能展示 */
.skills-section {
  margin: 0 0 3rem -2rem;
  padding: 0 2rem;
}

.skills-section h2 {
  margin-bottom: 2rem;
  color: #1f2937;
  font-size: 1.5rem;
}

.skills-grid {
  display: grid;
  gap: 1.5rem;
}

.skill-item {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.skill-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.skill-name {
  font-weight: 600;
  color: #1f2937;
}

.skill-level {
  color: #3b82f6;
  font-weight: 500;
}

.skill-bar {
  height: 8px;
  background: #e5e7eb;
  border-radius: 4px;
  overflow: hidden;
}

.skill-progress {
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #8b5cf6);
  border-radius: 4px;
  transition: width 1s ease-out;
}

/* 时间线 */
.timeline-section {
  margin: 0 0 3rem -2rem;
  padding: 0 2rem;
}

.timeline-section h2 {
  margin-bottom: 2rem;
  color: #1f2937;
  font-size: 1.5rem;
}

.timeline {
  position: relative;
  padding-left: 3rem;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 1rem;
  top: 0;
  bottom: 0;
  width: 2px;
  background: linear-gradient(180deg, #3b82f6, #8b5cf6);
}

.timeline-item {
  position: relative;
  margin-bottom: 2rem;
}

.timeline-marker {
  position: absolute;
  left: -2.5rem;
  top: 0;
  width: 3rem;
  height: 3rem;
  background: white;
  border: 2px solid #3b82f6;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
}

.timeline-content {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.timeline-date {
  color: #3b82f6;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.timeline-title {
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 0.5rem;
  font-size: 1.1rem;
}

.timeline-description {
  color: #6b7280;
  line-height: 1.6;
}

/* 联系方式 */
.contact-section {
  margin: 0 0 3rem -2rem;
  padding: 0 2rem;
}

.contact-section h2 {
  margin-bottom: 2rem;
  color: #1f2937;
  font-size: 1.5rem;
}

.contact-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.contact-item {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: transform 0.3s, box-shadow 0.3s;
}

.contact-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.contact-icon {
  font-size: 2rem;
  width: 3rem;
  height: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f3f4f6;
  border-radius: 50%;
}

.contact-info {
  flex: 1;
}

.contact-label {
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 0.25rem;
}

.contact-value {
  color: #6b7280;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .profile-card {
    flex-direction: column;
    text-align: center;
    gap: 2rem;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .timeline {
    padding-left: 2rem;
  }
  
  .timeline-marker {
    left: -2rem;
    width: 2.5rem;
    height: 2.5rem;
  }
  
  .name {
    font-size: 2rem;
  }
  
  .stat-number {
    font-size: 2rem;
  }
}

@media (max-width: 480px) {
  .profile-card {
    padding: 2rem 1.5rem;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .contact-grid {
    grid-template-columns: 1fr;
  }
}
</style>