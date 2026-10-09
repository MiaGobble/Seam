return function(context)
    local describe = context.describe
    local it = context.it
    local expect = context.expect
    local Seam = context.Seam

    local IsState = Seam.IsState
    local Value = Seam.Value
    local Computed = Seam.Computed

    describe("IsState", function()
        it("returns false for non-tables", function()
            expect(IsState(nil)).toBe(false)
            expect(IsState(1)).toBe(false)
            expect(IsState("state")).toBe(false)
        end)

        it("returns false for plain tables", function()
            expect(IsState({})).toBe(false)
            expect(IsState({ Value = 1 })).toBe(false)
        end)

        it("returns true for Value and Computed states", function()
            local value = Value(1)
            local computed = Computed(function(use)
                return use(value) + 1
            end)

            expect(IsState(value)).toBe(true)
            expect(IsState(computed)).toBe(true)

            computed:Destroy()
            value:Destroy()
        end)
    end)
end
