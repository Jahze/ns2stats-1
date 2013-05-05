enabled = false

sounds = nil

--TODO: replace with hooking OnTouch whenever a Pickupable is created but also when DropPack is created to account for MedPack and whatever else does not initialize the PickupableMixin on the server
--HookFunction("PickupableMixin.OnTouch") -- entity, player

function OnMapPreLoad()
    sounds = {
        triplekill = PrecacheAsset("sound/killstreaks.fev/killstreaks/triplekill")
        multikill = PrecacheAsset("sound/killstreaks.fev/killstreaks/multikill")
        rampage = PrecacheAsset("sound/killstreaks.fev/killstreaks/rampage")
        killingspree = PrecacheAsset("sound/killstreaks.fev/killstreaks/killingspree")
        dominating = PrecacheAsset("sound/killstreaks.fev/killstreaks/dominating")
        unstoppable = PrecacheAsset("sound/killstreaks.fev/killstreaks/unstoppable")
        megakill = PrecacheAsset("sound/killstreaks.fev/killstreaks/megakill")
        ultrakill = PrecacheAsset("sound/killstreaks.fev/killstreaks/ultrakill")
        ownage = PrecacheAsset("sound/killstreaks.fev/killstreaks/ownage")
        ludicrouskill = PrecacheAsset("sound/killstreaks.fev/killstreaks/ludicrouskill")
        headhunter = PrecacheAsset("sound/killstreaks.fev/killstreaks/headhunter")
        whickedsick = PrecacheAsset("sound/killstreaks.fev/killstreaks/whickedsick")
        monsterkill = PrecacheAsset("sound/killstreaks.fev/killstreaks/monsterkill")
        holyshit = PrecacheAsset("sound/killstreaks.fev/killstreaks/holyshit")
        godlike = PrecacheAsset("sound/killstreaks.fev/killstreaks/godlike")
        suicide = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide")
        suicide2 = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide2")
        suicide3 = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide3")
        suicide4 = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide4")
    }
end

function OnClientPutInServer(client)
    --RBPS:addLog { action = "connect", steamId = client:GetUserId() }

    -- if RBPSadvancedConfig.helpText ~= "" then    
    --     RBPS:PlayerSay(client:GetUserId(),RBPSadvancedConfig.helpText)
    -- end

    -- local player = client:GetControllingPlayer()
    -- if player then 
    --     Cout:SendMessageToClient(player, "askServerInfo",{action = "connect"})
    -- end

    -- if player then 
    --     Cout:SendMessageToClient(player, "askModsInfo",{action = "connect"})
    -- end

    -- if not client:GetIsVirtual() and RBPSwebDataFetched == true then
    --     RBPS:webGetSinglePlayerData(client:GetUserId())
    -- end
end

function OnClientDisconnect(client)
    --RBPS:addLog { score = score, action = "disconnect", steamId = theplayer.steamId }
end

function OnCommandStats(client, command, param2, param3)
    -- local RBPSplayer = RBPS:getPlayerByClient(client)
    
    -- if RBPSplayer == nil then        
    --     return
    -- end
    
    -- if command == "login" then
    --     if param2 then
    --         ServerAdminPrint(client,"Your login code is now set at: '" .. param2 .. "'")            
    --         RBPSplayer.code = param2        
    --     else
    --         ServerAdminPrint(client,"Your login code currently set at: '" .. param2 .. "'")         
    --     end        
    --     RBPSstats(client, "logintest", nil, nil)
    --     return                
    -- end
    
    -- if RBPSplayer.lastCommand == nil then RBPSplayer.lastCommand = 0 end
    -- local last = RBPSplayer.lastCommand + 2
    -- if last > Shared.GetSystemTime() then 
    --     ServerAdminPrint(client,"Please, wait a moment before using stats command again.")          
    --     return 
    -- end
    
    -- RBPSplayer.lastCommand = Shared.GetSystemTime()
    
    -- if not client then return end
    -- if not command then command="help" end
    
    -- local player = client:GetControllingPlayer()
    -- if not param2 then param2 = "empty" end
    -- if not param3 then param3 = "empty" end
       
    -- Shared.SendHTTPRequest(RBPS.websiteUrl .. "/api/" .. command .. "/" .. client:GetUserId() .. "?a=" .. param2 .. "&b=" .. param3 .. "&key=" .. RBPSadvancedConfig.key .. "&code=" .. RBPSplayer.code, "GET",
    --      function(response) RBPS:onHTTPResp(client,command,response) end)
end

-- function RBPS:onHTTPResp(client, action, response)
--     if client then
--         if action == "stats" then
--             RBPS:PlayerSay(client:GetUserId(), response)
--         end

--         ServerAdminPrint(client,response)
--     end
-- end

-- Pre Hooks
function OnPreDoDamage(self, damage, target, point, direction, surface, alt_mode, show_tracer)
    if not enabled then return end

    local has_hit = false
    local doer = self
    local attacker = nil
    
    if target and target:isa("Ragdoll") then
        return false
    end
    
    if self:isa("Player") then
        attacker = self
    else
        if self:GetParent() and self:GetParent():isa("Player") then
            attacker = self:GetParent()
        elseif HasMixin(self, "Owner") and self:GetOwner() and self:GetOwner():isa("Player") then
            attacker = self:GetOwner()
        end
    end
    
    if not attacker then
        attacker = doer
    end

    if attacker then
        local damage_type = kDamageType.Normal
        if self.GetDamageType then
            damage_type = self:GetDamageType()
        elseif HasMixin(self, "Tech") then
            damage_type = LookupTechData(self:GetTechId(), kTechDataDamageType, kDamageType.Normal)
        end
        
        if target and HasMixin(target, "Live") and damage > 0 then
            damage = GetDamageByType(target, attacker, doer, damage, damage_type)

            if damage > 0 then
                if attacker:isa("Player") and (not doer.GetShowHitIndicator or doer:GetShowHitIndicator()) then
                    has_hit = true
                    RBPS:addHitToLog(target, attacker, doer, damage, damage_type)
                end
            end
        end
        
        if not has_hit then
            RBPS:addMissToLog(attacker)
        end
    end
end

function OnPreConstructGhostStructure(entity, builder)
    if not enabled then return end

    if entity:GetIsGhostStructure() and GetAreFriends(entity, builder) then
        RBPS:ghostStructureAction("ghost_remove", entity, builder)
    end
end

function OnPreResetPlayerScores(player)
    player.assists = 0
end

function OnPreEntityKilled(target, attacker, doer, point, direction)
    if enabled then RBPS:addDeathToLog(target, attacker, doer) end
end

function OnPreAbortResearch(entity, refund_cost)
    if entity.researchProgress > 0 then        
        local team = entity:GetTeam()
        -- Team is not always available due to order of destruction during map change
        if team then        
            local research_node = team:GetTechTree():GetTechNode(entity.researchingId)
            if research_node then
                RBPS:addUpgradeAbortedToLog(research_node, entity)
            end
        end
    end
end

function OnPreTechResearched(entity, structure, research_id)
    if structure and structure:GetId() == entity:GetId() then
        local research_node = entity:GetTeam():GetTechTree():GetTechNode(research_id)
        RBPS:addUpgradeFinishedToLog(research_node, structure, entity)
    end
end

function OnPrePickupableDestroy(entity)
    RBPS:addPickableItemDestroyedToLog(entity)
end

function OnPreCommanderAbilityDestroy(ability)
    RBPS:addPickableAbilityDestroyedToLog(ability)
end


-- Post Hooks
function OnEntityCreate(entity)
    if enabled and entity:isa("Egg") then
        RBPS:addStructureBuiltToLog(entity, nil)
    end
end

function OnCreateEntityForCommander(tech_id, position, commander, new_ent)
    if enabled then RBPS:dropStructure(new_ent, commander) end
    return new_ent
end

function OnCommanderAbilityInitialized(self)
    if enabled then RBPS:addPickableAbilityCreateToLog(self) end
end

function OnCommanderAbilityDestroyed(self)
    if enabled then RBPS:addPickableAbilityDestroyedToLog(self) end
end

function OnBuildScoresMessage(score_player, send_to_player, t)
    t.assists = score_player:GetAssists()    
    t.badge = score_player.currentBadge or kBadges.None
    return t
end

function OnCreatePlayer(player)
    player.assists = 0
end

function OnJumpLand(player, land_intensity, slow_down)
    if enabled then RBPS:addJump(player:GetName()) end
end

function OnCopyPlayerDataFrom(player, other_player)
    player.assists = other_player.assists
end

function OnRemoveAllObstacles()
    if enabled then RBPS:gameReset() end
end

function OnGhostStructureCreated(entity)
    if enabled then
        RBPS:ghostStructureAction("ghost_create", entity, nil)
    end
end

function GhostStructurePerformedAction(entity, tech_node, position)
    if enabled and tech_node.techId == kTechId.Cancel and entity:GetIsGhostStructure() then
        RBPS:ghostStructureAction("ghost_destroy", entity, nil)
    end
end

function OnSetOnFire(entity, attacker, doer)
    --TODO: damage is not correct probably and damagetype
    RBPS:addHitToLog(entity, attacker, doer, entity.numStacks*kBurnDamagePerStackPerSecond, 3)
end

function OnConstruct(entity, elapsed_time, builder)
    if not entity.constructionComplete then
        local client = GetClient(builder)
        if client then
            RBPS:addConstructionTime(client)
        end
    end
end

function OnSetConstructionComplete(entity, builder)
    if entity:GetIsAlive() then
        RBPS:addStructureBuiltToLog(entity, builder)
    end
end

function OnSetResearching(entity, tech_node, player)
    if player:isa("Commander") then
        RBPS:addUpgradeStartedToLog(tech_node, player, entity)
    end
end

function OnRecyclableResearchComplete(entity, research_id)
    if research_id == kTechId.Recycle then        
        -- Amount to get back, accounting for upgraded structures too
        local upgrade_level = 0
        if entity.GetUpgradeLevel then
            upgrade_level = entity:GetUpgradeLevel()
        end
        
        local amount = GetRecycleAmount(entity:GetTechId(), upgrade_level)
        -- returns a scalar from 0-1 depending on health the structure has (at the present moment)
        local scalar = entity:GetRecycleScalar() * kRecyclePaybackScalar        
        -- We round it up to the nearest value thus not having weird fracts
        -- of costs being returned which is not suppose to be the case.
        local final_recycle_amount = math.round(amount * scalar)
                
        RBPS:addRecycledToLog(entity, final_recycle_amount)
    end
end

function OnPickupableCreated(entity)
    RBPS:addPickableItemCreateToLog(entity)
end

function OnPickupableTouched(entity, player)
    RBPS:addPickableItemPickedToLog(entity, player)
end

function OnPerformGradualMeleeAttack(weapon, player, damage, range, optional_coords, alt_mode, did_hit)
    if not did_hit then
        RBPS:addMissToLog(player)
    end
end

function OnAttackMeleeCapsule(weapon, player, damage, range, optional_coords, alt_mode, did_hit)
    if not did_hit then
        RBPS:addMissToLog(player)
    end
end

function OnCommanderAbilityInitialized(ability)
    RBPS:addPickableAbilityCreateToLog(ability)
end

function OnProjectileHitProcessed(projectile, entity, surface, normal)
    if entity and entity:isa("Player") and projectile:GetOwner() ~= entity:isa("Player") then
        -- is player
    else                                    
        RBPS:addMissToLog(projectile:GetOwner())
    end
end


-- Monkey patches
function Player:AddAssist()
    self.assists = Clamp(self.assists + 1, 0, kMaxScore)
    self:SetScoreboardChanged(true)   
end

function Player:GetAssists()
    return self.assists
end