<script setup>

import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  Menu, 
  Fold, 
  Expand, 
  House, 
  Document, 
  Setting, 
  User,
  Grid,
  Tools,
  DataAnalysis,
  Picture,
  VideoPlay,
  Folder,
  Star,
  Collection,
  Moon,
  Sunny
} from '@element-plus/icons-vue'
import logoImage from './assets/images/logo.png'
import githubImage from './assets/images/github.png'
import { useTheme, THEME_TYPES } from './composables/useTheme'

const router = useRouter()
const route = useRoute()
const isCollapse = ref(false)
const isMobile = ref(false)
const activeMenu = ref('1')

// 主题管理
const { currentTheme, themeMode, setThemeMode } = useTheme()

// 面包屑数据
const breadcrumbItems = ref([
  { name: '首页', path: '/' }
])

// 检测是否为移动端
const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
  updateBreadcrumb()
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})

// 监听路由变化
watch(() => route.path, () => {
  updateBreadcrumb()
  updateActiveMenu()
})

const handleSelect = (key) => {
  activeMenu.value = key
  // 根据key进行路由跳转
  const menuItem = menuItems.find(item => item.index === key)
  if (menuItem) {
    router.push(menuItem.path)
  }
}

// 更新面包屑
const updateBreadcrumb = () => {
  const currentMenuItem = menuItems.find(item => item.path === route.path)
  if (currentMenuItem) {
    breadcrumbItems.value = [
      { name: '首页', path: '/' },
      { name: currentMenuItem.title, path: currentMenuItem.path }
    ]
  } else {
    breadcrumbItems.value = [
      { name: '首页', path: '/' },
      { name: '未知页面', path: route.path }
    ]
  }
}

// 更新当前激活的菜单项
const updateActiveMenu = () => {
  const currentMenuItem = menuItems.find(item => item.path === route.path)
  if (currentMenuItem) {
    activeMenu.value = currentMenuItem.index
  }
}

// 打开 GitHub 链接
const openGitHub = () => {
  // 使用默认浏览器打开 GitHub 链接
  window.open('https://github.com', '_blank')
}

// 切换主题
const toggleTheme = () => {
  const nextMode = themeMode.value === THEME_TYPES.LIGHT ? THEME_TYPES.DARK : THEME_TYPES.LIGHT
  setThemeMode(nextMode)
}

// 设置主题模式
const setThemeModeHandler = (mode) => {
  console.log('切换主题模式:', mode)
  setThemeMode(mode)
}



// 计算侧边栏宽度
const sidebarWidth = computed(() => {
  return isCollapse.value ? '64px' : '200px'
})

// 计算主内容区域的左边距
const mainMarginLeft = computed(() => {
  if (isMobile.value) return '0px'
  return isCollapse.value ? '64px' : '200px'
})

const menuItems = [
  {
    index: '1',
    icon: House,
    title: '首页',
    path: '/'
  },
  {
    index: '2',
    icon: Picture,
    title: '序列帧图',
    path: '/sequence-frames'
  }
]
</script>

<template>
  <div class="app-wrapper">
    <!-- 侧边栏 -->
    <el-aside 
      :width="sidebarWidth" 
      class="sidebar"
      :class="{ 'sidebar-mobile': isMobile }"
    >
      <div class="logo-container">
        <el-image 
          :src="logoImage" 
          alt="Logo" 
          class="logo"
          fit="contain"
        />
        <span v-show="!isCollapse" class="logo-text">GAC</span>
      </div>
      
      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        :collapse="isCollapse"
        @select="handleSelect"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item 
          v-for="item in menuItems" 
          :key="item.index" 
          :index="item.index"
        >
          <el-icon><component :is="item.icon" /></el-icon>
          <template #title>{{ item.title }}</template>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- 主内容区域 -->
    <el-container class="main-container" :style="{ marginLeft: mainMarginLeft }">
      <!-- 顶部导航栏 -->
      <el-header class="header">
        <div class="header-left">
          <!-- 折叠按钮 -->
          <el-button 
            v-show="!isMobile"
            type="text" 
            @click="isCollapse = !isCollapse"
            class="collapse-btn"
          >
            <el-icon><Expand v-if="isCollapse" /><Fold v-else /></el-icon>
          </el-button>
          
          <el-breadcrumb separator="/">
            <el-breadcrumb-item 
              v-for="(item, index) in breadcrumbItems" 
              :key="index"
              :to="item.path"
            >
              {{ item.name }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        
        <div class="header-right">
          <!-- 主题切换按钮 -->
          <el-dropdown @command="setThemeModeHandler" class="theme-dropdown">
            <el-button type="text" class="theme-btn" title="切换主题">
              <el-icon v-if="currentTheme === 'dark'"><Moon /></el-icon>
              <el-icon v-else><Sunny /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item 
                  :command="THEME_TYPES.LIGHT"
                  :class="{ 'is-active': themeMode === THEME_TYPES.LIGHT }"
                >
                  <el-icon><Sunny /></el-icon>
                  浅色模式
                </el-dropdown-item>
                <el-dropdown-item 
                  :command="THEME_TYPES.DARK"
                  :class="{ 'is-active': themeMode === THEME_TYPES.DARK }"
                >
                  <el-icon><Moon /></el-icon>
                  深色模式
                </el-dropdown-item>
                <el-dropdown-item 
                  :command="THEME_TYPES.SYSTEM"
                  :class="{ 'is-active': themeMode === THEME_TYPES.SYSTEM }"
                  divided
                >
                  <el-icon><Setting /></el-icon>
                  跟随系统
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
          
          <el-button 
            type="text" 
            @click="openGitHub"
            class="github-btn"
            title="访问 GitHub"
          >
            <el-image 
              :src="githubImage" 
              alt="GitHub" 
              class="github-icon"
              fit="contain"
            />
            <span class="github-text">GitHub</span>
          </el-button>
        </div>
      </el-header>

      <!-- 主内容区域 -->
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </div>
</template>

<style scoped>
.app-wrapper {
  height: 100vh;
  position: relative;
  overflow: hidden;
}

.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  height: 100vh;
  background-color: #304156;
  transition: all 0.3s ease;
  overflow: hidden;
  z-index: 1000;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

.sidebar-mobile {
  position: fixed;
}

.logo-container {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #2b2f3a;
  padding: 0 20px;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.logo {
  width: 32px;
  height: 32px;
  margin-right: 12px;
  transition: all 0.3s ease;
}

.logo-text {
  color: #fff;
  font-size: 16px;
  font-weight: bold;
  white-space: nowrap;
  transition: all 0.3s ease;
}

.sidebar-menu {
  border-right: none;
  transition: all 0.3s ease;
  flex: 1;
  overflow-y: auto;
}

.main-container {
  transition: margin-left 0.3s ease;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.header {
  border-bottom: 1px solid var(--el-border-color-light);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  position: sticky;
  top: 0;
  z-index: 100;
  flex-shrink: 0;
  background-color: var(--el-bg-color);
}

.header-left {
  display: flex;
  align-items: center;
}

.collapse-btn {
  margin-right: 20px;
  font-size: 18px;
  transition: all 0.3s ease;
  color: var(--el-text-color-primary);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.theme-dropdown {
  margin-right: 8px;
}

.theme-btn {
  color: var(--el-text-color-regular);
  transition: all 0.3s ease;
  padding: 8px;
  border-radius: 6px;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.theme-btn:hover {
  color: var(--el-color-primary);
  background-color: var(--el-color-primary-light-9);
}

.github-btn {
  display: flex;
  align-items: center;
  color: var(--el-text-color-regular);
  transition: all 0.3s ease;
  padding: 8px 12px;
  border-radius: 6px;
}

.github-btn:hover {
  color: var(--el-color-primary);
  background-color: var(--el-color-primary-light-9);
}

.github-icon {
  width: 16px;
  height: 16px;
  margin-right: 6px;
}

.github-text {
  font-size: 14px;
}

.main-content {
  background-color: var(--el-bg-color-page);
  padding: 20px;
  transition: all 0.3s ease;
  flex: 1;
  overflow-y: auto;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    z-index: 1000;
    height: 100vh;
  }
  
  .main-container {
    margin-left: 0 !important;
  }
  
  .collapse-btn {
    display: none;
  }
}

@media (min-width: 769px) {
  .sidebar {
    position: fixed;
  }
  
  .collapse-btn {
    display: block;
  }
}
</style>
