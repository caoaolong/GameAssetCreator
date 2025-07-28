<template>
  <div class="home-page">
    <!-- 主要内容区域 -->
    <div class="hero-section">
      <div class="hero-content">
        <!-- Logo 和标题区域 -->
        <div class="brand-section">
          <div class="logo-container">
            <el-image 
              :src="logoImage" 
              alt="GameAssetCreator Logo" 
              class="hero-logo"
              fit="contain"
            />
          </div>
          <h1 class="app-title">GameAssetCreator</h1>
          <p class="app-subtitle">专注于打造独立开发者的瑞士军刀！</p>
          <div class="version-info">
            <el-tag v-if="!versionLoading" type="info" size="small" class="version-tag">
              v{{ version }}
            </el-tag>
            <el-skeleton v-else :rows="1" animated class="version-skeleton" />
          </div>
        </div>

        <!-- 功能介绍区域 -->
        <div class="features-section">
          <el-row :gutter="24">
            <el-col :span="8">
              <div class="feature-card">
                <el-icon class="feature-icon"><Picture /></el-icon>
                <h3>序列帧分离</h3>
                <p>快速将 GIF 动画分离为序列帧图片，支持跳帧提取和批量导出</p>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="feature-card">
                <el-icon class="feature-icon"><Tools /></el-icon>
                <h3>游戏资源处理</h3>
                <p>专业的游戏资源处理工具，为独立开发者提供完整的解决方案</p>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="feature-card">
                <el-icon class="feature-icon"><Star /></el-icon>
                <h3>高效便捷</h3>
                <p>简洁直观的界面设计，让资源处理变得简单高效</p>
              </div>
            </el-col>
          </el-row>
        </div>


      </div>
    </div>

    <!-- 打赏区域 -->
    <div class="donation-section">
      <el-card class="donation-card">
        <template #header>
          <div class="donation-header">
            <el-icon><Star /></el-icon>
            <span>支持开发者</span>
          </div>
        </template>
        
        <div class="donation-content">
          <div class="donation-text">
            <h3>如果这个工具对你有帮助</h3>
            <p>请考虑给开发者一些支持，让这个项目能够持续发展下去</p>
          </div>
          
          <div class="qr-code-container">
            <el-image 
              :src="wechatQRCode" 
              alt="微信收款二维码" 
              class="qr-code"
              fit="contain"
            />
            <p class="qr-tip">微信扫码打赏</p>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Picture, Tools, Star } from '@element-plus/icons-vue'
import logoImage from '../assets/images/logo.png'
import wechatQRCode from '../assets/images/wechat-payment-code.jpg'

const version = ref('')
const versionLoading = ref(true)

// 读取版本号
const loadVersion = async () => {
  try {
    const response = await fetch('/.version')
    if (response.ok) {
      const versionText = await response.text()
      version.value = versionText.trim()
    } else {
      version.value = '1.0.0'
    }
  } catch (error) {
    console.warn('无法读取版本文件，使用默认版本号:', error)
    version.value = '1.0.0'
  } finally {
    versionLoading.value = false
  }
}

onMounted(() => {
  loadVersion()
})
</script>

<style scoped>
.home-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.hero-section {
  background: linear-gradient(135deg, var(--el-color-primary-light-9) 0%, var(--el-color-primary-light-8) 100%);
  border-radius: 16px;
  padding: 60px 40px;
  margin-bottom: 40px;
  text-align: center;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.hero-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 30% 20%, rgba(64, 158, 255, 0.1) 0%, transparent 50%),
              radial-gradient(circle at 70% 80%, rgba(64, 158, 255, 0.05) 0%, transparent 50%);
  pointer-events: none;
}

.hero-content {
  max-width: 1000px;
  margin: 0 auto;
  position: relative;
  z-index: 1;
}

.brand-section {
  margin-bottom: 60px;
}

.logo-container {
  margin-bottom: 24px;
}

.hero-logo {
  width: 120px;
  height: 120px;
  margin: 0 auto;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.1));
  transition: all 0.3s ease;
}

.hero-logo:hover {
  transform: scale(1.05);
  filter: drop-shadow(0 6px 12px rgba(0, 0, 0, 0.15));
}

.app-title {
  font-size: 3.5rem;
  font-weight: 700;
  color: var(--el-color-primary);
  margin: 0 0 16px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  letter-spacing: -0.02em;
}

.app-subtitle {
  font-size: 1.5rem;
  color: var(--el-text-color-regular);
  margin: 0 0 20px 0;
  font-weight: 400;
  opacity: 0.9;
}

.version-info {
  margin-bottom: 40px;
}

.version-tag {
  font-size: 0.9rem;
  padding: 6px 16px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.9);
  color: var(--el-color-primary);
  border: 1px solid var(--el-color-primary-light-7);
  font-weight: 500;
  backdrop-filter: blur(10px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.version-skeleton {
  width: 80px;
  margin: 0 auto;
}

.features-section {
  margin-bottom: 60px;
}

.feature-card {
  text-align: center;
  padding: 32px 24px;
  background: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  height: 100%;
}

.feature-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.feature-icon {
  font-size: 3rem;
  color: var(--el-color-primary);
  margin-bottom: 20px;
  display: block;
}

.feature-card h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0 0 16px 0;
}

.feature-card p {
  color: var(--el-text-color-regular);
  line-height: 1.6;
  margin: 0;
  font-size: 1rem;
}

.donation-section {
  margin-top: 40px;
}

.donation-card {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.donation-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
}

.donation-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--el-color-warning);
}

.donation-header .el-icon {
  font-size: 1.4rem;
}

.donation-content {
  display: flex;
  align-items: center;
  gap: 40px;
  padding: 20px 0;
}

.donation-text {
  flex: 1;
}

.donation-text h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0 0 12px 0;
}

.donation-text p {
  color: var(--el-text-color-regular);
  line-height: 1.6;
  margin: 0;
  font-size: 1rem;
}

.qr-code-container {
  text-align: center;
  flex-shrink: 0;
}

.qr-code {
  width: 200px;
  height: 200px;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  margin-bottom: 12px;
  transition: all 0.3s ease;
}

.qr-code:hover {
  transform: scale(1.02);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.qr-tip {
  color: var(--el-text-color-regular);
  font-size: 0.9rem;
  margin: 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .hero-section {
    padding: 40px 20px;
  }
  
  .app-title {
    font-size: 2.5rem;
  }
  
  .app-subtitle {
    font-size: 1.2rem;
  }
  
  .donation-content {
    flex-direction: column;
    gap: 24px;
  }
  
  .qr-code {
    width: 150px;
    height: 150px;
  }
}

@media (max-width: 480px) {
  .app-title {
    font-size: 2rem;
  }
  
  .app-subtitle {
    font-size: 1rem;
  }
  
  .feature-card {
    padding: 24px 16px;
  }
  
  .feature-icon {
    font-size: 2.5rem;
  }
}
</style> 