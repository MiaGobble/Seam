-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local StateManager = require(Modules.StateManager)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)

-- Class
local Value : Types.ConstructorDecompiled = {}

Value.__SEAM_INDEX = Symbol.new("Value")
Value.__SEAM_CAN_BE_SCOPED = true

function Value.__CALLBACK(_: Types.ConstructorCompiled, ThisValue : any)
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local IsLocked = false
    local ValueType = if ThisValue ~= nil then typeof(ThisValue) else nil
    local ActiveValue : Types.ObjectCompiled

    if ValueType == "table" then
        -- Seam values clone tables before using them
        ThisValue = table.clone(ThisValue)
    end

    local function CloneTableToPath(Path : {any}?)
        if typeof(ThisValue) ~= "table" then
            error("TableInsert, TableRemove, and TableSet can only be used when Value is a table")
        end

        local SafePath = if Path ~= nil then Path else {}

        if typeof(SafePath) ~= "table" then
            error("Path must be a table of keys")
        end

        local OldRoot = ThisValue
        local NewRoot = table.clone(OldRoot)
        local OldCursor = OldRoot
        local NewCursor = NewRoot

        for _, ThisKey in SafePath do
            local OldNext = OldCursor[ThisKey]

            if typeof(OldNext) ~= "table" then
                error("Path points to a non-table value")
            end

            local NewNext = table.clone(OldNext)
            NewCursor[ThisKey] = NewNext
            OldCursor = OldNext
            NewCursor = NewNext
        end

        return NewRoot, NewCursor
    end

    local function CloneTableToParentPath(Path : {any})
        if typeof(ThisValue) ~= "table" then
            error("TableSet with a path can only be used when Value is a table")
        end

        if #Path == 0 then
            error("Path must contain at least one key")
        end

        local OldRoot = ThisValue
        local NewRoot = table.clone(OldRoot)
        local OldCursor = OldRoot
        local NewCursor = NewRoot

        for ThisIndex = 1, #Path - 1 do
            local ThisKey = Path[ThisIndex]
            local OldNext = OldCursor[ThisKey]

            if typeof(OldNext) ~= "table" then
                error("Path points to a non-table value")
            end

            local NewNext = table.clone(OldNext)
            NewCursor[ThisKey] = NewNext
            OldCursor = OldNext
            NewCursor = NewNext
        end

        return NewRoot, OldCursor, NewCursor, Path[#Path]
    end

    --[[
        local This = Value(...)
        This.Value = x OR x = This.Value
        This.Changed -> As rbxscriptsignal
    --]]

    local ValueObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("Value"),
        Changed = ChangedSignal,
        AttachedToInstance = AttachedSignal,
    }

    function ValueObject.Destroy()
        TroveInstance:Destroy()
    end

    function ValueObject.TableInsert(_: Types.ObjectCompiled, InsertedValue : any, Path : {any}?)
        local NewRoot, TargetTable = CloneTableToPath(Path)

        table.insert(TargetTable, InsertedValue)

        ActiveValue.Value = NewRoot
    end

    function ValueObject.TableRemove(_: Types.ObjectCompiled, RemovedValueIndex : number, Path : {any}?)
        if typeof(RemovedValueIndex) ~= "number" then
            error("RemovedValueIndex must be a number")
        end

        local NewRoot, TargetTable = CloneTableToPath(Path)

        table.remove(TargetTable, RemovedValueIndex)

        ActiveValue.Value = NewRoot
    end

    function ValueObject.TableSet(_: Types.ObjectCompiled, NewTargetValue : any, Path : {any}?)
        local SafePath = if Path ~= nil then Path else {}

        if typeof(SafePath) ~= "table" then
            error("Path must be a table of keys")
        end

        if #SafePath == 0 then
            ActiveValue.Value = NewTargetValue
            return
        end

        local NewRoot, _, NewParent, LastKey = CloneTableToParentPath(SafePath)
        NewParent[LastKey] = NewTargetValue
        ActiveValue.Value = NewRoot
    end

    function ValueObject.__CALLBACK(_: Types.ObjectCompiled, Object : any, Index : string)
        if not Object then
            return
        end

        if not Index then
            return
        end

        if typeof(ThisValue) == "table" and ThisValue ~= nil then
            Object[Index] = table.clone(ThisValue)
        else
            Object[Index] = ThisValue
        end

        AttachedSignal:Fire(Object)

        TroveInstance:Add(StateManager:AttachStateToObject(Object, {
            Value = function()
                if typeof(ThisValue) == "table" and ThisValue ~= nil then
                    return table.clone(ThisValue)
                else
                    return ThisValue
                end
            end,

            PropertyName = Index
        }))
    end

    function ValueObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        if Index == "Value" then
            return ThisValue
        end

        return nil
    end

    function ValueObject.__NEWINDEX(_: Types.ObjectCompiled, Index : string, NewValue : any)
        if Index == "Value" then
            if IsLocked then
                error("Attempt to modify value when locked.")
            end

            if ValueType ~= nil then
                if NewValue ~= nil and typeof(NewValue) ~= ValueType then
                    error("Invalid value type! Expected " .. ValueType .. ", got " .. typeof(NewValue))
                end
            elseif NewValue ~= nil then
                ValueType = typeof(NewValue)
            end

            if not IsValueChanged(ThisValue, NewValue) then
                return
            end

            ThisValue = NewValue

            -- Make sure to fire the changed signal for other states
            Batch.Fire(ChangedSignal, "Value", ThisValue)
            return
        elseif Index == "__LOCKED" then
            if NewValue == true then
                IsLocked = true
                ActiveValue:Destroy()
                return
            else
                error("Can not unlock values.")
            end
        else
            error("Ran into an unexpected error")
        end
    end

    ActiveValue = Compiler.CompileObject(ValueObject)

    return ActiveValue :: Types.ValueInstance<any>
end

return Compiler.CompileConstructor(Value) :: Types.ValueConstructor<any>