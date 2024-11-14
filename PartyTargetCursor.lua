
local CursorTargetWidgetMap = {
    player = "PlayerPortrait",
    pet = "PetPortrait",
    party1 = "PartyMemberFrame1Portrait",
    partypet1 = "PartyMemberFrame1PetFramePortrait",
    party2 = "PartyMemberFrame2Portrait",
    partypet2 = "PartyMemberFrame2PetFramePortrait",
    party3 = "PartyMemberFrame3Portrait",
    partypet3 = "PartyMemberFrame3PetFramePortrait",
    party4 = "PartyMemberFrame4Portrait",
    partypet4 = "PartyMemberFrame4PetFramePortrait"
};
local DbgTarget = nil;

local offset_x = 0.0;
local offset_y = 0.0;

local desired_offset_x = 0.0;
local desired_offset_y = 0.0;

local time_constant = 0.04;
local anim_time = 1.0;

function PartyTargetCursor_OnLoad()
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("UNIT_PET");
    PartyTargetCursor_UpdateTarget();
end

function PartyTargetCursor_OnEvent(event)
    if ( event == "PLAYER_TARGET_CHANGED" ) then
        PartyTargetCursor_UpdateTarget();
    elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
        PartyTargetCursor_UpdateTarget();
    elseif ( event == "UNIT_PET" ) then
        PartyTargetCursor_UpdateTarget();
    end
end

local function lerp(from, to, alpha)
    return (1.0 - alpha) * from + alpha * to;
end

function PartyTargetCursor_OnUpdate(elapsed)
    if ( anim_time > 0.0 ) then
        local lerp_factor = 1.0 - exp(-elapsed / time_constant);
        offset_x = lerp(offset_x, desired_offset_x, lerp_factor);
        offset_y = lerp(offset_y, desired_offset_y, lerp_factor);
        PartyTargetCursor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", offset_x, offset_y);
        anim_time = anim_time - elapsed;
    end
end

function PartyTargetCursor_DbgTarget(target)
    DbgTarget = target;
    PartyTargetCursor_UpdateTarget();
end

function PartyTargetCursor_UpdateTarget()
    local targetWidget = nil;
    if ( UnitExists("target") ) then
        targetWidget = TargetPortrait;
    end
    local target = DbgTarget or "target";
    for unitId, portraitWidgetName in pairs(CursorTargetWidgetMap) do
        if ( UnitIsUnit(target, unitId) ) then
            local widget = getglobal(portraitWidgetName);
            if ( widget:IsVisible() or DbgTarget ~= nil ) then
                targetWidget = widget;
                break;
            end
        end
    end
    if ( targetWidget ~= nil ) then
        anim_time = 2.0; -- Animate for 2 seconds
        desired_offset_x = targetWidget:GetLeft() - 15;
        desired_offset_y = targetWidget:GetTop() - UIParent:GetTop() - 5;
        if ( not PartyTargetCursor:IsVisible() ) then
            offset_x = desired_offset_x;
            offset_y = desired_offset_y;
        end
        PartyTargetCursor:Show();
    else
        PartyTargetCursor:Hide();
    end
end
