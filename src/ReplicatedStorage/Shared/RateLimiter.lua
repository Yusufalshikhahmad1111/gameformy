local RateLimiter = {}

local buckets = {}

function RateLimiter.Allow(scope, subject, interval, burst)
    interval = math.max(0.01, tonumber(interval) or 1)
    burst = math.max(1, tonumber(burst) or 1)
    local key = tostring(scope) .. ":" .. tostring(subject)
    local now = os.clock()
    local bucket = buckets[key]

    if not bucket or now - bucket.Window >= interval then
        bucket = {Window = now, Count = 0}
        buckets[key] = bucket
    end

    if bucket.Count >= burst then
        return false
    end

    bucket.Count += 1
    return true
end

function RateLimiter.ClearSubject(subject)
    local suffix = ":" .. tostring(subject)
    for key in pairs(buckets) do
        if string.sub(key, -#suffix) == suffix then
            buckets[key] = nil
        end
    end
end

return RateLimiter
