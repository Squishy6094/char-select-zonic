gZonicStates = {}
for i = 0, MAX_PLAYERS - 1 do
    gZonicStates[i] = {
        faceAngleAnim = 0,
        tiltAngleAnim = 0,
        wasUnderwater = false,
        slamFVel = 0,
    }
end

local ACT_ZONIC_WALKING = allocate_mario_action(ACT_GROUP_MOVING)
local ACT_ZONIC_ROLL = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_SHORT_HITBOX)
local ACT_ZONIC_SLAM = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
local ACT_ZONIC_SLAM_LAND = allocate_mario_action(ACT_GROUP_STATIONARY)

local function is_underwater(m)
    return m.pos.y + 140 < m.waterLevel
end

local function apply_zonic_slope_accel(m)
    if not m then return end
    local slopeAccel;

    local floor = m.floor;
    if not floor then return end
    local steepness = math.sqrt(floor.normal.x * floor.normal.x + floor.normal.z * floor.normal.z);

    local normalY = floor.normal.y;
    local floorDYaw = m.floorAngle - m.faceAngle.y;

    --[[
    if (mario_floor_is_slope(m) ~= 0) then
        local slopeClass = 0;

        if (m.action ~= ACT_SOFT_BACKWARD_GROUND_KB and m.action ~= ACT_SOFT_FORWARD_GROUND_KB) then
            slopeClass = mario_get_floor_class(m);
        end

        
        if slopeClass == SURFACE_CLASS_VERY_SLIPPERY then
            slopeAccel = 5.3;
        elseif slopeClass == SURFACE_CLASS_SLIPPERY then
            slopeAccel = 2.7;
        elseif slopeClass == SURFACE_CLASS_NOT_SLIPPERY then
            slopeAccel = 0.0;
        else
            slopeAccel = 1.7;
        end

        if (floorDYaw > -0x4000 and floorDYaw < 0x4000) then
            m.forwardVel = m.forwardVel + slopeAccel * steepness;
        else
            m.forwardVel = m.forwardVel - slopeAccel * steepness;
        end
    end
    ]]

    m.slideYaw = m.faceAngle.y;

    m.slideVelX = m.forwardVel * sins(m.faceAngle.y);
    m.slideVelZ = m.forwardVel * coss(m.faceAngle.y);

    m.vel.x = m.slideVelX;
    m.vel.y = 0.0;
    m.vel.z = m.slideVelZ;

    mario_update_moving_sand(m);
    mario_update_windy_ground(m);
end

local hardCap = 150
---@param m MarioState
local function update_zonic_walking_speed(m)
    if not m then return end
    local targetSpeed;
    local isRolling = m.action == ACT_ZONIC_ROLL

    local maxTargetSpeed = 50;
    if (m.floor and m.floor.type == SURFACE_SLOW) then
        maxTargetSpeed = 40.0;
    end

    if isRolling then
        targetSpeed = m.forwardVel;
    else
        targetSpeed = m.intendedMag/32*maxTargetSpeed;
    end

    if (m.quicksandDepth > 10.0) then
        targetSpeed = targetSpeed * 6.25 / m.quicksandDepth;
    end

    if is_underwater(m) then
        targetSpeed = targetSpeed * 0.5;
    end

    if m.floor.normal.y < 0.95 then
        local accelAngle = (0x4000 - math.abs(math.s16(m.floorAngle - m.faceAngle.y)))/0x4000/m.floor.normal.y
        if isRolling then
            targetSpeed = targetSpeed*(accelAngle*2)
            local anglePull = math.clamp(1 - m.floor.normal.y, 0, 1)/math.max(m.forwardVel*0.1, 0.1)
            m.faceAngle.y = m.floorAngle - approach_s32(math.s16(m.floorAngle - m.faceAngle.y), 0, 0x2000*anglePull, 0x2000*anglePull)
        else
            if accelAngle < 0 then
                accelAngle = accelAngle*0.3
            end
            targetSpeed = targetSpeed*(1+accelAngle)
        end
    end

    if m.forwardVel < 0 then
        m.forwardVel = math.ceil(math.lerp(m.forwardVel, 0, 0.2))
    elseif m.forwardVel < 15 and not isRolling then
        m.forwardVel = m.forwardVel + 0.9
        set_mario_particle_flags(m, PARTICLE_DUST, 0);
    elseif m.forwardVel < targetSpeed then
        m.forwardVel = m.forwardVel*1.03
    else
        if isRolling and m.floor.normal.y < 0.95 then
            m.forwardVel = m.forwardVel/1.01
        else
            m.forwardVel = m.forwardVel - (is_underwater(m) and 1 or 0.5)
        end
    end
    m.forwardVel = math.clamp(m.forwardVel, -hardCap, hardCap)
    --[[
    if (m.forwardVel <= 0.0) then
        m.forwardVel = m.forwardVel + 1.1;
    elseif (m.forwardVel <= targetSpeed) then
        m.forwardVel = m.forwardVel + 1.1 - m.forwardVel / 43.0;
    elseif (m.floor and m.floor.normal.y >= 0.95) then
        m.forwardVel = m.forwardVel - 1.0;
    end
    ]]

    --[[
    if (m.forwardVel > 48.0) then
        m.forwardVel = 48.0;
    end
    ]]

    local turnRadius = isRolling and 0x100 or 0x500*math.clamp(targetSpeed/m.forwardVel, 1, 2)
    m.faceAngle.y = m.intendedYaw - approach_s32(math.s16(m.intendedYaw - m.faceAngle.y), 0, turnRadius, turnRadius);
    apply_zonic_slope_accel(m);
end

---@param m MarioState
local function act_zonic_walking(m)
    if not m then return 0 end
    local startYaw = m.faceAngle.y;

    mario_drop_held_object(m);

    --[[
    if (should_begin_sliding(m) ~= 0) then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0);
    end
    ]]

    if (m.input & INPUT_FIRST_PERSON ~= 0) then
        return begin_braking_action(m);
    end

    if (m.input & INPUT_A_PRESSED ~= 0) then
        return set_jump_from_landing(m);
    end

    if (check_ground_dive_or_punch(m) ~= 0) then
        return 1;
    end

    if (m.input & INPUT_ZERO_MOVEMENT ~= 0) then
        if m.forwardVel > 15 then
            m.forwardVel = m.forwardVel - 2
        else
            return begin_braking_action(m);
        end
    end

    if (analog_stick_held_back(m) ~= 0 and m.forwardVel >= 16.0) then
        return set_mario_action(m, ACT_TURNING_AROUND, 0);
    end

    if (m.input & INPUT_Z_PRESSED ~= 0) then
        return set_mario_action(m, ACT_CROUCH_SLIDE, 0);
    end

    m.actionState = 0;

    local startPos = {x = 0, y = 0, z = 0}
    vec3f_copy(startPos, m.pos);
    update_zonic_walking_speed(m);

    local step = perform_ground_step(m)
    if step == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0);
        set_character_animation(m, CHAR_ANIM_GENERAL_FALL);
    elseif step == GROUND_STEP_NONE then
        anim_and_audio_for_walk(m)
    elseif step == GROUND_STEP_HIT_WALL then
        push_or_sidle_wall(m, startPos)
        m.actionTimer = 0;
    end

    check_ledge_climb_down(m);
    tilt_body_walking(m, startYaw);
    return 0;
end

---@param m MarioState
local function act_zonic_roll(m)
    if not m then return 0 end
    local isSpindash = m.actionArg == 1
    if not isSpindash then
        if m.actionTimer > 20 then
            if (m.input & INPUT_Z_DOWN == 0) then
                return set_mario_action(m, ACT_WALKING, 0);
            end
        else
            m.actionTimer = m.actionTimer + 1
        end

        if m.controller.buttonDown & B_BUTTON ~= 0 then
            play_character_sound(m, CHAR_SOUND_YAHOO)
            return set_mario_action(m, ACT_ZONIC_ROLL, 1)
        end
    else
        if m.actionTimer < 30 then
            m.actionTimer = m.actionTimer + 1
        else
            set_mario_particle_flags(m, PARTICLE_DUST, 0);
        end

        m.forwardVel = math.lerp(m.forwardVel, 0, 0.2)
        if m.controller.buttonDown & B_BUTTON == 0 then
            m.faceAngle.y = m.intendedYaw
            m.forwardVel = m.actionTimer*3
            update_zonic_walking_speed(m);
            return set_mario_action(m, ACT_ZONIC_ROLL, 0)
        end
    end

    if (m.input & INPUT_A_PRESSED ~= 0) then
        return set_mario_action(m, ACT_JUMP, 0)
    end

    if (m.forwardVel < 10) and m.floor.normal.y >= 0.95 and not isSpindash then
        return set_mario_action(m, ACT_CROUCHING, 0)
    end

    local step = perform_ground_step(m)
    if step == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0)
    elseif step == GROUND_STEP_HIT_WALL then
        mario_bonk_reflection(m, 0)
    end

    update_zonic_walking_speed(m);
    set_character_animation(m, CHAR_ANIM_SINGLE_JUMP);
    if not isSpindash then
        m.marioObj.header.gfx.animInfo.animAccel = 0x10000 * math.clamp(m.forwardVel/50, 0.2, 2)
        m.faceAngle.y = m.intendedYaw - approach_s32(math.s16(m.intendedYaw - m.faceAngle.y), 0, 0x100, 0x100);
    else
        m.marioObj.header.gfx.animInfo.animAccel = 0x10000 * m.actionTimer*0.1
        m.marioObj.header.gfx.angle.y = m.intendedYaw
    end
end

---@param m MarioState
local function act_zonic_slam(m)
    if not m then return 0 end
    local e = gZonicStates[m.playerIndex]

    if m.actionState == 0 then
        e.slamFVel = m.forwardVel
        m.actionState = m.actionState + 1
    end

    play_sound_if_no_flag(m, SOUND_ACTION_THROW, MARIO_ACTION_SOUND_PLAYED);
    set_character_animation(m, CHAR_ANIM_GROUND_POUND);

    local stepResult = perform_air_step(m, 0);
    m.forwardVel = 0
    m.vel.x = 0
    m.vel.z = 0
    m.vel.y = -100
    if (stepResult == AIR_STEP_LANDED) then
        if (should_get_stuck_in_ground(m) ~= 0) then
            queue_rumble_data_mario(m, 5, 80);
            play_character_sound(m, CHAR_SOUND_OOOF);
            set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0);
            set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0);
        else
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING);
            if (check_fall_damage(m, ACT_HARD_BACKWARD_GROUND_KB) == 0) then
                set_mario_particle_flags(m, (PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR), 0);
                set_mario_action(m, ACT_GROUND_POUND_LAND, 0);
            end
        end
        if (m.playerIndex == 0) then set_camera_shake_from_hit(SHAKE_GROUND_POUND); end
    end
end

---@param m MarioState
local function act_zonic_slam_land(m)
    if not m then return 0 end
    local e = gZonicStates[m.playerIndex]
    m.actionState = 1;
    if (m.input & INPUT_UNKNOWN_10 ~= 0) then
        return drop_and_set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0);
    end

    if (m.input & INPUT_OFF_FLOOR ~= 0) then
        return set_mario_action(m, ACT_FREEFALL, 0);
    end

    if (m.input & INPUT_ABOVE_SLIDE ~= 0) then
        m.forwardVel = e.slamFVel
        return set_mario_action(m, ACT_ZONIC_ROLL, 0);
    end

    if m.input & INPUT_A_PRESSED ~= 0 then
        m.forwardVel = e.slamFVel*0.95
        m.faceAngle.y = m.intendedYaw
        return set_mario_action(m, ACT_JUMP, 0);
    end

    if m.input & INPUT_B_PRESSED ~= 0 then
        return set_mario_action(m, ACT_ZONIC_ROLL, 1);
    end

    landing_step(m, CHAR_ANIM_GROUND_POUND_LANDING, ACT_BUTT_SLIDE_STOP);
    return 0;
end

hook_mario_action(ACT_ZONIC_WALKING, act_zonic_walking)
hook_mario_action(ACT_ZONIC_ROLL, act_zonic_roll, INT_SLIDE_KICK)
hook_mario_action(ACT_ZONIC_SLAM, act_zonic_slam, INT_GROUND_POUND)
hook_mario_action(ACT_ZONIC_SLAM_LAND, act_zonic_slam_land, INT_GROUND_POUND)

local function before_action(m, nextAct, nextArg)
    if nextAct == ACT_WALKING then
        return set_mario_action(m, ACT_ZONIC_WALKING, 0)
    end
    if nextAct == ACT_CROUCH_SLIDE then
        return set_mario_action(m, ACT_ZONIC_ROLL, 0)
    end
    if nextAct == ACT_PUNCHING and nextArg == 9 then
        return set_mario_action(m, ACT_ZONIC_ROLL, 1)
    end
    if nextAct == ACT_STEEP_JUMP then
        return set_mario_action(m, ACT_JUMP, 0)
    end
    if nextAct == ACT_GROUND_POUND then
        return set_mario_action(m, ACT_ZONIC_SLAM, 0)
    end
    if nextAct == ACT_GROUND_POUND_LAND then
        return set_mario_action(m, ACT_ZONIC_SLAM_LAND, 0)
    end
    if nextAct == ACT_BUTT_SLIDE then
        return set_mario_action(m, ACT_ZONIC_ROLL, 0)
    end
end

local function allow_water(m, water)
    if not water and (m.action & ACT_FLAG_RIDING_SHELL == 0) then return false end
end

---@param m MarioState
local function zonic_update(m)
    local e = gZonicStates[m.playerIndex]
    if e.wasUnderwater ~= is_underwater(m) then
        set_mario_particle_flags(m, PARTICLE_WATER_SPLASH, 0);
        if is_underwater(m) then
            m.vel.y = math.max(m.vel.y + 1, -50)
        elseif e.wasUnderwater then
            m.vel.y = m.vel.y * 2
        end
        e.wasUnderwater = is_underwater(m)
    end
end

_G.charSelect.character_hook_moveset(CT_ZBSONIC, HOOK_BEFORE_SET_MARIO_ACTION, before_action)
_G.charSelect.character_hook_moveset(CT_ZBSONIC, HOOK_ALLOW_FORCE_WATER_ACTION, allow_water)
_G.charSelect.character_hook_moveset(CT_ZBSONIC, HOOK_MARIO_UPDATE, zonic_update)