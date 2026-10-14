---
sidebar_position: 12
---

# EventSequence
A playable sequence of timed callbacks.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.4|Yes|

## Constructor
```lua
EventSequence({
	{ TimeDelta : number, Callback : () -> () },
	-- ...
}) -> EventSequence
```

Keyframes must be an array. Each entry is `{number, function}` — first the relative delay in seconds, then the callback. Dictionary keys error.

## Properties
#### `Looped : boolean`
When `true`, the sequence restarts after the last keyframe. Defaults to `false`.

#### `LoopDelayTime : number`
Extra wait before looping, in seconds. Defaults to `0`.

## Methods
#### `Play()`
Starts playback. If already playing, stops and restarts.

#### `Stop()`
Stops playback and resets progress.

#### `Pause()`
Pauses while playing. No-op if not playing.

#### `Resume()`
Resumes a paused sequence. No-op if not playing.

## Usage
Times are **relative deltas**, summed with previous keyframes:

```lua
local Sequence = Seam.EventSequence({
	{1, function() -- After 1s
		print("a")
	end},
	{2, function() -- After 1 + 2 = 3s total
		print("b")
	end},
	{3, function() -- After 1 + 2 + 3 = 6s total
		print("c")
	end},
})

Sequence.Looped = true
Sequence.LoopDelayTime = 0.5
Sequence:Play()
```

Playback advances on Seam's frame-update signal (`RenderStepped` on the client, `Heartbeat` on the server).
