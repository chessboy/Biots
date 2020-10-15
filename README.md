
## Biots

![biots Screenshot](https://github.com/chessboy/**biot**s/blob/master/**biot**s.png)

todo: Overview here...

todo: Playing with `Constants.swift` here... 

### Key Commands

|key|action|
|:-:|---|
|h|show/hide health indicator|
|shift-h|show/hide detailed health indicators|
|v|show/hide vision, 'on top of food' and 'on top of water' indicators|
|shift+v|show/hide seen objects|
|t|show/hide thrust, speed boost, and armor indicators|
|s|show/hide **biot** stats|
| | |
|a|select most fit **biot**|
|k|kill selected **biot**|
|shift-k|kill selected **biot** and select most fit **biot**|
|command-a|toggle speed mode (hides all nodes)|
|p|show/hide physics borders (good in combination with speed mode)|
| | |
|f|increase food supply by 1,000 units|
|shift-f|decrease food supply by 1,000 units|
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
- shift-click anywhere → add some **algae** in that area
- b+click → add a **block**
- w+click → add a **water source**
- shift-click a **block** or **water source** → drag to resize that object
