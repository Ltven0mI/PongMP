core = require("core")
core.registerStates(require("states"))

asset = require("assets")
asset.loadImages("assets/images")

advMath = require("libraries.advMath")
ui = require("libraries.ui")

core.registerSystem("menuMain", require("systems.menuMain"))
core.registerSystem("net", require("systems.network"))
core.registerSystem("game", require("systems.game"))

core.loadState("menu")