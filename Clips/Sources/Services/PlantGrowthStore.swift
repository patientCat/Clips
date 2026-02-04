import Foundation
import Combine
import AppKit

// 植物类型
enum PlantType: String, Codable, CaseIterable {
    case sunflower = "向日葵"
    case rose = "玫瑰"
    case tulip = "郁金香"
    case cactus = "仙人掌"
    case sakura = "樱花"
    
    var emoji: String {
        switch self {
        case .sunflower: return "🌻"
        case .rose: return "🌹"
        case .tulip: return "🌷"
        case .cactus: return "🌵"
        case .sakura: return "🌸"
        }
    }
    
    var seedEmoji: String {
        return "🌱"
    }
    
    var stages: [String] {
        switch self {
        case .sunflower: return ["🌱", "🌿", "🌾", "🌻"]
        case .rose: return ["🌱", "🌿", "🥀", "🌹"]
        case .tulip: return ["🌱", "🌿", "🌼", "🌷"]
        case .cactus: return ["🌱", "🪴", "🌿", "🌵"]
        case .sakura: return ["🌱", "🌿", "🌸", "🌳"]
        }
    }
}

// 植物状态
struct PlantState: Codable, Identifiable {
    let id: UUID
    var plantType: PlantType
    var growthStage: Int  // 0-3 (种子、发芽、成长、开花)
    var sunlight: Int     // 阳光值 (复制积累)
    var water: Int        // 水分值 (粘贴积累)
    var totalSunlight: Int  // 总共获得的阳光
    var totalWater: Int     // 总共获得的水分
    var createdAt: Date
    var lastWateredAt: Date?
    var lastSunAt: Date?
    var isFullyGrown: Bool { growthStage >= 3 }
    
    init(plantType: PlantType = .sunflower) {
        self.id = UUID()
        self.plantType = plantType
        self.growthStage = 0
        self.sunlight = 0
        self.water = 0
        self.totalSunlight = 0
        self.totalWater = 0
        self.createdAt = Date()
    }
    
    var currentEmoji: String {
        let stages = plantType.stages
        let index = min(growthStage, stages.count - 1)
        return stages[index]
    }
    
    var needsSunlight: Bool { sunlight < 10 }
    var needsWater: Bool { water < 10 }
    var canGrow: Bool { sunlight >= 10 && water >= 10 && !isFullyGrown }
}

// 植物养成数据管理
class PlantGrowthStore: ObservableObject {
    @Published var currentPlant: PlantState?
    @Published var gardenHistory: [PlantState] = []  // 已完成种植的植物
    @Published var copyCount: Int = 0   // 复制次数 (阳光)
    @Published var pasteCount: Int = 0  // 粘贴次数 (水分)
    
    private let storageKey = "PlantGrowthData"
    private let historyKey = "PlantGrowthHistory"
    private var cancellables = Set<AnyCancellable>()
    
    init(clipboardService: ClipboardService) {
        load()
        print("🌱 PlantGrowthStore 初始化")
        
        // 订阅文本变化（代表复制操作 -> 阳光）
        clipboardService.$currentTextContent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.addSunlight()
            }
            .store(in: &cancellables)
        
        // 订阅图片变化（也代表复制操作 -> 阳光）
        clipboardService.$currentImageContent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.addSunlight()
            }
            .store(in: &cancellables)
    }
    
    // 添加阳光（复制操作）
    func addSunlight() {
        copyCount += 1
        if var plant = currentPlant {
            plant.sunlight += 1
            plant.totalSunlight += 1
            currentPlant = plant
            save()
            print("☀️ 阳光 +1, 当前阳光: \(plant.sunlight)")
        }
    }
    
    // 添加水分（粘贴操作）
    func addWater() {
        pasteCount += 1
        if var plant = currentPlant {
            plant.water += 1
            plant.totalWater += 1
            currentPlant = plant
            save()
            print("💧 水分 +1, 当前水分: \(plant.water)")
        }
    }
    
    // 手动触发粘贴计数（需要在外部调用）
    func recordPaste() {
        addWater()
    }
    
    // 给植物浇水（消耗10水分）
    func waterPlant() {
        guard var plant = currentPlant, plant.water >= 10, !plant.isFullyGrown else { return }
        plant.water -= 10
        plant.lastWateredAt = Date()
        currentPlant = plant
        checkAndGrow()
        save()
        print("🚿 浇水成功!")
    }
    
    // 给植物晒太阳（消耗10阳光）
    func sunPlant() {
        guard var plant = currentPlant, plant.sunlight >= 10, !plant.isFullyGrown else { return }
        plant.sunlight -= 10
        plant.lastSunAt = Date()
        currentPlant = plant
        checkAndGrow()
        save()
        print("🌞 晒太阳成功!")
    }
    
    // 检查是否可以成长
    private func checkAndGrow() {
        guard var plant = currentPlant else { return }
        
        // 需要同时浇过水和晒过太阳才能成长
        if let lastWatered = plant.lastWateredAt,
           let lastSun = plant.lastSunAt,
           !plant.isFullyGrown {
            // 如果两个操作都在最近完成过，就成长
            let now = Date()
            let waterRecent = now.timeIntervalSince(lastWatered) < 60  // 1分钟内
            let sunRecent = now.timeIntervalSince(lastSun) < 60
            
            if waterRecent && sunRecent {
                plant.growthStage += 1
                plant.lastWateredAt = nil
                plant.lastSunAt = nil
                currentPlant = plant
                print("🌱 植物成长! 当前阶段: \(plant.growthStage)")
                
                if plant.isFullyGrown {
                    // 植物完全长成
                    gardenHistory.append(plant)
                    print("🎉 植物完全长成!")
                }
                save()
            }
        }
    }
    
    // 开始种植新植物
    func startNewPlant(type: PlantType) {
        currentPlant = PlantState(plantType: type)
        save()
        print("🌱 开始种植新植物: \(type.rawValue)")
    }
    
    // 收获植物并开始新的
    func harvest() {
        if let plant = currentPlant, plant.isFullyGrown {
            if !gardenHistory.contains(where: { $0.id == plant.id }) {
                gardenHistory.append(plant)
            }
        }
        currentPlant = nil
        save()
    }
    
    // 重置当前植物
    func reset() {
        currentPlant = nil
        save()
    }
    
    // MARK: - Persistence
    
    private func save() {
        do {
            if let plant = currentPlant {
                let data = try JSONEncoder().encode(plant)
                UserDefaults.standard.set(data, forKey: storageKey)
            } else {
                UserDefaults.standard.removeObject(forKey: storageKey)
            }
            
            let historyData = try JSONEncoder().encode(gardenHistory)
            UserDefaults.standard.set(historyData, forKey: historyKey)
            
            UserDefaults.standard.set(copyCount, forKey: "PlantCopyCount")
            UserDefaults.standard.set(pasteCount, forKey: "PlantPasteCount")
        } catch {
            print("Failed to save plant data: \(error)")
        }
    }
    
    private func load() {
        // 加载当前植物
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                currentPlant = try JSONDecoder().decode(PlantState.self, from: data)
            } catch {
                print("Failed to load plant data: \(error)")
            }
        }
        
        // 加载历史
        if let historyData = UserDefaults.standard.data(forKey: historyKey) {
            do {
                gardenHistory = try JSONDecoder().decode([PlantState].self, from: historyData)
            } catch {
                print("Failed to load plant history: \(error)")
            }
        }
        
        copyCount = UserDefaults.standard.integer(forKey: "PlantCopyCount")
        pasteCount = UserDefaults.standard.integer(forKey: "PlantPasteCount")
    }
}
