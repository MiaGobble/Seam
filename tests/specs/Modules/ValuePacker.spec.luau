return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local roblox = context.roblox

	local ValuePacker = context.requirePath({ "Modules", "ValuePacker" })

	local function roundTrip(value, valueType)
		return ValuePacker.PackValue(ValuePacker.UnpackValue(value, valueType), valueType)
	end

	describe("ValuePacker", function()
		it("round-trips animatable values", function()
			expect(roundTrip(4.5, "number")).toBe(4.5)

			local vector2 = roblox.Vector2.new(1, -2)
			expect(roundTrip(vector2, "Vector2")).toBe(vector2)

			local vector3 = roblox.Vector3.new(1, 2, 3)
			expect(roundTrip(vector3, "Vector3")).toBe(vector3)

			local vector2int = roblox.Vector2int16.new(4, 5)
			expect(roundTrip(vector2int, "Vector2int16")).toBe(vector2int)

			local vector3int = roblox.Vector3int16.new(4, 5, 6)
			expect(roundTrip(vector3int, "Vector3int16")).toBe(vector3int)

			local udim = roblox.UDim.new(0.5, 8)
			local packedUDim = roundTrip(udim, "UDim")
			expect(packedUDim.Scale).toBeCloseTo(udim.Scale)
			expect(packedUDim.Offset).toBeCloseTo(udim.Offset)

			local udim2 = roblox.UDim2.new(0.25, 1, 0.5, 2)
			local packedUDim2 = roundTrip(udim2, "UDim2")
			expect(packedUDim2.X.Scale).toBeCloseTo(0.25)
			expect(packedUDim2.X.Offset).toBeCloseTo(1)
			expect(packedUDim2.Y.Scale).toBeCloseTo(0.5)
			expect(packedUDim2.Y.Offset).toBeCloseTo(2)

			local range = roblox.NumberRange.new(1, 4)
			local packedRange = roundTrip(range, "NumberRange")
			expect(packedRange.Min).toBeCloseTo(1)
			expect(packedRange.Max).toBeCloseTo(4)

			local rect = roblox.Rect.new(1, 2, 3, 4)
			local packedRect = roundTrip(rect, "Rect")
			expect(packedRect.Min.X).toBeCloseTo(1)
			expect(packedRect.Max.Y).toBeCloseTo(4)

			local ray = roblox.Ray.new(roblox.Vector3.new(1, 2, 3), roblox.Vector3.new(0, 1, 0))
			local packedRay = roundTrip(ray, "Ray")
			expect(packedRay.Origin).toBe(ray.Origin)
			expect(packedRay.Direction).toBe(ray.Direction)

			local color = roblox.Color3.new(0.2, 0.4, 0.8)
			local packedColor = roundTrip(color, "Color3")
			expect(packedColor.R).toBeCloseTo(color.R, 1e-3)
			expect(packedColor.G).toBeCloseTo(color.G, 1e-3)
			expect(packedColor.B).toBeCloseTo(color.B, 1e-3)

			local keypoint = roblox.ColorSequenceKeypoint.new(0.25, color)
			local packedKeypoint = roundTrip(keypoint, "ColorSequenceKeypoint")
			expect(packedKeypoint.Time).toBeCloseTo(0.25)
			expect(packedKeypoint.Value.R).toBeCloseTo(color.R, 1e-3)

			local numberKey = roblox.NumberSequenceKeypoint.new(0.5, 2, 0.1)
			local packedNumberKey = roundTrip(numberKey, "NumberSequenceKeypoint")
			expect(packedNumberKey.Time).toBeCloseTo(0.5)
			expect(packedNumberKey.Value).toBeCloseTo(2)
			expect(packedNumberKey.Envelope).toBeCloseTo(0.1)

			local properties = roblox.PhysicalProperties.new(1, 0.3, 0.5, 1, 1)
			local packedProperties = roundTrip(properties, "PhysicalProperties")
			expect(packedProperties.Density).toBeCloseTo(properties.Density)
			expect(packedProperties.Friction).toBeCloseTo(properties.Friction)
			expect(packedProperties.Elasticity).toBeCloseTo(properties.Elasticity)

			local frame = roblox.CFrame.new(1, 2, 3)
			local packedFrame = roundTrip(frame, "CFrame")
			expect(packedFrame.X).toBeCloseTo(frame.X)
			expect(packedFrame.Y).toBeCloseTo(frame.Y)
			expect(packedFrame.Z).toBeCloseTo(frame.Z)

			local region = roblox.Region3.new(roblox.Vector3.new(0, 0, 0), roblox.Vector3.new(2, 4, 6))
			local packedRegion = roundTrip(region, "Region3")
			expect(packedRegion.Size.X).toBeCloseTo(region.Size.X)
			expect(packedRegion.Size.Y).toBeCloseTo(region.Size.Y)
			expect(packedRegion.CFrame.Y).toBeCloseTo(region.CFrame.Y)

			local regionInt =
				roblox.Region3int16.new(roblox.Vector3int16.new(0, 1, 2), roblox.Vector3int16.new(3, 4, 5))
			local packedRegionInt = roundTrip(regionInt, "Region3int16")
			expect(packedRegionInt.Min.X).toBe(regionInt.Min.X)
			expect(packedRegionInt.Max.Z).toBe(regionInt.Max.Z)

			local timestamp = roblox.DateTime
			if timestamp == nil then
				local packedTime = roundTrip({ UnixTimestampMillis = 1500 }, "DateTime")
				expect(packedTime.UnixTimestampMillis).toBe(1500)
			end
		end)

		it("returns an empty unpack for unsupported types", function()
			expect(ValuePacker.UnpackValue(true, "boolean")).toEqual({})
			expect(ValuePacker.PackValue({}, "boolean")).toBeNil()
		end)
	end)
end
