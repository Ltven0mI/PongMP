core = require("core")
core.registerStates(require("states"))

asset = require("assets")
asset.loadImages("assets/images")

advMath = require("libraries.advMath")

core.registerSystem("menuMain", require("systems.menuMain"))

core.loadState("menu")