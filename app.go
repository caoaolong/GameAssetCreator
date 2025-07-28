package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"fmt"
	"image"
	"image/draw"
	"image/gif"
	"image/png"
	"io"
	"os"
	"path/filepath"
	"strconv"

	"github.com/wailsapp/wails/v2/pkg/runtime"
)

// App struct
type App struct {
	ctx context.Context
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// Greet returns a greeting for the given name
func (a *App) Greet(name string) string {
	return fmt.Sprintf("Hello %s, It's show time!", name)
}

// GetSystemTheme returns the current system theme (light or dark)
func (a *App) GetSystemTheme() string {
	// 在 Wails 中，我们可以通过前端来检测系统主题
	// 这里返回一个占位符，实际检测在前端进行
	return "system"
}

// SetTheme sets the application theme
func (a *App) SetTheme(theme string) {
	// 设置应用主题，这里只是返回成功
	// 实际的主题切换在前端处理
	fmt.Printf("设置主题: %s\n", theme)
}

// GetTheme returns the current application theme
func (a *App) GetTheme() string {
	// 获取当前应用主题，暂时返回 light
	return "light"
}

// SelectDirectory opens a directory selection dialog and returns the selected path
func (a *App) SelectDirectory() string {
	// 打开目录选择对话框
	selectedPath, err := runtime.OpenDirectoryDialog(a.ctx, runtime.OpenDialogOptions{
		Title: "选择序列帧输出目录",
	})

	if err != nil {
		fmt.Printf("选择目录时出错: %v\n", err)
		return ""
	}

	return selectedPath
}

// SelectGifFile opens a file selection dialog and returns the selected GIF file path
func (a *App) SelectGifFile() string {
	// 打开文件选择对话框，只允许选择 GIF 文件
	selectedPath, err := runtime.OpenFileDialog(a.ctx, runtime.OpenDialogOptions{
		Title: "选择GIF文件",
		Filters: []runtime.FileFilter{
			{
				DisplayName: "GIF文件 (*.gif)",
				Pattern:     "*.gif",
			},
		},
	})

	if err != nil {
		fmt.Printf("选择GIF文件时出错: %v\n", err)
		return ""
	}

	return selectedPath
}

// GetImageBase64 reads an image file and returns its base64 encoded data
func (a *App) GetImageBase64(imagePath string) string {
	// 读取图片文件
	file, err := os.Open(imagePath)
	if err != nil {
		fmt.Printf("无法打开图片文件: %v\n", err)
		return ""
	}
	defer file.Close()

	// 读取文件内容
	content, err := io.ReadAll(file)
	if err != nil {
		fmt.Printf("无法读取图片文件: %v\n", err)
		return ""
	}

	// 编码为base64
	encoded := base64.StdEncoding.EncodeToString(content)

	// 返回data URL格式
	return "data:image/png;base64," + encoded
}

// ExtractFrames extracts frames from a GIF file and returns base64 data
func (a *App) ExtractFrames(gifPath, frameName string, frameSkip int) map[string]interface{} {
	result := map[string]interface{}{
		"success":         false,
		"message":         "",
		"frames":          []interface{}{},
		"totalFrames":     0,
		"extractedFrames": 0,
	}

	// 检查输入文件是否存在
	if _, err := os.Stat(gifPath); os.IsNotExist(err) {
		result["message"] = "GIF文件不存在"
		return result
	}

	// 打开 GIF 文件
	gifFile, err := os.Open(gifPath)
	if err != nil {
		result["message"] = "无法打开GIF文件"
		return result
	}
	defer gifFile.Close()

	// 解码 GIF
	g, err := gif.DecodeAll(gifFile)
	if err != nil {
		result["message"] = "无法解码GIF文件"
		return result
	}

	totalFrames := len(g.Image)
	result["totalFrames"] = totalFrames

	// 提取每一帧并生成 base64 数据
	var extractedFrames []interface{}
	extractedCount := 0

	for i := 0; i < totalFrames; i += frameSkip {
		// 为每个提取的帧重新计算累积效果
		accumulatedImage := image.NewRGBA(g.Image[0].Bounds())

		// 从第一帧累积到当前帧
		for j := 0; j <= i; j++ {
			currentFrame := g.Image[j]
			disposalMethod := g.Disposal[j]

			if j == 0 {
				// 第一帧直接绘制
				draw.Draw(accumulatedImage, accumulatedImage.Bounds(), currentFrame, image.Point{}, draw.Over)
			} else {
				// 根据处置方法处理
				switch disposalMethod {
				case gif.DisposalNone:
					// 不清除背景，直接绘制新帧
					draw.Draw(accumulatedImage, accumulatedImage.Bounds(), currentFrame, image.Point{}, draw.Over)
				case gif.DisposalBackground:
					// 清除背景色，然后绘制新帧
					// 这里简化处理，直接绘制新帧
					draw.Draw(accumulatedImage, accumulatedImage.Bounds(), currentFrame, image.Point{}, draw.Over)
				case gif.DisposalPrevious:
					// 恢复到前一帧，然后绘制新帧
					// 这里简化处理，直接绘制新帧
					draw.Draw(accumulatedImage, accumulatedImage.Bounds(), currentFrame, image.Point{}, draw.Over)
				default:
					// 默认行为
					draw.Draw(accumulatedImage, accumulatedImage.Bounds(), currentFrame, image.Point{}, draw.Over)
				}
			}
		}

		// 生成文件名
		frameNumber := strconv.Itoa(i + 1)
		// 补齐数字位数，确保排序正确
		if i < 9 {
			frameNumber = "00" + frameNumber
		} else if i < 99 {
			frameNumber = "0" + frameNumber
		}

		fileName := frameName + frameNumber + ".png"

		// 将图像编码为 PNG 格式的 base64
		var buf bytes.Buffer
		err = png.Encode(&buf, accumulatedImage)
		if err != nil {
			result["message"] = "无法编码PNG数据"
			return result
		}

		// 编码为base64
		encoded := base64.StdEncoding.EncodeToString(buf.Bytes())
		base64Data := "data:image/png;base64," + encoded

		// 估算文件大小（base64编码会增加约33%的大小）
		estimatedSize := float64(buf.Len()) / 1024.0

		extractedFrames = append(extractedFrames, map[string]interface{}{
			"name":    fileName,
			"preview": base64Data,
			"size":    fmt.Sprintf("%.1fKB", estimatedSize),
			"index":   i,
			"id":      fmt.Sprintf("frame_%d", i), // 唯一ID用于删除
		})

		extractedCount++
	}

	result["success"] = true
	result["message"] = fmt.Sprintf("成功提取 %d 帧", extractedCount)
	result["frames"] = extractedFrames
	result["extractedFrames"] = extractedCount

	return result
}

// ExportFrames saves frames as PNG files to the specified directory
func (a *App) ExportFrames(frames []interface{}, outputDir, frameName string) map[string]interface{} {
	result := map[string]interface{}{
		"success":       false,
		"message":       "",
		"exportedCount": 0,
	}

	// 检查输出目录是否存在，如果不存在则创建
	if _, err := os.Stat(outputDir); os.IsNotExist(err) {
		err = os.MkdirAll(outputDir, 0755)
		if err != nil {
			result["message"] = "无法创建输出目录"
			return result
		}
	}

	exportedCount := 0
	for _, frameData := range frames {
		frame := frameData.(map[string]interface{})
		preview := frame["preview"].(string)
		originalIndex := frame["index"].(int)

		// 使用用户配置的序列帧名称重新生成文件名
		frameNumber := strconv.Itoa(originalIndex + 1)
		// 补齐数字位数，确保排序正确
		if originalIndex < 9 {
			frameNumber = "00" + frameNumber
		} else if originalIndex < 99 {
			frameNumber = "0" + frameNumber
		}

		fileName := frameName + frameNumber + ".png"

		// 从 base64 数据中提取图片数据
		base64Data := preview[22:] // 移除 "data:image/png;base64," 前缀
		imageData, err := base64.StdEncoding.DecodeString(base64Data)
		if err != nil {
			fmt.Printf("无法解码图片数据: %v\n", err)
			continue
		}

		// 保存文件
		filePath := filepath.Join(outputDir, fileName)
		err = os.WriteFile(filePath, imageData, 0644)
		if err != nil {
			fmt.Printf("无法保存文件 %s: %v\n", fileName, err)
			continue
		}

		exportedCount++
	}

	result["success"] = true
	result["message"] = fmt.Sprintf("成功导出 %d 帧到 %s", exportedCount, outputDir)
	result["exportedCount"] = exportedCount

	return result
}
