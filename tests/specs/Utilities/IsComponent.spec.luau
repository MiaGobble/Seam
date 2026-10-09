return function(context)
    local describe = context.describe
    local it = context.it
    local expect = context.expect
    local Seam = context.Seam
    local Instance = context.Instance

    local IsComponent = Seam.IsComponent
    local Component = Seam.Component

    describe("IsComponent", function()
        it("returns false for non-components", function()
            expect(IsComponent(nil)).toBe(false)
            expect(IsComponent({})).toBe(false)
            expect(IsComponent(1)).toBe(false)
        end)

        it("returns true for Component constructors", function()
            local MyComponent = Component({
                Init = function() end,
                Construct = function()
                    return Instance.new("Folder")
                end,
            })

            expect(IsComponent(MyComponent)).toBe(true)
        end)
    end)
end
