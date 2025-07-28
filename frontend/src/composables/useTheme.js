import { ref, watch, onMounted } from 'vue'
import { GetSystemTheme, SetTheme, GetTheme } from '../../wailsjs/go/main/App'

// 主题类型
export const THEME_TYPES = {
  LIGHT: 'light',
  DARK: 'dark',
  SYSTEM: 'system'
}

// 主题管理
export function useTheme() {
  const currentTheme = ref(THEME_TYPES.LIGHT)
  const systemTheme = ref(THEME_TYPES.LIGHT)
  const themeMode = ref(THEME_TYPES.SYSTEM) // light, dark, system

  // 初始化主题
  const initTheme = async () => {
    try {
      console.log('初始化主题...')
      
      // 检测系统主题
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
      systemTheme.value = mediaQuery.matches ? THEME_TYPES.DARK : THEME_TYPES.LIGHT
      console.log('系统主题:', systemTheme.value)
      
      // 从本地存储获取用户设置的主题模式
      const savedThemeMode = localStorage.getItem('themeMode')
      if (savedThemeMode) {
        themeMode.value = savedThemeMode
        console.log('从本地存储恢复主题模式:', savedThemeMode)
      }
      
      // 根据主题模式设置当前主题
      updateCurrentTheme()
    } catch (error) {
      console.error('初始化主题失败:', error)
    }
  }

  // 更新当前主题
  const updateCurrentTheme = () => {
    console.log('更新当前主题 - 模式:', themeMode.value, '系统主题:', systemTheme.value)
    
    if (themeMode.value === THEME_TYPES.SYSTEM) {
      currentTheme.value = systemTheme.value
      console.log('跟随系统模式，设置主题为:', currentTheme.value)
    } else {
      currentTheme.value = themeMode.value
      console.log('固定模式，设置主题为:', currentTheme.value)
    }
    
    // 应用主题到 DOM
    applyTheme(currentTheme.value)
  }

  // 应用主题到 DOM
  const applyTheme = (theme) => {
    console.log('应用主题:', theme)
    const html = document.documentElement
    
    // 移除所有主题类
    html.classList.remove('light', 'dark')
    
    // 添加当前主题类
    html.classList.add(theme)
    
    // 设置 Element Plus 主题
    if (theme === THEME_TYPES.DARK) {
      html.setAttribute('data-theme', 'dark')
    } else {
      html.setAttribute('data-theme', 'light')
    }
    
    console.log('主题已应用到 DOM')
  }

  // 切换主题模式
  const setThemeMode = async (mode) => {
    if (!Object.values(THEME_TYPES).includes(mode)) {
      console.error('无效的主题模式:', mode)
      return
    }
    
    themeMode.value = mode
    
    // 保存到本地存储
    localStorage.setItem('themeMode', mode)
    
    // 更新当前主题
    updateCurrentTheme()
    
    // 通知后端
    try {
      await SetTheme(currentTheme.value)
    } catch (error) {
      console.error('设置主题失败:', error)
    }
  }

  // 监听系统主题变化
  const watchSystemTheme = () => {
    // 监听媒体查询变化
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    
    const handleChange = (e) => {
      console.log('系统主题变化:', e.matches ? 'dark' : 'light')
      systemTheme.value = e.matches ? THEME_TYPES.DARK : THEME_TYPES.LIGHT
      if (themeMode.value === THEME_TYPES.SYSTEM) {
        console.log('跟随系统模式，更新主题')
        updateCurrentTheme()
      }
    }
    
    mediaQuery.addEventListener('change', handleChange)
    
    // 初始设置
    systemTheme.value = mediaQuery.matches ? THEME_TYPES.DARK : THEME_TYPES.LIGHT
    console.log('初始系统主题:', systemTheme.value)
    
    return () => {
      mediaQuery.removeEventListener('change', handleChange)
    }
  }

  // 监听主题模式变化
  watch(themeMode, () => {
    updateCurrentTheme()
  })

  // 监听当前主题变化
  watch(currentTheme, (newTheme) => {
    applyTheme(newTheme)
  })

  // 组件挂载时初始化
  onMounted(() => {
    // 先监听系统主题，再初始化主题
    const cleanup = watchSystemTheme()
    initTheme()
    
    // 返回清理函数
    return cleanup
  })

  return {
    currentTheme,
    systemTheme,
    themeMode,
    setThemeMode,
    THEME_TYPES
  }
} 