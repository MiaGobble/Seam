--[[
    Performance Benchmarks for Seam in Lune (Luau Sub-Environment)
]]

local process = require("@lune/process")
local roblox = require("@lune/roblox")
local loadPackage = require("../tests/lune/loadSeam")

local Instance = roblox.Instance
local root = process.cwd
local package = loadPackage(`{root}/src`)
local Seam = package.Seam
local step = package.step

print("==================================================")
print("             SEAM LUAU BENCHMARKS                 ")
print("==================================================")

local function benchmark(name: string, iterations: number, fn: () -> ())
	-- Warmup
	for _ = 1, math.min(10, iterations) do
		fn()
	end

	local start = os.clock()
	for _ = 1, iterations do
		fn()
	end
	local elapsed = os.clock() - start
	local opsPerSec = math.floor(iterations / elapsed)
	local avgMs = (elapsed / iterations) * 1000

	print(string.format("  %-38s : %8d ops/s  (%6.3f ms/op)  [total: %.3fs]", name, opsPerSec, avgMs, elapsed))
end

-- 1. Value Creation and Mutation
print("\n[1] Value Primitive Performance")
benchmark("Value(x) creation [10,000x]", 1, function()
	local values = table.create(10000)
	for i = 1, 10000 do
		values[i] = Seam.Value(i)
	end
	for i = 1, 10000 do
		values[i]:Destroy()
	end
end)

benchmark("Value.Value write [100,000x]", 1, function()
	local val = Seam.Value(0)
	for i = 1, 100000 do
		val.Value = i
	end
	val:Destroy()
end)

-- 2. StateManager Attached State Frame Cost (Idle Test)
print("\n[2] StateManager Property Attachment (Idle Frame Overhead)")
local idleInstances = table.create(2000)
local idleValues = table.create(2000)

for i = 1, 2000 do
	local folder = Instance.new("Folder")
	local val = Seam.Value(`Folder_{i}`)
	val(folder, "Name")
	idleInstances[i] = folder
	idleValues[i] = val
end

benchmark("Step 2,000 attached instances (100 frames)", 100, function()
	step(0.016)
end)

for i = 1, 2000 do
	idleValues[i]:Destroy()
	idleInstances[i]:Destroy()
end

-- 3. Reactive Propagation: Diamond Graph
print("\n[3] Reactive Dependency Propagation (Diamond Graph)")
benchmark("Diamond update (Root -> 2 branches -> Leaf) [10,000x]", 10000, function()
	local rootVal = Seam.Value(1)
	local b1 = Seam.Computed(function(use)
		return use(rootVal) * 2
	end)
	local b2 = Seam.Computed(function(use)
		return use(rootVal) + 5
	end)
	local leaf = Seam.Computed(function(use)
		return use(b1) + use(b2)
	end)

	rootVal.Value = 2
	local _ = leaf.Value

	leaf:Destroy()
	b2:Destroy()
	b1:Destroy()
	rootVal:Destroy()
end)

-- 4. Animation: Spring Stepping
print("\n[4] Spring Simulation Performance")
local springs = table.create(500)
for i = 1, 500 do
	springs[i] = Seam.Spring(0, 15, 0.75)
	springs[i].Target = 100
end

benchmark("Step 500 active Springs [120 frames]", 120, function()
	step(0.016)
end)

for i = 1, 500 do
	springs[i]:Destroy()
end

-- 5. Children Reconciliation & Diffing
print("\n[5] Children Reconciliation (Diffing 500 Instances)")
local parent = Instance.new("Folder")
local childrenList = table.create(500)
for i = 1, 500 do
	childrenList[i] = Instance.new("Folder")
end
local trigger = Seam.Value(0)
local childrenComputed = Seam.Computed(function(use)
	use(trigger)
	return childrenList
end)
Seam.Children(parent, childrenComputed)

benchmark("Mutate 50 children in 500-child set [50x]", 50, function()
	local newList = table.clone(childrenList)
	-- replace 50 children
	for j = 1, 50 do
		newList[j] = Instance.new("Folder")
	end
	childrenList = newList
	trigger.Value += 1
end)

trigger:Destroy()
childrenComputed:Destroy()
parent:Destroy()

-- 6. EventSequence Playback
print("\n[6] EventSequence Timeline Updates")
local seqs = table.create(200)
for i = 1, 200 do
	seqs[i] = Seam.EventSequence({
		{ 0.1, function() end },
		{ 0.2, function() end },
		{ 0.3, function() end },
		{ 0.4, function() end },
	})
	seqs[i].Play()
end

benchmark("Step 200 active EventSequences [60 frames]", 60, function()
	step(0.016)
end)

for i = 1, 200 do
	seqs[i].Stop()
end

print("\n==================================================")
print("             BENCHMARKS COMPLETE                  ")
print("==================================================")
