return function(context)
    local describe = context.describe
    local it = context.it
    local expect = context.expect
    local Compiler = context.Compiler

    describe("Compiler", function()
        it("compiles a constructor and invokes __CALLBACK", function()
            local calls = {}
            local Constructor = {
                __SEAM_CAN_BE_SCOPED = false,
                __CALLBACK = function(_, value)
                    table.insert(calls, value)
                    return value * 2
                end,
            }

            local Compiled = Compiler.CompileConstructor(Constructor)

            expect(Compiled.__SEAM_CAN_BE_SCOPED).toBe(false)
            expect(Compiled(21)).toBe(42)
            expect(calls).toEqual({ 21 })
        end)

        it("compiles an object with call, index, and newindex hooks", function()
            local stored = nil
            local Object = {
                Name = "Seam",
                __CALLBACK = function(_, value)
                    return `hello {value}`
                end,
                __INDEX = function(_, key)
                    if key == "Value" then
                        return stored
                    end

                    return nil
                end,
                __NEWINDEX = function(_, key, value)
                    if key == "Value" then
                        stored = value
                    end
                end,
            }

            local Compiled = Compiler.CompileObject(Object)

            expect(Compiled.Name).toBe("Seam")
            expect(Compiled("world")).toBe("hello world")

            Compiled.Value = 5
            expect(Compiled.Value).toBe(5)
        end)

        it("preserves falsy backend indexes", function()
            local Compiled = Compiler.CompileConstructor({
                __SEAM_CAN_BE_SCOPED = false,
                __CALLBACK = function()
                    return true
                end,
            })

            expect(Compiled.__SEAM_CAN_BE_SCOPED).toBe(false)
        end)
    end)
end
