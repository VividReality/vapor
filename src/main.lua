git,git_count = "missing git.lua",0
pcall(require, "git");

require("lib/json")
async = require("core/async") -- this needs to be required before "socket.http"

http = require("socket.http")

currently_downloading = {}

function imgname(gameobj)
  return gameobj.id..".png"
end

function fname(gameobj,sourceindex)
  return gameobj.id.."-"..sourceindex..".love"
end

local function execgame(binarypath, gamepath)
  local execstr
  if love._os == "Windows" then
    local fstr = [[start "" "%s" "%%APPDATA%%/LOVE/vapor-data/%s"]]
    execstr = fstr:format(binarypath, gamepath)
  else
    -- OS X, Linux
    local fstr = [["%s" "%s/%s"]]
    execstr = fstr:format(binarypath, love.filesystem.getSaveDirectory(), gamepath)
  end
  print(gamepath.." starting.")
  return os.execute(execstr)
end

function dogame(gameobj)

  local fn = fname(gameobj,gameobj.stable)
  if not currently_downloading[fn] then
    
    if love.filesystem.exists(fn) then
      print(fn .. " exists.")
      
      local hash
      if love.filesystem.exists(fn..".sha1") then
        hash = love.filesystem.read(fn..".sha1")
      end
      if gameobj.hashes[gameobj.stable] == hash then
        print(fn .. " hash validated.")
        selectindex = nil
        ui.headerindex = 0
        local status = execgame(binary, fn)
      else
        if gameobj.invalid then
          gameobj.invalid = nil
          love.filesystem.remove(fn)
          love.filesystem.remove(fn..".sha1")
        else
          gameobj.invalid = true
          print(fn .. " hash not validated.")
        end
      end
    else
      print(fn .. " is being downloaded.")
      local url = gameobj.sources[gameobj.stable]
      currently_downloading[fn] = true
      downloader:request(url, async.love_filesystem_sink(fn,true), function()
        currently_downloading[fn] = nil
      end)
    end
  
  end
end

function love.load(args)

  love.graphics.setCaption("Vapor - v"..git_count.." ["..git.."]")
  binary = love.arg.getLow(args)
  
  icons = require("core/icons")
  fonts = require("core/fonts")
  colors = require("core/colors")
  settings = require("core/settings")
  remote = require("core/remote")
  ui = require("core/ui")

  if args[2] == "clearcache" then
    love.filesystem.remove(settings.file)
    love.filesystem.remove(remote.file)
    print("Cleared "..settings.file.." and "..remote.file)
  end

  downloader = async.SocketQueue()
  downloader.dt = 0

  remote.load()
  settings.load()

  selectindex = nil

  love.graphics.setMode(love.graphics.getWidth(),settings.padding*(settings.gameshow+3)+settings.heading.h,false,false,0)
  
end

function love.update(dt)
  downloader:update()
  downloader.dt = downloader.dt + dt
  
  ui.update(dt)
  
end

function love.draw()
  ui.header(gameobj)
end

function love.keypressed(key)

  if key == "right" or key == "down" then
    if selectindex then
      selectindex = selectindex + 1
      if selectindex > #remote.data.games then
        selectindex = 1
      end    
    else
      selectindex = 1
    end
  elseif key == "left" or key == "up" then
    if selectindex then
      selectindex = selectindex - 1
      if selectindex < 1 then
        selectindex = #remote.data.games
      end
    else
      selectindex = #remote.data.games
    end
  elseif key == "return" or key == " " then
    if remote.data.games[selectindex] then
      dogame(remote.data.games[selectindex])
    end
  elseif key == "escape" then
    love.event.quit()
  elseif (key == "delete") or (key == "backspace") then
    local gameobj = remote.data.games[selectindex]
    if gameobj and not currently_downloading[fname(gameobj,gameobj.stable)] then
      love.filesystem.remove(fname(gameobj,gameobj.stable))
      love.filesystem.remove(fname(gameobj,gameobj.stable)..".sha1")
      love.filesystem.remove(imgname(gameobj))
      ui.images[selectindex] = nil
      gameobj.invalid = nil
    end
  end
end

function love.mousepressed(x,y,button)
  local gameobj = remote.data.games[selectindex]
  if button == "l" then
    if gameobj then
      dogame(gameobj)
    end
  elseif button == "r" then
    if gameobj then
      settings.data.games[gameobj.id].favorite = not settings.data.games[gameobj.id].favorite
    end
  end
end

function love.quit()
  local raw = json.encode(settings.data)
  love.filesystem.write(settings.file, raw)
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
