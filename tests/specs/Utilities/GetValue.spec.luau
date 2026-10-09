return function(context)
    local describe = context.describe
    local it = context.it
    local expect = context.expect
    local Seam = context.Seam

    local GetValue = Seam.GetValue
    local Value = Seam.Value

    describe("GetValue", function()
        it("returns nil for nil input", function()
            expect(GetValue(nil)).toBeNil()
        end)

        it("returns plain values unchanged", function()
            expect(GetValue(42)).toBe(42)
            expect(GetValue("hello")).toBe("hello")
        end)

        it("returns the current value from a Value state", function()
            local state = Value(10)
            expect(GetValue(state)).toBe(10)

            state.Value = 20
            expect(GetValue(state)).toBe(20)

            state:Destroy()
        end)
    end)
end
