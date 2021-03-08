color = {}

-- hex input as a string "ffffff"
function color.hex2rgb (hex) -- made by inferion (which is why it's trash) 
  local charTable = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
  local hexTable = {string.sub(hex,1,2),string.sub(hex,3,4),string.sub(hex,5,6)}
  local function findString(table,input)
    for i, v in ipairs(table) do
      if v == input then
        return i
      end
    end
  end
  local red = (findString(charTable,string.sub(hexTable[1],1,1)) - 1) * 16
  red = red + (findString(charTable,string.sub(hexTable[1],2,2)) - 1)
  local green = (findString(charTable,string.sub(hexTable[2],1,1)) - 1) * 16
  green = green + (findString(charTable,string.sub(hexTable[2],2,2)) - 1)
  local blue = (findString(charTable,string.sub(hexTable[3],1,1)) - 1) * 16
  blue = blue + (findString(charTable,string.sub(hexTable[3],2,2)) - 1)
  return red, green, blue
end
-- rgb output as three number variables r, g, b

-- rgb input as three number variables r, g, b
function color.rgb2hsl(r, g, b, a) -- from https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2
  local s
  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l, a or 255
end
-- hsl output as three number variables h, s, l

-- hsl input as three number variables, h, s, l
function color.hsl2rgb(h, s, l) -- from https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    function hue2rgb(p, q, t)
      if t < 0   then t = t + 1 end
      if t > 1   then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end

  return r * 255, g * 255, b * 255
end
-- rgb output as three number variables, r, g, b


-- rgb input as three number variables, r, g, b
function color.rgb2hex(r,g,b) -- from https://gist.github.com/marceloCodget/3862929
  local rgb = {r,g,b}
  local hexadecimal = ''

  for key, value in pairs(rgb) do
    local hex = ''

    while(value > 0)do
      local index = math.floor(math.fmod(value, 16) + 1)
      value = math.floor(value / 16)
      hex = string.sub('0123456789abcdef', index, index) .. hex     
    end

    if(string.len(hex) == 0)then
      hex = '00'

    elseif(string.len(hex) == 1)then
      hex = '0' .. hex
    end

    hexadecimal = hexadecimal .. hex
  end

  return hexadecimal
end
-- hex output as a string "ffffff"

-- hex input as a string "ffffff", hueshift input as a number 0.0-1.0
function color.hueshiftHex(hex,hueShift) -- made by inferion (which is why it's bad)
  local r, g, b = color.hex2rgb(hex)
  local h, s, l = color.rgb2hsl(r,g,b)
  h = (h + hueShift) % 1
  local r, g, b = color.hsl2rgb(h,s,l)
  local hex = color.rgb2hex(r,g,b)
  return hex
end
-- hex output as a string "ffffff"


-- hex input as a string "ffffff", transition as percentage 0-1
function color.transHex(hex1,hex2,percentage)
	percentage = math.min(math.max(percentage,0),1)
	local r1, g1, b1 = color.hex2rgb(hex1)
	local r2, g2, b2 = color.hex2rgb(hex2)
	local er = (r2 - r1) * percentage + r1
	local eg = (g2 - g1) * percentage + g1
	local eb = (b2 - b1) * percentage + b1
	return color.rgb2hex(er,eg,eb)
end
-- hex output as a string "ffffff"