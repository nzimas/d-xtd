local d = {}

d.param_ids = {
  "sample_rate",
  "bit_depth",
  "saturation",
  "crossover",
  "highbias",
  "lowbias",
  "hiss",
  "gate_threshold"
}

d.param_shorts = {
  "sr",
  "bd",
  "sat",
  "co",
  "hb",
  "lb",
  "hs",
  "gt"
}

bullshit = {}
bullshit.x = {
  0,
  35,
  75,
  5,
  32,
  60,
  82,
  105
}

bullshit.y = {
  30,
  33,
  28,
  60,
  55,
  62,
  50,
  42
}

function get_size_level(p)
  local srsaths = false
  if p == "saturation" or p == "saturation" or p == "hiss" then
    srsaths = true
  end

  local mi, ma, va = params:get_range(p)[1], params:get_range(p)[2], params:get(p)
  local size, level = util.linlin(mi, ma, srsaths and 36 or 24, srsaths and 48 or 36, va), math.floor(util.linlin(mi, ma, 1, 16, va))
  local table = {size, level}
  return table
end

function d.draw_matrix()
  screen.move(0, 5)
  screen.text("sr")
  screen.move(20, 5)
  screen.text("bd")
  screen.move(40, 5)
  screen.text("sat")
  screen.move(60, 5)
  screen.text("co")
  screen.move(80, 5)
  screen.text("hb")
  screen.move(100, 5)
  screen.text("lb")
  screen.move(120, 5)
  screen.text("hs")
  
  screen.move(0, 10)
  screen.line(127,10)
  screen.stroke()

  screen.move(0, 24)
  screen.text(params:get("sr1"))
  screen.move(20, 24)
  screen.text(params:get("bd1"))
  screen.move(40, 24)
  screen.text(params:get("sat1"))
  screen.move(60, 24)
  screen.text(params:get("co1"))
  screen.move(80, 24)
  screen.text(params:get("hb1"))
  screen.move(100, 24)
  screen.text(params:get("lb1"))
  screen.move(120, 24)
  screen.text(params:get("hs1"))
  
  screen.move(0, 44)
  screen.text(params:get("sr2"))
  screen.move(20, 44)
  screen.text(params:get("bd2"))
  screen.move(40, 44)
  screen.text(params:get("sat2"))
  screen.move(60, 44)
  screen.text(params:get("co2"))
  screen.move(80, 44)
  screen.text(params:get("hb2"))
  screen.move(100, 44)
  screen.text(params:get("lb2"))
  screen.move(120, 44)
  screen.text(params:get("hs2"))
  
  screen.move(0, 64)
  screen.text(params:get("sr3"))
  screen.move(20, 64)
  screen.text(params:get("bd3"))
  screen.move(40, 64)
  screen.text(params:get("sat3"))
  screen.move(60, 64)
  screen.text(params:get("co3"))
  screen.move(80, 64)
  screen.text(params:get("hb3"))
  screen.move(100, 64)
  screen.text(params:get("lb3"))
  screen.move(120, 64)
  screen.text(params:get("hs3"))
end

function d.draw_engine()
  screen.move(3, 5)
  screen.text("sample rate: " .. params:get("sample_rate"))
  screen.move(3, 13)
  screen.text("bit depth: ".. params:get("bit_depth"))
  screen.move(3, 21)
  screen.text("saturation: " .. params:get("saturation"))
  screen.move(3, 29)
  screen.text("crossover: " .. params:get("crossover"))
  screen.move(3, 37)
  screen.text("highbias: " .. params:get("highbias"))
  screen.move(3, 45)
  screen.text("lowbias: " .. params:get("lowbias"))
  screen.move(3, 53)
  screen.text("hiss: " .. params:get("hiss"))
  screen.move(3, 61)
  screen.text("gate: " .. params:get("gate_threshold"))
end

function d.draw_bullshit()
  for i = 1, #d.param_ids do
    screen.move(bullshit.x[i], bullshit.y[i])
    screen.font_face(math.random(1, 56))
    screen.font_size(get_size_level(d.param_ids[i])[1])
    screen.level(get_size_level(d.param_ids[i])[2])
    if i == 4 then
      screen.text_rotate(bullshit.x[i], bullshit.y[i], d.param_shorts[i], -15)
    elseif i == 7 then
      screen.text_rotate(bullshit.x[i], bullshit.y[i], d.param_shorts[i], 15)
    elseif i == 8 then
      screen.text_rotate(bullshit.x[i], bullshit.y[i], d.param_shorts[i], -10)
    else
      screen.text(d.param_shorts[i])
    end
  end
end

function d.draw_command()
  screen.move(0, 20)
  screen.rect(0, 12, 127, 45)
  screen.level(1)
  screen.blend_mode(5)
  screen.fill()
  screen.stroke()
  
  screen.blend_mode(0)
  screen.font_face(14)
  screen.move(68, 55)
  screen.level(0)
  screen.font_size(52)
  screen.text_center(command)
  screen.move(64, 52)
  screen.level(16)
  screen.font_size(52)
  screen.text_center(command)
end

return d
