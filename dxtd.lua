engine.name = 'D'

local gfx = include("lib/gfx")
local alt = false
local page = 1

matrix = {}
for i = 1, 3 do
  matrix[i] = {
    sr = 0,
    bd = 0,
    sat = 0,
    co = 0,
    hb = 0,
    lb = 0,
    hs = 0
  }
end

sweetspots = {}
for i = 1, 2 do
  sweetspots[i] = {nil}
  sweetspots[i].has_data = false
end

command = ""
function build_command(n)
  command = command .. n
end

function process_command(n)
  if #n == 4 then
    if n == "2222" then
      params:set("sample_rate", 48000)
      params:set("bit_depth", 32)
    elseif n == "2223" then
      params:set("saturation", 5)
      params:set("crossover", 2000)
      params:set("highbias", 0.14)
      params:set("lowbias", 0.01)
      params:set("hiss", 0.001)
      params:set("gate_threshold", 0.01)
    elseif n == "2232" then
      for i = 1, 3 do
        params:set("sr" .. i, math.random(-100, 100))
        params:set("bd" .. i, math.random(-100, 100))
        params:set("sat" .. i, math.random(-100, 100))
        params:set("co" .. i, math.random(-100,100))
        params:set("hb" .. i, math.random(-100, 100))
        params:set("lb" .. i, math.random(-100, 100))
        params:set("hs" .. i, math.random(-100, 100))
      end
     elseif n == "2233" then
      for i = 1, 2 do
        sweetspots[i] = {nil}
        sweetspots[i].has_data = false
       end
    elseif n == "2322" then
      for i = 1, #gfx.param_ids do
        sweetspots[1][i] = params:get(gfx.param_ids[i])
      end
      sweetspots[1].has_data = true
    elseif n == "2323" then
      for i = 1, #gfx.param_ids do
        sweetspots[2][i] = params:get(gfx.param_ids[i])
      end
      sweetspots[2].has_data = true
    elseif n == "3322" then
      page = 1
    elseif n == "3323" then
      page = 2
    elseif n == "3332" then
      page = 3
    end
  end
  command = ""
end

function init()
  local pcount = params.count + 1
  
  for i = 1, 3 do
    params:add_number("sr" .. i, "sr" .. i, -100, 100, math.random(-100, 100))
    params:set_action("sr" .. i, function(v) matrix[i].sr = v end)

    params:add_number("bd" .. i, "bd" .. i, -100, 100, math.random(-100, 100))
    params:set_action("bd" .. i, function(v) matrix[i].bd = v end)
    
    params:add_number("sat" .. i, "sat" .. i,-100, 100, math.random(-100, 100))
    params:set_action("sat" .. i, function(v) matrix[i].sat = v end)

    params:add_number("co" .. i, "co" .. i, -100, 100, math.random(-100, 100))
    params:set_action("co" .. i, function(v) matrix[i].co = v end)

    params:add_number("hb" .. i, "hb" .. i, -100, 100, math.random(-100, 100))
    params:set_action("hb" .. i, function(v) matrix[i].h = v end)
    
    params:add_number("lb" .. i, "lb" .. i, -100, 100, math.random(-100, 100))
    params:set_action("lb" .. i, function(v) matrix[i].l = v end)

    params:add_number("hs" .. i, "hs" .. i, -100, 100, math.random(-100, 100))
    params:set_action("hs" .. i, function(v) matrix[i].hs = v end)
  end

  for i = pcount, params.count do
    params:hide(i)
  end

  params:add_separator("engine")
  params:add_control("sample_rate", "sample rate", controlspec.new(2000, 48000, "exp", 1, 48000, '', 0.001, false))
  params:set_action("sample_rate", function(x) engine.srate(x) end)
  params:add_control("bit_depth", "bit depth", controlspec.new(1, 32, "lin", 0, 32, '', 0.01, false))
  params:set_action("bit_depth", function(x) engine.sdepth(x) end)
  params:add_control("saturation", "saturation", controlspec.new(10, 500, "exp", 1, 15, '', 0.01, false))
  params:set_action("saturation", function(x) engine.distAmount(x) end)
  params:add_control("crossover", "crossover", controlspec.new(50, 10000, "lin", 10, 2000, '', 0.01, false))
  params:set_action("crossover", function(x) engine.crossover(x) end)
  params:add_control("highbias", "highbias", controlspec.new(0.001, 1, "lin", 0.001, 0.12, '', 0.01, false))
  params:set_action("highbias", function(x) engine.highbias(x) end)
  params:add_control("lowbias", "lowbias", controlspec.new(0.001, 1, "lin", 0.001, 0.04, '', 0.01, false))
  params:set_action("lowbias", function(x) engine.lowbias(x) end)
  params:add_control("hiss", "hiss", controlspec.new(0, 10, "lin", 0.01, 0.001, '', 0.01, true))
  params:set_action("hiss", function(x) engine.hissAmount(x) end)
  params:add_control("gate_threshold", "gate threshold", controlspec.new(0.0, 1.0, "lin", 0, 0.01, '', 0.001, false))
  params:set_action("gate_threshold", function(x) engine.gateThreshold(x) end)

  params:bang()

  local screen_metro = metro.init()
  screen_metro.time = 1/10
  screen_metro.event = function() redraw() end
  screen_metro:start()
end

function enc(n, d)
  params:delta("sample_rate", d * util.linlin(-100, 100, 0, 1, matrix[n].sr))
  params:delta("bit_depth", d * util.linlin(-100, 100, 0, 1, matrix[n].bd))
  params:delta("saturation", d * util.linlin(-100, 100, 0, 1, matrix[n].sat))
  params:delta("crossover", d * util.linlin(-100, 100, 0, 1, matrix[n].co))
  params:delta("highbias", d * util.linlin(-100, 100, 0, 1, matrix[n].h))
  params:delta("lowbias", d * util.linlin(-100, 100, 0, 1, matrix[n].l))
  params:delta("hiss", d * util.linlin(-100, 100, 0, 1, matrix[n].hs))
end

function key(n, z)
  if n == 1 then alt = z == 1 and true or false end
  
  if alt then
    if n == 2 and z == 1 then
      build_command("2")
    elseif n == 3 and z == 1 then
      build_command("3")
    end
  else
    if n == 2 and z == 1 then
      if sweetspots[1].has_data == true then
        for i = 1, #gfx.param_ids do
          params:set(gfx.param_ids[i], sweetspots[1][i])
        end
      end
    elseif n == 3 and z == 1 then
      if sweetspots[2].has_data == true then
        for i = 1, #gfx.param_ids do
          params:set(gfx.param_ids[i], sweetspots[2][i])
        end
      end
    end
    process_command(command)
  end
end

function redraw()
  screen.aa(0)
  screen.blend_mode(0)
  screen.clear()
  screen.level(16)
  screen.font_face(25)
  screen.font_size(6)
  screen.move(5, 5)
  if page == 1 then
    gfx.draw_bullshit()
  elseif page == 2 then
    gfx.draw_engine()
  elseif page == 3 then
    gfx.draw_matrix()
  end
  if alt then gfx.draw_command() end
  screen.update()
end
