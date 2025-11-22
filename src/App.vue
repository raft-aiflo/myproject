<script setup>
import { RouterView, RouterLink } from 'vue-router'
</script>

<template>
  <div class="app">
    <header class="header">
      <nav class="nav">
        <RouterLink to="/" class="nav-link">首页</RouterLink>
        <RouterLink to="/about" class="nav-link">关于</RouterLink>
        <RouterLink to="/admin" class="nav-link">管理</RouterLink>
      </nav>
    </header>
    <main class="main">
      <RouterView />
    </main>
  </div>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
  color: #333;
}

.app {
  min-height: 100vh;
}

.header {
  background: #fff;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 2rem;
  display: flex;
  gap: 2rem;
}

.nav-link {
  text-decoration: none;
  color: #666;
  font-weight: 500;
  transition: color 0.3s;
}

.nav-link:hover,
.nav-link.router-link-active {
  color: #3b82f6;
}

.main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
</style>
