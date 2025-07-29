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
  const url = 'https://github.com/caoaolong/GameAssetCreator'

  // 优先使用 Wails 的 BrowserOpenURL API
  if (window.runtime && window.runtime.BrowserOpenURL) {
    try {
      window.runtime.BrowserOpenURL(url)
      return
    } catch (error) {
      console.error('Wails BrowserOpenURL 失败:', error)
    }
  }

  // 备用方案：直接使用 location.href 或创建临时链接
  try {
    window.location.href = url
  } catch (error) {
    // 方法2：创建临时链接
    const link = document.createElement('a')
    link.href = url
    link.target = '_blank'
    link.rel = 'noopener noreferrer'
    link.style.display = 'none'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}

// 切换主题
const toggleTheme = () => {
  const nextMode = themeMode.value === THEME_TYPES.LIGHT ? THEME_TYPES.DARK : THEME_TYPES.LIGHT
  setThemeMode(nextMode)
}

// 设置主题模式
const setThemeModeHandler = (mode) => {
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
    <el-aside :width="sidebarWidth" class="sidebar" :class="{ 'sidebar-mobile': isMobile }">
      <div class="logo-container">
        <el-image :src="logoImage" alt="Logo" class="logo-image" fit="contain" />
      </div>

      <el-menu :default-active="activeMenu" class="sidebar-menu" :collapse="isCollapse" @select="handleSelect"
        :background-color="currentTheme === 'dark' ? '#1a1a1a' : '#f5f7fa'" 
        :text-color="currentTheme === 'dark' ? '#e5e7eb' : '#606266'" 
        :active-text-color="currentTheme === 'dark' ? '#409EFF' : '#409EFF'">
        <el-menu-item v-for="item in menuItems" :key="item.index" :index="item.index">
          <el-icon>
            <component :is="item.icon" />
          </el-icon>
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
          <el-button v-show="!isMobile" type="text" @click="isCollapse = !isCollapse" class="collapse-btn">
            <el-icon>
              <Expand v-if="isCollapse" />
              <Fold v-else />
            </el-icon>
          </el-button>

          <el-breadcrumb separator="/">
            <el-breadcrumb-item v-for="(item, index) in breadcrumbItems" :key="index" :to="item.path">
              {{ item.name }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <div class="header-right">
          <!-- 主题切换按钮 -->
          <el-dropdown @command="setThemeModeHandler" class="theme-dropdown">
            <el-button type="text" class="theme-btn" title="切换主题">
              <el-icon v-if="currentTheme === 'dark'">
                <Moon />
              </el-icon>
              <el-icon v-else>
                <Sunny />
              </el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item :command="THEME_TYPES.LIGHT"
                  :class="{ 'is-active': themeMode === THEME_TYPES.LIGHT }">
                  <el-icon>
                    <Sunny />
                  </el-icon>
                  浅色模式
                </el-dropdown-item>
                <el-dropdown-item :command="THEME_TYPES.DARK" :class="{ 'is-active': themeMode === THEME_TYPES.DARK }">
                  <el-icon>
                    <Moon />
                  </el-icon>
                  深色模式
                </el-dropdown-item>
                <el-dropdown-item :command="THEME_TYPES.SYSTEM"
                  :class="{ 'is-active': themeMode === THEME_TYPES.SYSTEM }" divided>
                  <el-icon>
                    <Setting />
                  </el-icon>
                  跟随系统
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>

          <el-button type="text" @click="openGitHub" class="github-btn" title="访问 GitHub">
            <svg class="github-icon" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
              <path d="M950.930286 512q0 143.433143-83.748571 257.974857t-216.283429 158.573714q-15.433143 2.852571-22.601143-4.022857t-7.168-17.115429l0-120.539429q0-55.442286-29.696-81.115429 32.548571-3.437714 58.587429-10.313143t53.686857-22.308571 46.299429-38.034286 30.281143-59.977143 11.702857-86.016q0-69.12-45.129143-117.686857 21.138286-52.004571-4.534857-116.589714-16.018286-5.12-46.299429 6.290286t-52.589714 25.161143l-21.723429 13.677714q-53.174857-14.848-109.714286-14.848t-109.714286 14.848q-9.142857-6.290286-24.283429-15.433143t-47.689143-22.016-49.152-7.68q-25.161143 64.585143-4.022857 116.589714-45.129143 48.566857-45.129143 117.686857 0 48.566857 11.702857 85.723429t29.988571 59.977143 46.006857 38.253714 53.686857 22.308571 58.587429 10.313143q-22.820571 20.553143-28.013714 58.88-11.995429 5.705143-25.746286 8.557714t-32.548571 2.852571-37.449143-12.288-31.744-35.693714q-10.825143-18.285714-27.721143-29.696t-28.306286-13.677714l-11.410286-1.682286q-11.995429 0-16.603429 2.56t-2.852571 6.582857 5.12 7.972571 7.460571 6.875429l4.022857 2.852571q12.580571 5.705143 24.868571 21.723429t17.993143 29.110857l5.705143 13.165714q7.460571 21.723429 25.161143 35.108571t38.253714 17.115429 39.716571 4.022857 31.744-1.974857l13.165714-2.267429q0 21.723429 0.292571 50.834286t0.292571 30.866286q0 10.313143-7.460571 17.115429t-22.820571 4.022857q-132.534857-44.032-216.283429-158.573714t-83.748571-257.974857q0-119.442286 58.88-220.306286t159.744-159.744 220.306286-58.88 220.306286 58.88 159.744 159.744 58.88 220.306286z" />
            </svg>
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
  background-color: var(--el-bg-color-overlay);
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
  height: 42px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--el-bg-color);
  padding: 10px;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.logo-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  margin-right: 12px;
  border-radius: 6px;
  background: transparent;
  transition: all 0.3s ease;
  overflow: hidden;
}

.logo-image {
  width: 100%;
  height: 100%;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.logo-text {
  color: var(--el-text-color-primary);
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
  cursor: pointer;
  position: relative;
  z-index: 10;
}

.github-btn:hover {
  color: var(--el-color-primary);
  background-color: var(--el-color-primary-light-9);
}

.github-icon {
  width: 16px;
  height: 16px;
  margin-right: 6px;
  fill: var(--el-text-color-regular);
  transition: all 0.3s ease;
}

.github-btn:hover .github-icon {
  fill: var(--el-color-primary);
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
