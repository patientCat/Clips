import SwiftUI

struct HelpView: View {
    private var theme: ThemeColors { Theme.current }
    
    var body: some View {
        VStack(spacing: 0) {
            GlassSectionHeader(
                title: "帮助与快捷键",
                count: nil,
                actionTitle: nil,
                action: nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 快捷键部分
                    shortcutsSection
                    
                    Divider()
                        .background(GlassmorphismTheme.border)
                    
                    // 功能介绍部分
                    featuresSection
                    
                    Divider()
                        .background(GlassmorphismTheme.border)
                    
                    // 使用技巧
                    tipsSection
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - 快捷键部分
    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("⌨️ 快捷键")
            
            shortcutRow(keys: "⌘ ⇧ V", description: "呼出/隐藏快捷面板（全局快捷键）")
            shortcutRow(keys: "⌘ W", description: "关闭当前窗口")
            shortcutRow(keys: "⌘ Q", description: "退出应用")
            shortcutRow(keys: "⌘ H", description: "隐藏应用")
            shortcutRow(keys: "⌘ M", description: "最小化窗口到 Dock")
        }
    }
    
    // MARK: - 功能介绍部分
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("📋 功能介绍")
            
            featureRow(
                icon: "doc.on.clipboard",
                title: "CLIPS - 剪贴板历史",
                description: "自动记录复制的文本和图片，点击即可快速复制使用"
            )
            
            featureRow(
                icon: "star.fill",
                title: "FAVS - 收藏夹",
                description: "将常用的剪贴板内容加星收藏，方便随时使用"
            )
            
            featureRow(
                icon: "key",
                title: "KEYS - 键值存储",
                description: "存储常用的键值对，如 API Key、密码等快捷内容"
            )
            
            featureRow(
                icon: "curlybraces",
                title: "JSON - 格式化工具",
                description: "JSON 格式化、压缩、校验工具"
            )
            
            featureRow(
                icon: "bell",
                title: "TIMER - 休息提醒",
                description: "定时提醒休息，保护眼睛和身体健康"
            )
            
            featureRow(
                icon: "folder",
                title: "SHELF - 文件架",
                description: "临时存放文件，方便快速访问和管理"
            )
        }
    }
    
    // MARK: - 使用技巧部分
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("💡 使用技巧")
            
            tipRow("使用 ⌘⇧V 可以在任何应用中快速呼出剪贴板面板")
            tipRow("点击菜单栏图标可以打开弹出式面板")
            tipRow("点击 Dock 图标可以打开主窗口")
            tipRow("在历史记录中点击星标可以添加到收藏夹")
            tipRow("支持搜索历史记录，快速找到需要的内容")
            tipRow("应用首次运行需要授权辅助功能权限以使用全局快捷键")
        }
    }
    
    // MARK: - Helper Views
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(GlassmorphismTheme.glassFontBold(size: 16))
            .foregroundColor(GlassmorphismTheme.textPrimary)
    }
    
    private func shortcutRow(keys: String, description: String) -> some View {
        HStack(spacing: 12) {
            Text(keys)
                .font(GlassmorphismTheme.glassFontMono(size: 13))
                .foregroundColor(GlassmorphismTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(GlassmorphismTheme.primary.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(GlassmorphismTheme.primary.opacity(0.3), lineWidth: 1)
                        )
                )
                .frame(minWidth: 90)
            
            Text(description)
                .font(GlassmorphismTheme.glassFont(size: 13))
                .foregroundColor(GlassmorphismTheme.textSecondary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(GlassmorphismTheme.primary)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(GlassmorphismTheme.primary.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
                
                Text(description)
                    .font(GlassmorphismTheme.glassFont(size: 12))
                    .foregroundColor(GlassmorphismTheme.textMuted)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(GlassmorphismTheme.primary)
            Text(text)
                .font(GlassmorphismTheme.glassFont(size: 13))
                .foregroundColor(GlassmorphismTheme.textSecondary)
            Spacer()
        }
    }
}
