function lerp_s16(a, b, t)
    a = math.s16(math.round(a))
    b = math.s16(math.round(b))

    local delta = b - a

    if delta > 0x8000 then
        delta = delta - 0x10000
    elseif delta < -0x8000 then
        delta = delta + 0x10000
    end

    return math.s16(a + delta * t)
end