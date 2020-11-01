
# Biots

![biots Screenshot](https://github.com/chessboy/Biots/blob/master/Biots.png)

A prototype "software toy" built with [OctopusKit](https://github.com/InvadingOctopus/octopuskit) and SwiftAI's [NeuralNet](https://github.com/Swift-AI/NeuralNet) library. Biots allows you to evolve a population of ... todo...

## Adjusting Constants
You can play with all of the settings by editing `Constants.swift`

### Window Size and Graphics
As this is still a prototype, you'll need to set the window size in code:
```swift
static let windowWidth: CGFloat = 1920
```
The height of the window will be `windowWidth/φ` (where φ = golden ratio)

### Key Commands

|key|action|
|:-:|---|
|h|show/hide health indicator|
|shift-h|show/hide detailed health indicators|
|v|show/hide vision, 'on top of food' and 'on top of water' indicators|
|shift+v|show/hide seen objects|
|t|show/hide thrust, speed boost, and armor indicators|
|d|show/hide all indicators
|s|show/hide **biot** stats|
| | |
|a|select most fit **biot**|
|shift-a|select least fit **biot**|
|k|kill selected **biot**|
|shift-k|kill selected **biot** and select most fit **biot**|
|command-a|toggle speed mode (hides all nodes)|
|p|show/hide physics borders (good in combination with speed mode)|
| | |
|option-f|increase food supply by 1,000 units|
|option-shift-f|decrease food supply by 1,000 units|
|command-f|toggle algae fountain influence|
| | |
|+|zoom in camera|
|-|zoom out camera|
|→|move world left|
|←|move world right|
|↑|move world down|
|↓|move world up|
|z|set zoom to default|
| | |
|command-s |dump current genomes to console (as `json`)|
|command-shift-s |dump current world objects to console (as `json`)|

### Mouse Operations
- command-click a **biot** → set it as the 'tracked' **biot** (camera will follow)
- command-shift-click a **biot** → clicked **biot** becomes seed of ALL **biot**s in the dish (random mode only)
- left-click a **biot** → spawn 2 clones (with chance random mutation)
- right-click a **biot**, block or water source → kill that object
- f+click anywhere → add some **algae** in that area
- b+click anywhere → add a **block**
- w+click anywhere → add a **water source**
- w+shift-click anywhere → add a **mud source**
- shift-click a **block** or **water source** → drag to resize that object
