
local PW = require("PineWorks")
-- PW.enableDebug()

local scene = PW.scene.new("main")
local cameraController = PW.cameraControllers.keyboard(3, 45, {
	disableFlight = true,
})
scene.camera:setController(cameraController)
scene.camera:setPos(0, 0.25, 0)

PW.frame:setBackgroundColor(colors.black)

scene:addEnv(PW.modelGen:plane({
	size = 100,
	y = -0.1,
	color = colors.green,
}))
scene:addEnv(PW.modelGen:mountains({
	color = colors.green,
	y = -0.1,
	res = 18,
	scale = 50,
	randomHeight = 0.5,
	randomOffset = 0.5,
}))
scene:addEnv(PW.modelGen:mountains({
	color = colors.gray,
	y = -0.1,
	res = 12,
	scale = 100,
	height = 0.8,
	randomHeight = 0.5,
	randomOffset = 0.5,
	snow = true,
	snowHeight = 0.6,
	snowColor = colors.lightGray,
}))

local lodSettings = {
	qualityHalvingDistance = 10,
	variantCount = 8,
}

local pineModel = PW.model("models/pinetree"):toLoD(lodSettings)
local bushModel = PW.model("models/bush"):scale(0.5)

local range = 50
for i = 1, 300 do
	local x = math.random() * range - (range*0.5)
	local z = math.random() * range - (range*0.5)
	scene:add(pineModel, x, 0, z)
end

for i = 1, 150 do
	local x = math.random() * range - (range*0.5)
	local z = math.random() * range - (range*0.5)
	scene:add(bushModel, x, 0, z)
end

local fireworkColors = {
	colors.red,
	colors.orange,
	colors.yellow,
	colors.lime,
	colors.pink,
	colors.purple,
	colors.white,
	colors.lightBlue,
}

local function randomFrom(t)
	return t[math.random(1, #t)]
end

local trailPointModel = PW.modelGen:cube({
	color = colors.lightGray,
}):scale(0.2)
local function spawnTrailPoint(x, y, z)
	local trail = scene:add(trailPointModel, x, y, z)

	local spawnTime = os.epoch("utc")
	trail:on("update", function(dt)
		local t = os.epoch("utc")
		local time = t - spawnTime
		trail:setPos(nil, trail.y - dt*2, nil)
		if time >= 200 then
			-- trail:remove()
			trail:remove({PW.effects.shrink})
		end
	end)
	-- trail:remove()
end

local function launchFirework()
	local ball = PW.modelGen:icosphere({
		color = colors.red,
		colors = {
			-- colors.red, colors.orange, colors.yellow,
			randomFrom(fireworkColors),
			randomFrom(fireworkColors),
			randomFrom(fireworkColors),
		},
		res = 4,
		colorsFractal = true,
	})
	for i = 1, #ball do
		ball[i].forceRender = true
	end

	local explosionTime = math.random() * 1 + 0.7
	local acceleration = 0.25

	local spawnRange = 80

	local function distance(x, y, z)
		return (x*x + y*y + z*z)^0.5
	end

	local function distanceToVolume(d)
		return math.min(1, 1 / (d*0.1))
	end

	local spawnX = (math.random() - 0.5) * spawnRange
	local spawnZ = (math.random() - 0.5) * spawnRange

	local firework = scene:add(ball, spawnX, 0, spawnZ)
	firework.pineObject[8] = 7
	local vy = 0
	local spawnTime = os.epoch("utc")
	local lastTrailTime = os.epoch("utc")
	local trailSpawnTime = 0.05
	PW.audio.playSound("entity.firework_rocket.launch", 0.5 * distanceToVolume(distance(spawnX, 0, spawnZ)), math.random()/4 + 0.75)
	firework:on("update", function(dt)
		local t = os.epoch("utc")

		if t > lastTrailTime + trailSpawnTime * 1000 then
			lastTrailTime = t
			spawnTrailPoint(firework.x, firework.y, firework.z)
		end

		vy = vy + acceleration * dt
		local newY = firework.y + vy
		firework:setPos(nil, newY, nil)
		if t > spawnTime + explosionTime * 1000 then
			local volume = distanceToVolume(distance(firework.x, firework.y, firework.z))
			PW.audio.playSound("entity.firework_rocket.blast", volume, math.random()*0.75 + 0.25)
			if math.random(1, 3) == 1 then
				local sound = "entity.firework_rocket.twinkle_far"
				if math.random() > 0.5 then
					sound = "entity.firework_rocket.twinkle"
				end
				PW.audio.playSound(sound, volume, math.random()/2 + 0.5)
			end

			local disappearTimes = {}
			local model = firework.pineObject[7]
			for i = 1, #model do
				disappearTimes[model[i]] = math.random() * 3
			end

			---@type Effect
			local function effect(object, dt, time)
				local model = object.pineObject[7]
				for i = #model, 1, -1 do
					local poly = model[i]

					local avgX = (poly[1] + poly[4] + poly[7]) / 3
					local avgY = (poly[2] + poly[5] + poly[8]) / 3
					local avgZ = (poly[3] + poly[6] + poly[9]) / 3

					local offsetX1 = poly[1] - avgX
					local offsetY1 = poly[2] - avgY
					local offsetZ1 = poly[3] - avgZ

					local offsetX2 = poly[4] - avgX
					local offsetY2 = poly[5] - avgY
					local offsetZ2 = poly[6] - avgZ

					local offsetX3 = poly[7] - avgX
					local offsetY3 = poly[8] - avgY
					local offsetZ3 = poly[9] - avgZ

					local d = distance(avgX, avgY, avgZ)
					local targetDistance = (time*2)^0.5 * 4

					avgX = avgX * targetDistance / d
					avgY = avgY * targetDistance / d
					avgZ = avgZ * targetDistance / d

					-- avgX = avgX * ((4 - time)^0.5 * 2) ^ dt
					-- avgY = avgY * ((4 - time)^0.5 * 2) ^ dt
					-- avgZ = avgZ * ((4 - time)^0.5 * 2) ^ dt

					poly[1] = avgX + offsetX1
					poly[2] = avgY + offsetY1
					poly[3] = avgZ + offsetZ1

					poly[4] = avgX + offsetX2
					poly[5] = avgY + offsetY2
					poly[6] = avgZ + offsetZ2

					poly[7] = avgX + offsetX3
					poly[8] = avgY + offsetY3
					poly[9] = avgZ + offsetZ3

					if time >= disappearTimes[poly] then
						table.remove(model, i)
					end
				end

				if time > 3 then
					return true
				end
			end
			firework:remove({effect})

			local effectOnUpdate = firework.eventHandlers["update"]
			firework:on("update", function(dt)
				effectOnUpdate(dt)
				vy = vy + acceleration * 2 * dt
				local newY = firework.y + vy * dt
				firework:setPos(nil, newY, nil)
				-- vy = vy * 0.5^dt
			end)
		end
	end)
end

local stars = {}
for i = 1, 200 do
	local x = math.random() - 0.5
	local y = math.random()/2
	local z = math.random() - 0.5
	local color = colors.white
	if math.random() < 0.4 then
		color = colors.lightGray
	elseif math.random() < 0.2 then
		color = colors.yellow
	end
	stars[#stars+1] = {
		x = x,
		y = y,
		z = z,
		color = color,
	}
end

local fireworkTime = 0.5
local lastFireworkTime = os.epoch("utc")
scene:on("update", function(dt)
	local t = os.epoch("utc")
	if t > lastFireworkTime + fireworkTime*1000 then
		lastFireworkTime = t
		launchFirework()
		fireworkTime = math.random()
	end

	local camX = scene.camera.x
	local camY = scene.camera.y
	local camZ = scene.camera.z
	local colorBuffer = PW.frame.buffer.screenBuffer.c2
	for i = 1, #stars do
		local star = stars[i]
		local x, y, visible = PW.frame:map3dTo2d(star.x + camX, star.y + camY, star.z + camZ)
		if visible then
			x = math.floor(x + 0.5)
			y = math.floor(y + 0.5)
			if x >= 1 and y >= 1 then
				if x <= #colorBuffer[1] and y <= #colorBuffer then
					colorBuffer[y][x] = star.color
				end
			end
		end
	end
	-- for x = 1, 30 do
	-- 	for y = 1, 30 do
	-- 		colorBuffer[y][x] = colors.white
	-- 	end
	-- end
end)

PW.run()