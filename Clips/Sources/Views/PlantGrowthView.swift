import SwiftUI

struct PlantGrowthView: View {
    @ObservedObject var store: PlantGrowthStore
    @State private var showPlantPicker = false
    @State private var animateGrowth = false
    @State private var showCelebration = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            GlassSectionHeader(
                title: "种花养成",
                count: store.gardenHistory.count,
                actionTitle: store.currentPlant != nil ? "重置" : nil,
                action: { store.reset() }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    if let plant = store.currentPlant {
                        // 当前植物展示
                        currentPlantView(plant)
                        
                        // 资源统计
                        resourcesView(plant)
                        
                        // 操作按钮
                        actionsView(plant)
                        
                        // 成长进度
                        progressView(plant)
                        
                    } else {
                        // 没有植物时显示选择界面
                        plantSelectionView
                    }
                    
                    // 花园历史
                    if !store.gardenHistory.isEmpty {
                        gardenHistoryView
                    }
                    
                    // 使用说明
                    instructionsView
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
            }
        }
        .sheet(isPresented: $showPlantPicker) {
            plantPickerSheet
        }
    }
    
    // MARK: - Current Plant View
    
    private func currentPlantView(_ plant: PlantState) -> some View {
        VStack(spacing: 12) {
            // 植物展示区
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.1),
                                Color.yellow.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(GlassmorphismTheme.border, lineWidth: 1)
                    )
                
                VStack(spacing: 8) {
                    // 植物emoji
                    Text(plant.currentEmoji)
                        .font(.system(size: 80))
                        .scaleEffect(animateGrowth ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatCount(3), value: animateGrowth)
                    
                    // 植物名称
                    Text(plant.plantType.rawValue)
                        .font(GlassmorphismTheme.glassFontBold(size: 16))
                        .foregroundColor(GlassmorphismTheme.textPrimary)
                    
                    // 成长阶段
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index <= plant.growthStage ? GlassmorphismTheme.primary : GlassmorphismTheme.textMuted.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    if plant.isFullyGrown {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                            Text("已完全长成!")
                        }
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.primary)
                        .padding(.top, 4)
                    }
                }
                .padding(20)
            }
            .frame(height: 200)
            
            // 庆祝动画
            if showCelebration {
                HStack(spacing: 8) {
                    Text("🎉")
                    Text("恭喜! 植物成长了!")
                        .font(GlassmorphismTheme.glassFontBold(size: 14))
                        .foregroundColor(GlassmorphismTheme.primary)
                    Text("🎉")
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Resources View
    
    private func resourcesView(_ plant: PlantState) -> some View {
        HStack(spacing: 12) {
            // 阳光
            resourceCard(
                icon: "☀️",
                title: "阳光",
                current: plant.sunlight,
                total: plant.totalSunlight,
                color: .orange,
                hint: "复制获取"
            )
            
            // 水分
            resourceCard(
                icon: "💧",
                title: "水分",
                current: plant.water,
                total: plant.totalWater,
                color: .blue,
                hint: "粘贴获取"
            )
        }
    }
    
    private func resourceCard(icon: String, title: String, current: Int, total: Int, color: Color, hint: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
            }
            
            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(min(current, 10)) / 10)
                }
            }
            .frame(height: 8)
            
            Text("\(current)/10")
                .font(GlassmorphismTheme.glassFontBold(size: 16))
                .foregroundColor(current >= 10 ? color : GlassmorphismTheme.textPrimary)
            
            Text(hint)
                .font(GlassmorphismTheme.glassFont(size: 10))
                .foregroundColor(GlassmorphismTheme.textMuted)
            
            Text("累计: \(total)")
                .font(GlassmorphismTheme.glassFont(size: 10))
                .foregroundColor(GlassmorphismTheme.textMuted)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(GlassmorphismTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(GlassmorphismTheme.border, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Actions View
    
    @ViewBuilder
    private func actionsView(_ plant: PlantState) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // 晒太阳按钮
                actionButton(
                    icon: "sun.max.fill",
                    title: "晒太阳",
                    subtitle: "消耗10阳光",
                    enabled: plant.sunlight >= 10 && !plant.isFullyGrown,
                    color: .orange
                ) {
                    withAnimation {
                        store.sunPlant()
                        triggerGrowthAnimation()
                    }
                }
                
                // 浇水按钮
                actionButton(
                    icon: "drop.fill",
                    title: "浇水",
                    subtitle: "消耗10水分",
                    enabled: plant.water >= 10 && !plant.isFullyGrown,
                    color: .blue
                ) {
                    withAnimation {
                        store.waterPlant()
                        triggerGrowthAnimation()
                    }
                }
            }
            
            // 收获按钮（完全长成后显示）
            if plant.isFullyGrown {
                Button(action: {
                    withAnimation {
                        store.harvest()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                        Text("收获并种植新植物")
                    }
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [GlassmorphismTheme.primary, GlassmorphismTheme.primary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func actionButton(icon: String, title: String, subtitle: String, enabled: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(enabled ? color : GlassmorphismTheme.textMuted)
                
                Text(title)
                    .font(GlassmorphismTheme.glassFontBold(size: 13))
                    .foregroundColor(enabled ? GlassmorphismTheme.textPrimary : GlassmorphismTheme.textMuted)
                
                Text(subtitle)
                    .font(GlassmorphismTheme.glassFont(size: 10))
                    .foregroundColor(GlassmorphismTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(enabled ? color.opacity(0.1) : GlassmorphismTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(enabled ? color.opacity(0.3) : GlassmorphismTheme.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .onHover { hovering in
            if enabled {
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
        }
    }
    
    // MARK: - Progress View
    
    private func progressView(_ plant: PlantState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("成长进度")
                .font(GlassmorphismTheme.glassFontBold(size: 13))
                .foregroundColor(GlassmorphismTheme.textPrimary)
            
            HStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { index in
                    VStack(spacing: 4) {
                        Text(plant.plantType.stages[index])
                            .font(.system(size: 28))
                            .opacity(index <= plant.growthStage ? 1 : 0.3)
                        
                        Text(stageLabel(index))
                            .font(GlassmorphismTheme.glassFont(size: 10))
                            .foregroundColor(index <= plant.growthStage ? GlassmorphismTheme.textPrimary : GlassmorphismTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    
                    if index < 3 {
                        Rectangle()
                            .fill(index < plant.growthStage ? GlassmorphismTheme.primary : GlassmorphismTheme.textMuted.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: 30)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(GlassmorphismTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(GlassmorphismTheme.border, lineWidth: 1)
                )
        )
    }
    
    private func stageLabel(_ index: Int) -> String {
        switch index {
        case 0: return "种子"
        case 1: return "发芽"
        case 2: return "成长"
        case 3: return "开花"
        default: return ""
        }
    }
    
    // MARK: - Plant Selection View
    
    private var plantSelectionView: some View {
        VStack(spacing: 16) {
            GlassEmptyState(
                icon: "leaf",
                message: "开始种植",
                submessage: "选择一种植物开始养成"
            )
            
            Button(action: { showPlantPicker = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("选择植物")
                }
                .font(GlassmorphismTheme.glassFontBold(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [GlassmorphismTheme.primary, GlassmorphismTheme.primary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
        }
    }
    
    // MARK: - Plant Picker Sheet
    
    private var plantPickerSheet: some View {
        VStack(spacing: 16) {
            Text("选择要种植的植物")
                .font(GlassmorphismTheme.glassFontBold(size: 18))
                .foregroundColor(GlassmorphismTheme.textPrimary)
                .padding(.top, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PlantType.allCases, id: \.self) { plantType in
                    Button(action: {
                        store.startNewPlant(type: plantType)
                        showPlantPicker = false
                    }) {
                        VStack(spacing: 8) {
                            Text(plantType.emoji)
                                .font(.system(size: 40))
                            Text(plantType.rawValue)
                                .font(GlassmorphismTheme.glassFontBold(size: 14))
                                .foregroundColor(GlassmorphismTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(GlassmorphismTheme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(GlassmorphismTheme.border, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Button("取消") {
                showPlantPicker = false
            }
            .font(GlassmorphismTheme.glassFont(size: 14))
            .foregroundColor(GlassmorphismTheme.textMuted)
            .padding(.bottom, 20)
        }
        .frame(width: 300, height: 350)
        .background(GlassmorphismTheme.cardBackground)
    }
    
    // MARK: - Garden History View
    
    private var gardenHistoryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "leaf.circle.fill")
                    .foregroundColor(GlassmorphismTheme.primary)
                Text("我的花园")
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
                
                Spacer()
                
                Text("\(store.gardenHistory.count) 株")
                    .font(GlassmorphismTheme.glassFont(size: 12))
                    .foregroundColor(GlassmorphismTheme.textMuted)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.gardenHistory.reversed()) { plant in
                        VStack(spacing: 4) {
                            Text(plant.plantType.emoji)
                                .font(.system(size: 32))
                            Text(plant.plantType.rawValue)
                                .font(GlassmorphismTheme.glassFont(size: 10))
                                .foregroundColor(GlassmorphismTheme.textMuted)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(GlassmorphismTheme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(GlassmorphismTheme.border, lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(GlassmorphismTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(GlassmorphismTheme.border, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Instructions View
    
    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(GlassmorphismTheme.primary)
                Text("游戏说明")
                    .font(GlassmorphismTheme.glassFontBold(size: 13))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                instructionRow(icon: "☀️", text: "复制内容获得阳光")
                instructionRow(icon: "💧", text: "粘贴内容获得水分")
                instructionRow(icon: "🌞", text: "满10阳光可以晒太阳")
                instructionRow(icon: "🚿", text: "满10水分可以浇花")
                instructionRow(icon: "🌱", text: "同时浇水和晒太阳后植物成长")
                instructionRow(icon: "🎉", text: "成长4次植物完全长成!")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(GlassmorphismTheme.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(GlassmorphismTheme.border, lineWidth: 1)
                )
        )
    }
    
    private func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 14))
            Text(text)
                .font(GlassmorphismTheme.glassFont(size: 12))
                .foregroundColor(GlassmorphismTheme.textSecondary)
        }
    }
    
    // MARK: - Animation Helpers
    
    private func triggerGrowthAnimation() {
        animateGrowth = true
        showCelebration = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animateGrowth = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCelebration = false
            }
        }
    }
}
