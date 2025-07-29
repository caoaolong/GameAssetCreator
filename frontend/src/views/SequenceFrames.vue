<template>
  <div class="sequence-frames">
    <!-- 主要内容区域 -->
    <div class="content-wrapper">
      <!-- 左侧配置面板 -->
      <div class="sidebar">
        <el-card class="config-card" shadow="never">
          <template #header>
            <div class="card-title">
              <el-icon><Setting /></el-icon>
              <span>配置参数</span>
            </div>
          </template>
          
          <div class="config-form">
            <!-- 文件上传 -->
            <div class="form-item">
              <label class="form-label">选择GIF文件</label>
              <el-button 
                type="primary" 
                @click="selectGifFile" 
                :disabled="!!selectedFile"
                style="width: 100%; margin-bottom: 8px;"
              >
                <el-icon><UploadFilled /></el-icon>
                选择GIF文件
              </el-button>
              <!-- 文件选择状态 -->
              <div v-if="selectedFile" class="file-status">
                <el-tag type="success" size="large" effect="dark">
                  <el-icon><UploadFilled /></el-icon>
                  {{ selectedFile.name }}
                </el-tag>
              </div>
            </div>
            
            <!-- 输出目录 -->
            <div class="form-item">
              <label class="form-label">输出目录</label>
              <el-button 
                type="primary" 
                plain 
                @click="selectOutputDir" 
                style="width: 100%; margin-bottom: 8px;"
              >
                <el-icon><FolderOpened /></el-icon>
                选择目录
              </el-button>
              <div class="path-display">
                <el-tooltip 
                  :content="outputPath" 
                  placement="top" 
                  :show-after="500"
                  popper-class="path-tooltip"
                >
                  <span class="path-text">{{ outputPath }}</span>
                </el-tooltip>
              </div>
            </div>
            
            <!-- 跳帧数 -->
            <div class="form-item">
              <label class="form-label">跳帧数</label>
              <el-input-number
                v-model="frameSkip"
                :min="1"
                :max="50"
                style="width: 100%;"
                placeholder="每隔多少帧提取"
              />
              <div class="form-tip">默认: 12帧</div>
            </div>
            
            <!-- 序列帧名称 -->
            <div class="form-item">
              <label class="form-label">序列帧名称</label>
              <el-input
                v-model="frameName"
                placeholder="如: frame_"
                style="width: 100%;"
              />
              <div class="form-tip">示例: frame_001.png</div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="form-actions">
              <el-button 
                type="success" 
                :disabled="!selectedFile"
                @click="extractFrames"
                style="width: 100%; margin-bottom: 12px;"
              >
                <el-icon><VideoPlay /></el-icon>
                开始分离
              </el-button>
              <el-button 
                v-if="frameList.length > 0" 
                type="warning" 
                @click="exportFrames"
                style="width: 100%;"
              >
                <el-icon><Download /></el-icon>
                导出所有帧
              </el-button>
            </div>
          </div>
        </el-card>
      </div>
            
      <!-- 右侧帧显示区域 -->
      <div class="main-content">
        <el-card class="frames-card" shadow="never">
          <template #header>
            <div class="frames-header">
              <div class="header-left">
                <h2 class="frames-title">分离的序列帧</h2>
                <div class="frames-info">
                  <el-tag type="info" size="small">
                    {{ currentDisplayFrames.length }}/{{ frameList.length }} 帧
                  </el-tag>
                  <span v-if="frameList.length > 0" class="frames-stats">
                    跳帧数: {{ frameSkip }} | 总帧数: {{ totalFrames }}
                  </span>
                </div>
              </div>
              <div v-if="frameList.length > 0" class="header-right">
                <div class="range-selector">
                  <span class="range-label">显示范围</span>
                  <el-slider
                    v-model="frameRange"
                    :min="0"
                    :max="frameList.length - 1"
                    range
                    :show-tooltip="false"
                    style="width: 180px; margin: 0 12px;"
                    @change="handleRangeChange"
                  />
                  <el-tag type="primary" size="small">
                    {{ frameRange[0] + 1 }} - {{ frameRange[1] + 1 }}
                  </el-tag>
                </div>
              </div>
            </div>
          </template>
          
          <div class="frames-container">
            <div v-if="frameList.length === 0" class="empty-state">
              <div class="empty-content">
                <el-icon class="empty-icon"><PictureFilled /></el-icon>
                <h3>暂无序列帧</h3>
                <p>请先上传GIF文件并点击开始分离</p>
              </div>
            </div>
            <div v-else class="frames-grid">
              <div 
                v-for="(frame, index) in currentDisplayFrames" 
                :key="frame.id"
                class="frame-item"
              >
                <div class="frame-image">
                  <img :src="frame.preview" :alt="frame.name" />
                  <div class="frame-actions">
                    <el-button 
                      size="small" 
                      type="danger" 
                      circle
                      @click="deleteFrame(frame.id)"
                      class="delete-btn"
                    >
                      <el-icon><Delete /></el-icon>
                    </el-button>
                  </div>
                </div>
                <div class="frame-info">
                  <span class="frame-number">{{ frame.name }}</span>
                  <span class="frame-size">{{ frame.size }}</span>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { 
  UploadFilled, 
  FolderOpened, 
  Download, 
  PictureFilled,
  VideoPlay,
  Delete,
  Setting
} from '@element-plus/icons-vue'
import { SelectDirectory, SelectGifFile, ExtractFrames, ExportFrames } from '../../wailsjs/go/main/App'

const selectedFile = ref(null)
const outputPath = ref('/Users/admin/Documents/GameAssets/Frames')
const frameSkip = ref(12)
const frameName = ref('frame_')
const frameList = ref([])
const totalFrames = ref(0)

// 范围选择相关状态
const frameRange = ref([0, 0]) // [最小值, 最大值]
const displayFrames = ref([]) // 当前显示的帧列表

// 删除和撤销功能的状态
const deletedFrames = ref([]) // 存储被删除的帧
const undoStack = ref([]) // 撤销栈

// 计算当前显示的帧
const currentDisplayFrames = computed(() => {
  if (frameList.value.length === 0) return []
  
  const [start, end] = frameRange.value
  return frameList.value.slice(start, end + 1)
})

// 监听帧列表变化，更新范围
watch(frameList, (newFrames) => {
  if (newFrames.length > 0) {
    frameRange.value = [0, newFrames.length - 1]
  } else {
    frameRange.value = [0, 0]
  }
}, { immediate: true })

const selectGifFile = async () => {
  try {
    // 调用后端的文件选择对话框
    const selectedPath = await SelectGifFile()
    
    if (selectedPath) {
      // 从路径中提取文件名
      const fileName = selectedPath.split('/').pop() || selectedPath.split('\\').pop()
      selectedFile.value = {
        name: fileName,
        path: selectedPath
      }
      console.log('选择的GIF文件:', selectedPath)
      // 清空之前的帧列表
      frameList.value = []
    } else {
      console.log('用户取消了文件选择')
    }
  } catch (error) {
    console.error('选择GIF文件时出错:', error)
  }
}

const selectOutputDir = async () => {
  try {
    // 调用后端的目录选择对话框
    const selectedPath = await SelectDirectory()
    
    if (selectedPath) {
      outputPath.value = selectedPath
      console.log('选择的输出目录:', selectedPath)
    } else {
      console.log('用户取消了目录选择')
    }
  } catch (error) {
    console.error('选择目录时出错:', error)
    // 可以在这里添加错误提示
  }
}

const extractFrames = async () => {
  if (!selectedFile.value) return
  
  console.log('开始分离帧，参数:', {
    file: selectedFile.value.name,
    filePath: selectedFile.value.path,
    frameSkip: frameSkip.value,
    frameName: frameName.value
  })
  
  try {
    // 调用后端的帧分离方法
    const result = await ExtractFrames(
      selectedFile.value.path,
      frameName.value,
      frameSkip.value
    )
    
    if (result.success) {
      // 更新帧列表（后端已经返回了 base64 数据）
      frameList.value = result.frames
      totalFrames.value = result.totalFrames
      
      // 清空删除和撤销状态
      deletedFrames.value = []
      undoStack.value = []
      
      console.log('分离完成:', result.message)
      console.log('提取的帧数:', result.extractedFrames)
      
      // 可以在这里添加成功提示
    } else {
      console.error('分离失败:', result.message)
      // 可以在这里添加错误提示
    }
  } catch (error) {
    console.error('分离帧时出错:', error)
    // 可以在这里添加错误提示
  }
}



// 删除帧
const deleteFrame = (frameId) => {
  const frameIndex = frameList.value.findIndex(frame => frame.id === frameId)
  if (frameIndex !== -1) {
    const deletedFrame = frameList.value.splice(frameIndex, 1)[0]
    deletedFrames.value.push(deletedFrame)
    
    // 添加到撤销栈
    undoStack.value.push({
      action: 'delete',
      frame: deletedFrame,
      index: frameIndex
    })
    
    // 调整范围，确保范围有效
    if (frameList.value.length > 0) {
      const maxIndex = frameList.value.length - 1
      if (frameRange.value[1] > maxIndex) {
        frameRange.value[1] = maxIndex
      }
      if (frameRange.value[0] > maxIndex) {
        frameRange.value[0] = maxIndex
      }
    } else {
      frameRange.value = [0, 0]
    }
    
    console.log('删除帧:', deletedFrame.name)
  }
}

// 撤销删除
const undoDelete = () => {
  if (undoStack.value.length > 0) {
    const lastAction = undoStack.value.pop()
    if (lastAction.action === 'delete') {
      // 将删除的帧重新插入到原来的位置
      frameList.value.splice(lastAction.index, 0, lastAction.frame)
      
      // 从删除列表中移除
      const deleteIndex = deletedFrames.value.findIndex(frame => frame.id === lastAction.frame.id)
      if (deleteIndex !== -1) {
        deletedFrames.value.splice(deleteIndex, 1)
      }
      
      console.log('撤销删除帧:', lastAction.frame.name)
    }
  }
}

// 键盘快捷键处理
const handleKeydown = (event) => {
  // Ctrl+Z (Windows) 或 Command+Z (Mac)
  if ((event.ctrlKey || event.metaKey) && event.key === 'z') {
    event.preventDefault()
    undoDelete()
  }
}

// 处理范围变化
const handleRangeChange = (value) => {
  console.log('范围变化:', value)
  // 这里可以添加额外的逻辑，比如保存用户偏好等
}

// 监听键盘事件
onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})

// 导出帧
const exportFrames = async () => {
  if (frameList.value.length === 0) {
    console.log('没有可导出的帧')
    return
  }
  
  try {
    console.log('开始导出帧到:', outputPath.value)
    
    // 调用后端的导出方法
    const result = await ExportFrames(frameList.value, outputPath.value, frameName.value)
    
    if (result.success) {
      console.log('导出完成:', result.message)
      console.log('导出的帧数:', result.exportedCount)
      // 可以在这里添加成功提示
    } else {
      console.error('导出失败:', result.message)
      // 可以在这里添加错误提示
    }
  } catch (error) {
    console.error('导出帧时出错:', error)
    // 可以在这里添加错误提示
  }
}
</script>

<style scoped>
.sequence-frames {
  min-height: 100vh;
  background-color: var(--el-bg-color-page);
}

.content-wrapper {
  display: flex;
  gap: 24px;
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
  min-height: 100vh;
}

.sidebar {
  width: 320px;
  flex-shrink: 0;
}

.config-card {
  border-radius: 8px;
  border: 1px solid var(--el-border-color-light);
  height: fit-content;
  position: sticky;
  top: 120px;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.card-title .el-icon {
  font-size: 16px;
  color: var(--el-color-primary);
}

.config-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.file-status {
  text-align: center;
  padding: 8px 0;
}

.form-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
}

.form-tip {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
  text-align: center;
}

.form-actions {
  margin-top: 8px;
}

.path-display {
  margin-top: 8px;
}

.path-text {
  color: var(--el-text-color-regular);
  font-family: monospace;
  font-size: 12px;
  background-color: var(--el-fill-color-light);
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid var(--el-border-color-light);
  line-height: 1.3;
  display: block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  cursor: pointer;
  transition: all 0.3s ease;
}

.path-text:hover {
  background-color: var(--el-fill-color);
  border-color: var(--el-color-primary-light-5);
}

.main-content {
  flex: 1;
  min-width: 0;
}

.frames-card {
  border-radius: 8px;
  border: 1px solid var(--el-border-color-light);
  height: 100%;
}

.frames-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.frames-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0;
}

.frames-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.frames-stats {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
}

.header-right {
  display: flex;
  align-items: center;
}

.range-selector {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--el-fill-color-light);
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid var(--el-border-color-light);
}

.range-label {
  font-size: 12px;
  font-weight: 500;
  color: var(--el-text-color-regular);
  white-space: nowrap;
}

.frames-container {
  min-height: 500px;
  padding: 20px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 500px;
}

.empty-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  color: var(--el-text-color-placeholder);
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
  color: var(--el-fill-color);
}

.empty-content h3 {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: var(--el-text-color-regular);
}

.empty-content p {
  font-size: 14px;
  margin: 0;
  color: var(--el-text-color-placeholder);
}

.frames-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 16px;
}

.frame-item {
  border: 1px solid var(--el-border-color-light);
  border-radius: 8px;
  overflow: hidden;
  background-color: var(--el-bg-color);
  transition: all 0.3s ease;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.frame-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
  border-color: var(--el-color-primary-light-5);
}

.frame-image {
  width: 100%;
  height: 140px;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: var(--el-fill-color-light);
  position: relative;
  overflow: hidden;
}

.frame-image img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  transition: transform 0.3s ease;
}

.frame-item:hover .frame-image img {
  transform: scale(1.02);
}

.frame-actions {
  position: absolute;
  top: 8px;
  right: 8px;
  opacity: 0;
  transition: all 0.3s ease;
  transform: scale(0.8);
}

.frame-item:hover .frame-actions {
  opacity: 1;
  transform: scale(1);
}

.delete-btn {
  background-color: rgba(255, 255, 255, 0.9);
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.delete-btn:hover {
  background-color: var(--el-color-danger);
  color: white;
  transform: scale(1.05);
}

.frame-info {
  padding: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: var(--el-bg-color);
  border-top: 1px solid var(--el-border-color-light);
}

.frame-number {
  font-weight: 500;
  color: var(--el-text-color-primary);
  font-size: 12px;
}

.frame-size {
  color: var(--el-text-color-placeholder);
  font-size: 11px;
  background: var(--el-fill-color-light);
  padding: 2px 6px;
  border-radius: 4px;
}

/* 全局样式，用于自定义 tooltip */
:global(.path-tooltip) {
  max-width: 400px !important;
  word-break: break-all !important;
  font-family: monospace !important;
  font-size: 12px !important;
  line-height: 1.4 !important;
}
</style> 