<template>
  <div class="sequence-frames">
    <el-row :gutter="20">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>序列帧图</span>
            </div>
          </template>
          <div class="page-content">
            <h2>GIF序列帧分离工具</h2>
            <p>上传GIF图片，自动分离为序列帧图</p>
            
            <!-- 配置区域 -->
            <el-row :gutter="16" style="margin-bottom: 16px;">
              <el-col :span="6">
                <el-card shadow="hover" size="small">
                  <template #header>
                    <span style="font-size: 12px;">上传GIF</span>
                  </template>
                  <div class="upload-section">
                    <el-button 
                      size="small" 
                      type="primary" 
                      @click="selectGifFile"
                      style="width: 100%; margin-bottom: 8px;"
                    >
                      <el-icon><UploadFilled /></el-icon>
                      选择GIF文件
                    </el-button>
                    <div v-if="selectedFile" class="file-info">
                      <span style="font-size: 11px; color: var(--el-color-success);">✓ {{ selectedFile.name }}</span>
                    </div>
                  </div>
                </el-card>
              </el-col>
              
              <el-col :span="6">
                <el-card shadow="hover" size="small">
                  <template #header>
                    <span style="font-size: 12px;">输出目录</span>
                  </template>
                  <div class="output-section">
                    <el-button size="small" type="primary" @click="selectOutputDir" style="width: 100%; margin-bottom: 8px;">
                      <el-icon><FolderOpened /></el-icon>
                      选择目录
                    </el-button>
                    <div class="output-path">
                      <span class="path-text">{{ outputPath }}</span>
                    </div>
                  </div>
                </el-card>
              </el-col>
              
              <el-col :span="6">
                <el-card shadow="hover" size="small">
                  <template #header>
                    <span style="font-size: 12px;">跳帧数</span>
                  </template>
                  <div class="frame-skip-section">
                    <el-input-number
                      v-model="frameSkip"
                      :min="1"
                      :max="50"
                      size="small"
                      style="width: 100%;"
                      placeholder="每隔多少帧提取"
                    />
                    <div class="skip-tip">
                      <span style="font-size: 11px; color: var(--el-text-color-placeholder);">默认: 12帧</span>
                    </div>
                  </div>
                </el-card>
              </el-col>
              
              <el-col :span="6">
                <el-card shadow="hover" size="small">
                  <template #header>
                    <span style="font-size: 12px;">序列帧名称</span>
                  </template>
                  <div class="name-section">
                    <el-input
                      v-model="frameName"
                      size="small"
                      placeholder="如: frame_"
                      style="width: 100%; margin-bottom: 8px;"
                    />
                    <div class="name-tip">
                      <span style="font-size: 11px; color: var(--el-text-color-placeholder);">示例: frame_001.png</span>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
            
            <!-- 操作按钮 -->
            <el-row style="margin-bottom: 16px;">
              <el-col :span="24">
                <el-button 
                  type="primary" 
                  :disabled="!selectedFile"
                  @click="extractFrames"
                  style="margin-right: 12px;"
                >
                  <el-icon><VideoPlay /></el-icon>
                  开始分离
                </el-button>
                <el-button 
                  v-if="frameList.length > 0" 
                  type="success" 
                  @click="exportFrames"
                >
                  <el-icon><Download /></el-icon>
                  导出所有帧
                </el-button>
              </el-col>
            </el-row>
            
            <!-- 序列帧显示区域 -->
            <el-row :gutter="20">
              <el-col :span="24">
                <el-card shadow="hover">
                  <template #header>
                    <div class="frames-header">
                      <span>分离的序列帧 ({{ frameList.length }} 帧)</span>
                      <div v-if="frameList.length > 0" class="frame-stats">
                        <span style="font-size: 12px; color: var(--el-text-color-placeholder);">
                          跳帧数: {{ frameSkip }} | 总帧数: {{ totalFrames }}
                        </span>
                      </div>
                    </div>
                  </template>
                  
                  <div class="frames-container">
                    <div v-if="frameList.length === 0" class="no-frames">
                      <el-icon><PictureFilled /></el-icon>
                      <p>暂无序列帧，请先上传GIF文件并点击开始分离</p>
                    </div>
                    <div v-else class="frames-grid">
                      <div 
                        v-for="(frame, index) in frameList" 
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
              </el-col>
            </el-row>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { 
  UploadFilled, 
  FolderOpened, 
  Download, 
  PictureFilled,
  VideoPlay,
  Delete
} from '@element-plus/icons-vue'
import { SelectDirectory, SelectGifFile, ExtractFrames, ExportFrames } from '../../wailsjs/go/main/App'

const selectedFile = ref(null)
const outputPath = ref('/Users/admin/Documents/GameAssets/Frames')
const frameSkip = ref(12)
const frameName = ref('frame_')
const frameList = ref([])
const totalFrames = ref(0)

// 删除和撤销功能的状态
const deletedFrames = ref([]) // 存储被删除的帧
const undoStack = ref([]) // 撤销栈

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
  padding: 20px;
}

.card-header {
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.page-content h2 {
  color: var(--el-color-primary);
  margin-bottom: 16px;
}

.page-content p {
  color: var(--el-text-color-regular);
  margin-bottom: 24px;
}

.upload-section {
  padding: 12px;
}

.file-info {
  margin-top: 8px;
  text-align: center;
}

.output-section {
  padding: 12px;
}

.output-path {
  margin-top: 8px;
}

.path-text {
  color: var(--el-text-color-regular);
  font-family: monospace;
  font-size: 11px;
  background-color: var(--el-fill-color-light);
  padding: 4px 8px;
  border-radius: 4px;
  border: 1px solid var(--el-border-color);
  word-break: break-all;
  line-height: 1.2;
  display: block;
}

.frame-skip-section {
  padding: 12px;
}

.skip-tip {
  margin-top: 8px;
  text-align: center;
}

.name-section {
  padding: 12px;
}

.name-tip {
  text-align: center;
}

.frames-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.frame-stats {
  display: flex;
  align-items: center;
}

.frames-container {
  min-height: 300px;
}

.no-frames {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 300px;
  color: var(--el-text-color-placeholder);
}

.no-frames .el-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.frames-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  padding: 16px;
}

.frame-item {
  width: 200px;
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  overflow: hidden;
  background-color: var(--el-bg-color);
  transition: all 0.3s ease;
}

.frame-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.frame-image {
  width: 100%;
  height: 150px;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: var(--el-fill-color-light);
}

.frame-image {
  position: relative;
}

.frame-image img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.frame-actions {
  position: absolute;
  top: 8px;
  right: 8px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.frame-item:hover .frame-actions {
  opacity: 1;
}

.delete-btn {
  background-color: rgba(255, 255, 255, 0.9);
  border: none;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.delete-btn:hover {
  background-color: var(--el-color-danger);
  color: white;
}

.frame-info {
  padding: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: var(--el-fill-color-light);
}

.frame-number {
  font-weight: bold;
  color: var(--el-text-color-primary);
  font-size: 12px;
}

.frame-size {
  color: var(--el-text-color-placeholder);
  font-size: 11px;
}
</style> 