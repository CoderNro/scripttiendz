-- Script Farm Level và Auto Quest cho Blox Fruits (Sea 1)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local mouse = player:GetMouse()

-- Cài đặt danh sách các phần nhiệm vụ của NPC với yêu cầu cấp độ
local quests = {
    -- NPC "Quest Giver" với các phần nhiệm vụ khác nhau theo cấp độ
    {npc = "Bandit Quest Giver", 
        tasks = {
            {levelRange = {1, 10}, questName = "Bandits", enemyName = "Bandit [Lv. 5]", enemyAmount = 10},
            
        }
    }
}

-- Tìm kiếm phần nhiệm vụ phù hợp với cấp độ người chơi
local function findQuestForLevel(level)
    for _, questData in pairs(quests) do
        for _, task in pairs(questData.tasks) do
            if level >= task.levelRange[1] and level <= task.levelRange[2] then
                return task, questData.npc  -- Trả về phần nhiệm vụ và tên NPC
            end
        end
    end
    return nil, nil  -- Không tìm thấy nhiệm vụ phù hợp
end

-- Kiểm tra xem vũ khí hiện tại của người chơi là loại gì
local function getWeaponType()
    local currentWeapon = character:FindFirstChildOfClass("Tool")
    
    if currentWeapon then
        if currentWeapon.Name:match("Melee") then
            return "Melee"
        elseif currentWeapon.Name:match("Sword") then
            return "Sword"
        elseif currentWeapon.Name:match("Fruit") then
            return "Fruit"
        else
            return "Unknown"
        end
    else
        return "None"
    end
end

-- Hàm sử dụng vũ khí dựa trên loại vũ khí
local function useWeapon(weaponType)
    if weaponType == "Melee" then
        print("Sử dụng Melee để đánh quái.")
        -- Code để sử dụng Melee
        if character:FindFirstChild("MeleeWeapon") then
            character.MeleeWeapon:Activate()  -- Thực hiện hành động với vũ khí Melee
        end
    elseif weaponType == "Sword" then
        print("Sử dụng Sword để đánh quái.")
        -- Code để sử dụng Sword
        if character:FindFirstChild("SwordWeapon") then
            character.SwordWeapon:Activate()  -- Thực hiện hành động với vũ khí Sword
        end
    elseif weaponType == "Fruit" then
        print("Sử dụng Fruit để đánh quái.")
        -- Code để sử dụng Fruit
        if character:FindFirstChild("FruitPower") then
            character.FruitPower:Activate()  -- Thực hiện hành động với vũ khí Fruit
        end
    else
        print("Không phát hiện vũ khí hợp lệ.")
    end
end

-- Tìm NPC và nhận nhiệm vụ
local function interactWithNPC(npcName, quest)
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc.Name == npcName then
            -- Tìm phần đối thoại của NPC
            local dialog = npc:FindFirstChild("Dialog")
            if dialog then
                print("Đang đối thoại với NPC: " .. npc.Name)
                -- Gọi phương thức nhận nhiệm vụ
                dialog:InvokeServer("Accept Quest")
                print("Đã nhận nhiệm vụ: " .. quest.questName)
            end
        end
    end
end

-- Tìm kiếm quái vật cần đánh
local function findTargetEnemy(enemyName)
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == enemyName then
            return enemy
        end
    end
    return nil
end

-- Tự động tấn công quái vật
local function attackEnemy(enemy, weaponType)
    local enemyHumanoid = enemy:FindFirstChild("Humanoid")
    if enemyHumanoid then
        -- Đảm bảo nhân vật đứng gần quái vật và tấn công
        if (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude < 50 then
            humanoid:MoveTo(enemy.HumanoidRootPart.Position)
            -- Gọi lệnh tấn công với loại vũ khí đã chọn
            useWeapon(weaponType)
            print("Đang tấn công " .. enemy.Name)
        end
    end
end

-- Kiểm tra hoàn thành nhiệm vụ
local function checkQuestCompletion(enemyAmount)
    -- Kiểm tra số lượng quái vật đã đánh bại
    local defeatedEnemies = 0
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy.Humanoid.Health <= 0 then
            defeatedEnemies = defeatedEnemies + 1
        end
    end
    return defeatedEnemies >= enemyAmount
end

-- Chạy script
while true do
    -- Kiểm tra cấp độ của người chơi
    local playerLevel = player.Data.Level -- Đảm bảo đây là cách truy cập đúng cấp độ trong game
    local quest, npcName = findQuestForLevel(playerLevel)

    if quest then
        -- Nếu có nhiệm vụ phù hợp với cấp độ
        -- Tự động đối thoại với NPC và nhận nhiệm vụ
        interactWithNPC(npcName, quest)
        
        -- Lấy loại vũ khí hiện tại của người chơi
        local weaponType = getWeaponType()
        print("Loại vũ khí hiện tại: " .. weaponType)
        
        -- Farm quái vật cho đến khi hoàn thành nhiệm vụ
        while not checkQuestCompletion(quest.enemyAmount) do
            local enemy = findTargetEnemy(quest.enemyName)
            if enemy then
                attackEnemy(enemy, weaponType)
            end
            wait(1)  -- Đợi một chút trước khi lặp lại
        end

        -- Nhiệm vụ hoàn thành, có thể quay lại NPC để nhận thưởng
        print("Nhiệm vụ đã hoàn thành: " .. quest.questName)
    else
        print("Không có nhiệm vụ phù hợp cho cấp độ " .. playerLevel)
    end
    wait(10)  -- Kiểm tra lại sau mỗi 10 giây
end