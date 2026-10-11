-- Forked from the Oklab module used in Fusion.

local Oklab = {}

function Oklab.ToOklab(RobloxColor: Color3): Vector3
	local LongConeResponse = RobloxColor.R * 0.4122214708 + RobloxColor.G * 0.5363325363 + RobloxColor.B * 0.0514459929
	local MediumConeResponse = RobloxColor.R * 0.2119034982 + RobloxColor.G * 0.6806995451 + RobloxColor.B * 0.1073969566
	local ShortConeResponse = RobloxColor.R * 0.0883024619 + RobloxColor.G * 0.2817188376 + RobloxColor.B * 0.6299787005

	local LongConeCubicRoot = LongConeResponse ^ (1 / 3)
	local MediumConeCubicRoot = MediumConeResponse ^ (1 / 3)
	local ShortConeCubicRoot = ShortConeResponse ^ (1 / 3)

	local OklabLightness = LongConeCubicRoot * 0.2104542553 + MediumConeCubicRoot * 0.7936177850 - ShortConeCubicRoot * 0.0040720468
	local OklabA = LongConeCubicRoot * 1.9779984951 - MediumConeCubicRoot * 2.4285922050 + ShortConeCubicRoot * 0.4505937099
	local OklabB = LongConeCubicRoot * 0.0259040371 + MediumConeCubicRoot * 0.7827717662 - ShortConeCubicRoot * 0.8086757660

	return Vector3.new(OklabLightness, OklabA, OklabB)
end

function Oklab.FromOklab(OklabColor: Vector3, ReturnUnclamped: boolean?): Color3
	local LongConeCubicRoot = OklabColor.X + OklabColor.Y * 0.3963377774 + OklabColor.Z * 0.2158037573
	local MediumConeCubicRoot = OklabColor.X - OklabColor.Y * 0.1055613458 - OklabColor.Z * 0.0638541728
	local ShortConeCubicRoot = OklabColor.X - OklabColor.Y * 0.0894841775 - OklabColor.Z * 1.2914855480

	local LongConeResponse = LongConeCubicRoot ^ 3
	local MediumConeResponse = MediumConeCubicRoot ^ 3
	local ShortConeResponse = ShortConeCubicRoot ^ 3

	local RedChannel = LongConeResponse * 4.0767416621 - MediumConeResponse * 3.3077115913 + ShortConeResponse * 0.2309699292
	local GreenChannel = LongConeResponse * -1.2684380046 + MediumConeResponse * 2.6097574011 - ShortConeResponse * 0.3413193965
	local BlueChannel = LongConeResponse * -0.0041960863 - MediumConeResponse * 0.7034186147 + ShortConeResponse * 1.7076147010

	if not ReturnUnclamped then
		RedChannel = math.clamp(RedChannel, 0, 1)
		GreenChannel = math.clamp(GreenChannel, 0, 1)
		BlueChannel = math.clamp(BlueChannel, 0, 1)
	end

	return Color3.new(RedChannel, GreenChannel, BlueChannel)
end

return Oklab
