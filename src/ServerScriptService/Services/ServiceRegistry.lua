-- Kingdoms Conquest — ServiceRegistry
-- Lightweight registry used to make service ownership explicit before Stage 12.
local ServiceRegistry = {}

local services = {}

function ServiceRegistry.Register(name, service)
    assert(type(name) == "string" and name ~= "", "service name required")
    assert(service ~= nil, "service required")
    if services[name] ~= nil then
        error("duplicate service registration: " .. name)
    end
    services[name] = service
end

function ServiceRegistry.Get(name)
    return services[name]
end

function ServiceRegistry.List()
    local names = {}
    for name in pairs(services) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return ServiceRegistry
