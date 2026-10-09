-- Author: iGottic

-- Imports
local Constructors = script.Parent.Parent
local Modules = Constructors.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Computed = require(script.Parent.Computed)
local Value = require(script.Parent.Value)
local GetValue = require(Constructors.Utilities.GetValue)
local ValuePacker = require(Modules.ValuePacker)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local Symbol = require(Modules.Symbol)

-- Class
local Bezier : Types.ConstructorDecompiled = {}

Bezier.__SEAM_OBJECT = Symbol.new("Bezier")
Bezier.__SEAM_CAN_BE_SCOPED = true

local function ClampAlpha(AlphaValue : number) : number
    return math.clamp(AlphaValue, 0, 1)
end

local function GetBezierNumber(AlphaValue : number, OriginValue : number, MidpointValue : number, TargetValue : number) : number
    local InverseAlpha = 1 - AlphaValue
    return (InverseAlpha * InverseAlpha * OriginValue) + (2 * InverseAlpha * AlphaValue * MidpointValue) + (AlphaValue * AlphaValue * TargetValue)
end

local function GetBezierValue(AlphaValue : number, OriginValue : any, MidpointValue : any, TargetValue : any, ValueType : string) : any
    if ValueType == "number" then
        return GetBezierNumber(AlphaValue, OriginValue, MidpointValue, TargetValue)
    end

    local UnpackedOrigin = ValuePacker.UnpackValue(OriginValue, ValueType)
    local UnpackedMidpoint = ValuePacker.UnpackValue(MidpointValue, ValueType)
    local UnpackedTarget = ValuePacker.UnpackValue(TargetValue, ValueType)

    if #UnpackedOrigin == 0 then
        if AlphaValue <= 0 then
            return OriginValue
        elseif AlphaValue >= 1 then
            return TargetValue
        end

        return MidpointValue
    end

    local UnpackedBezier = {}

    for Index, OriginElement in UnpackedOrigin do
        UnpackedBezier[Index] = GetBezierNumber(AlphaValue, OriginElement, UnpackedMidpoint[Index], UnpackedTarget[Index])
    end

    return ValuePacker.PackValue(UnpackedBezier, ValueType)
end

function Bezier.__CALLBACK(_: Types.ConstructorCompiled, Alpha : any, Origin : any, Midpoint : any, Target : any) : Types.BezierInstance<any>
    local TroveInstance = Trove.new()
    local AttachedSignal = Signal.new()
    local AlphaValue = Value(GetValue(Alpha))
    local OriginValue = Value(GetValue(Origin))
    local MidpointValue = Value(GetValue(Midpoint))
    local TargetValue = Value(GetValue(Target))
    local ValueType = typeof(OriginValue.Value)
    local ActiveValue : Types.ObjectCompiled

    local function BindInput(Source : any, TargetState : any)
        if typeof(Source) == "table" and Source.__SEAM_OBJECT then
            TargetState.Value = GetValue(Source)

            return Source.Changed:Connect(function()
                TargetState.Value = GetValue(Source)
            end)
        end

        TargetState.Value = GetValue(Source)
        return nil
    end

    if typeof(AlphaValue.Value) ~= "number" then
        error("Bezier alpha must resolve to a number")
    end

    if typeof(MidpointValue.Value) ~= ValueType or typeof(TargetValue.Value) ~= ValueType then
        error("Bezier origin, midpoint, and target must resolve to the same type")
    end

    local BoundInputConnections = {
        Alpha = BindInput(Alpha, AlphaValue),
        Origin = BindInput(Origin, OriginValue),
        Midpoint = BindInput(Midpoint, MidpointValue),
        Target = BindInput(Target, TargetValue),
    }

    local ComputedValue = Computed(function(Use)
        local CurrentAlpha = Use(AlphaValue)
        local CurrentOrigin = Use(OriginValue)
        local CurrentMidpoint = Use(MidpointValue)
        local CurrentTarget = Use(TargetValue)

        if typeof(CurrentAlpha) ~= "number" then
            error("Bezier alpha must resolve to a number")
        end

        if typeof(CurrentOrigin) ~= ValueType or typeof(CurrentMidpoint) ~= ValueType or typeof(CurrentTarget) ~= ValueType then
            error("Bezier origin, midpoint, and target must resolve to the same type")
        end

        return GetBezierValue(ClampAlpha(CurrentAlpha), CurrentOrigin, CurrentMidpoint, CurrentTarget, ValueType)
    end)

    TroveInstance:Add(AlphaValue)
    TroveInstance:Add(OriginValue)
    TroveInstance:Add(MidpointValue)
    TroveInstance:Add(TargetValue)
    TroveInstance:Add(ComputedValue)
    TroveInstance:Add(ComputedValue.AttachedToInstance:Connect(function(Object)
        AttachedSignal:Fire(Object)
    end))

    local function RebindInput(Key : string, Source : any, TargetState : any)
        local CurrentConnection = BoundInputConnections[Key]

        if CurrentConnection ~= nil then
            if CurrentConnection.Connected then
                CurrentConnection:Disconnect()
            end

            BoundInputConnections[Key] = nil
        end

        BoundInputConnections[Key] = BindInput(Source, TargetState)
    end

    local BezierObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("Bezier"),
        AttachedToInstance = AttachedSignal,
    }

    function BezierObject.Destroy()
        for _, Connection in BoundInputConnections do
            if Connection ~= nil and Connection.Connected then
                Connection:Disconnect()
            end
        end

        table.clear(BoundInputConnections)
        TroveInstance:Destroy()
        TroveInstance = nil
    end

    function BezierObject.__CALLBACK(_: Types.ObjectCompiled, Object : any, Index : string)
        ComputedValue(Object, Index)
        return ActiveValue
    end

    function BezierObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        if Index == "Value" then
            return ComputedValue.Value
        elseif Index == "Changed" then
            return ComputedValue.Changed
        elseif Index == "Origin" then
            return Origin
        elseif Index == "Midpoint" then
            return Midpoint
        elseif Index == "Target" then
            return Target
        elseif Index == "Alpha" then
            return Alpha
        end

        return nil
    end

    function BezierObject.__NEWINDEX(_: Types.ObjectCompiled, Index : string, NewValue : any)
        if Index == "Origin" then
            Origin = NewValue
            RebindInput("Origin", NewValue, OriginValue)
        elseif Index == "Midpoint" then
            Midpoint = NewValue
            RebindInput("Midpoint", NewValue, MidpointValue)
        elseif Index == "Target" then
            Target = NewValue
            RebindInput("Target", NewValue, TargetValue)
        elseif Index == "Alpha" then
            Alpha = NewValue
            RebindInput("Alpha", NewValue, AlphaValue)
        elseif Index == "Value" then
            Origin = NewValue
            Midpoint = NewValue
            Target = NewValue
            RebindInput("Origin", NewValue, OriginValue)
            RebindInput("Midpoint", NewValue, MidpointValue)
            RebindInput("Target", NewValue, TargetValue)
        end
    end

    ActiveValue = Compiler.CompileObject(BezierObject)

    return ActiveValue :: Types.BezierInstance<any>
end

return Compiler.CompileConstructor(Bezier) :: Types.BezierConstructor<any>