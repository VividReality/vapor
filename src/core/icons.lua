icons = {}

icons.play = love.graphics.newImage("assets/icons/go-next.png")
icons.view = love.graphics.newImage("assets/icons/applications-internet.png")
icons.download = love.graphics.newImage("assets/icons/emblem-web.png")
icons.favorite = love.graphics.newImage("assets/icons/help-about.png")
icons.favorite_off = love.graphics.newImage("assets/icons/help-about-off.png")
icons.delete = love.graphics.newImage("assets/icons/dialog-cancel.png")
icons.website = love.graphics.newImage("assets/icons/system-software-update.png")
icons.website_off = love.graphics.newImage("assets/icons/system-software-update-off.png")

icons.downloading = {}
icons.downloading[1] = love.graphics.newImage("assets/icons/network-idle.png")
icons.downloading[2] = love.graphics.newImage("assets/icons/network-receive.png")
icons.downloading[3] = love.graphics.newImage("assets/icons/network-transmit.png")
icons.downloading[4] = love.graphics.newImage("assets/icons/network-transmit-receive.png")

return icons
