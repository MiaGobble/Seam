---
sidebar_position: 12
---

# EventSequence
A sequence of value changes and custom callbacks that can be played/stopped/etc at any time.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.4|No|

## Constructor
```lua
EventSequence({
	{
		Time : number,
		Callback : () -> nil,
	},

	-- ...
})
```

## Methods
#### `Play()`
Plays the event sequence in order of times provided.

#### `Stop()`
Stops the playing event sequence.

#### `Pause()`
Pauses the playing event sequence.

#### `Resume()`
Resumes the paused event sequence.

#### `Looped`
Setting `.Looped` to *true* will make sequences repeat after completion.

#### `LoopDelayTime`
Changes the amount of time to wait before looping (defaults to 0).

## Usage
`EventSequence` allows you to group timed callbacks with each other, and that group has methods to play and stop the sequence. This is particularly most helpful in applications such as complex animation, since it allows you to change values at time intervals.

Here is an example usage of this:

```lua
local EventSeqeuence = Seam.EventSequence({
	{1, function() -- Waits one second, then runs
		print("a")
	end},
	
	{2, function() -- Waits two seconds (plus the one from before), then runs
		print("b")
	end},
	
	{3, function() -- Waits three seconds (plus the three from before), then runs
		print("c")
	end},
})

EventSeqeuence:Play()
```

In an event sequence, you pass in an array of sequence keypoints. Each keypoint contains the following, ***in order***:
* A time, in seconds, when the keypoint will play (ordered and relative)
* A callback function for the keypoint