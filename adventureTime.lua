<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE muclient>

<muclient>
<plugin
   name="Adventure_Time_Miniwindow"
   author="Pokey"
   id="48062dcd6b968c590df50ae5"
   language="Lua"
   purpose="Shows different guild gp in a mini window"
   date_written="2009-02-24 13:30"
   requires="4.40"
   version="1.0"
   save_state="y"
   >
<description trim="y">
<![CDATA[
Install this plugin to show an info bar with all different guild GPs

The window can be dragged to a new location with the mouse.
]]>
</description>

</plugin>

<!--  Triggers  -->

<triggers>
  <trigger
   custom_colour="3"
   enabled="y"
   group="gp_stats"
   ignore_case="y"
   keep_evaluating="y"
   match="^\s{1,7}(Total|Adventuring|Covert|Crafts|Faith|Fighting|Magic|People):\s{1,}((?:|-)\d{1,3})\s\((\d{2,3})\)$"
   regexp="y"
   repeat="y"
   sequence="90"
   send_to="12"
   other_text_colour="silver"
       >
  <send>
     statItem("%1", "%2", "%3")
     </send>
  </trigger>
</triggers>

<!--  Aliases  -->

<aliases>
     muclient_version="5.06"
     world_file_version="15"
     date_saved="2021-04-16 21:34:43">
    <alias
     match="^adventuretime regen (\d)$"
     enabled="y"
     group="weapon aliases"
     regexp="y"
     send_to="12"
     sequence="100"
       >
       <send>
       local regen = tonumber("%1")
       if regen > 4 then
         regen = 4
       end
       update_regen(regen)
     </send>
    </alias>
</aliases>

<!--  Timers  -->

 <timers>
    <timer
     second="2" 
     script="UpdateGPGeneration"
     active_closed="y"
     name="adventure_time_gp_timer"
       >
    </timer>
  </timers>
<!--  Script  -->


<script>
<![CDATA[

GAUGE_LEFT = 120
GAUGE_HEIGHT = 15

WINDOW_WIDTH = 282
WINDOW_HEIGHT = 160
NUMBER_OF_TICKS = 5

BACKGROUND_COLOUR = ColourNameToRGB "rosybrown"
FONT_COLOUR = ColourNameToRGB "darkred"
BORDER_COLOUR = ColourNameToRGB "#553333"

stat_names = {"Total", "Adventuring", "Covert", "Crafts", "Faith", "Fighting", "Magic", "People"}

stat_colours = { 
  ["Total"] = "orange",
  ["Adventuring"] = "forestgreen",
  ["Covert"] = "indigo",
  ["Crafts"] = "gold",
  ["Faith"] = "cyan",
  ["Fighting"] = "crimson",
  ["Magic"] = "violet",
  ["People"] = "white"}

gp_regen = 3

-- Init stats
stats = {}
for _, stat in pairs(stat_names) do
  stats[stat] = {}
  stats[stat]["current"] = 0
  stats[stat]["max"] = 1
end

last_max_gp = 1
last_gp = 0

function update_regen(new_value)
   gp_regen = new_value
   print(string.format("AdventureTime GP regen set to %d", gp_regen))
end

function OnPluginMXPsetEntity (sIn, bDelayUpdates)
  local sValue = utils.split(sIn, '=')
  if (sValue[1] == "maxgp") then
    if (sValue[2] ~= last_max_gp) then
      if tonumber(sValue[2]) < 1 then
        stats["Total"]["max"] = "1"
      else
        stats["Total"]["max"] = sValue[2]
      end
      UpdateDerivedGP()
      do_update()
      last_max_gp = sValue[2]
    end
  elseif (sValue[1] == "gp") then
    if (sValue[2] ~= last_current_gp) then
      stats["Total"]["current"] = sValue[2] 
      UpdateDerivedGP()
      do_update()
      last_gp = sValue[2]
    end
  end

end

function UpdateGPGeneration()
  local total, total_max = tonumber (stats["Total"]["current"]),
    tonumber (stats["Total"]["max"])
  if (total < total_max and gp_regen > 0) then
    total = total + gp_regen
    if (total > total_max) then
      total = total_max
    end
    stats["Total"]["current"] = total
    UpdateDerivedGP()
    do_update()
  end
end

function UpdateDerivedGP()
  local total, total_max = tonumber (stats["Total"]["current"]),
    tonumber (stats["Total"]["max"])
  for _, stat in pairs(stat_names) do
    stats[stat]["current"] = stats[stat]["max"] + total - total_max
  end
end

function mousedown(flags, hotspot_id)

  -- find where mouse is so we can adjust window relative to mouse
  startx, starty = WindowInfo (win, 14), WindowInfo (win, 15)
  
  -- find where window is in case we drag it offscreen
  origx, origy = WindowInfo (win, 10), WindowInfo (win, 11)
end -- mousedown

function dragmove(flags, hotspot_id)

  -- find where it is now
  local posx, posy = WindowInfo (win, 17),
                     WindowInfo (win, 18)

  -- move the window to the new location
  WindowPosition(win, posx - startx, posy - starty, 0, 2);
  
  -- change the mouse cursor shape appropriately
  if posx < 0 or posx > GetInfo (281) or
     posy < 0 or posy > GetInfo (280) then
    check (SetCursor ( 11))   -- X cursor
  else
    check (SetCursor ( 1))   -- hand cursor
  end -- if
  
end -- dragmove

function dragrelease(flags, hotspot_id)
  local newx, newy = WindowInfo (win, 17), WindowInfo (win, 18)
  
  -- don't let them drag it out of view
  if newx < 0 or newx > GetInfo (281) or
     newy < 0 or newy > GetInfo (280) then
     -- put it back
    WindowPosition(win, origx, origy, 0, 2);
  end -- if out of bounds
  
end -- dragrelease


function DoGauge (sPrompt, Percent, Colour, Margin)

  local Fraction = tonumber (Percent)
  
  if Fraction > 1 then Fraction = 1 end
  if Fraction < 0 then Fraction = 0 end
   
  local width = WindowTextWidth (win, font_id, sPrompt)
  
  WindowText (win, font_id, sPrompt,
                             GAUGE_LEFT - width, vertical, 0, 0, FONT_COLOUR)

  WindowRectOp (win, 2, GAUGE_LEFT + Margin, vertical, WINDOW_WIDTH - 5, vertical + GAUGE_HEIGHT, 
                          BACKGROUND_COLOUR)  -- fill entire box
 
  
  local gauge_width = (WINDOW_WIDTH - (GAUGE_LEFT + Margin) - 5) * Fraction
  
   -- box size must be > 0 or WindowGradient fills the whole thing 
  if math.floor (gauge_width) > 0 then
    
    -- top half
    WindowGradient (win, GAUGE_LEFT + Margin, vertical, GAUGE_LEFT + Margin + gauge_width, vertical + GAUGE_HEIGHT / 2, 
                    0x000000,
                    Colour, 2) 
    
    -- bottom half
    WindowGradient (win, GAUGE_LEFT + Margin, vertical + GAUGE_HEIGHT / 2, 
                    GAUGE_LEFT + Margin + gauge_width, vertical +  GAUGE_HEIGHT,   
                    Colour,
                    0x000000,
                    2) 

  end -- non-zero
  
  -- show ticks
  local ticks_at = (WINDOW_WIDTH - GAUGE_LEFT - 5) / (NUMBER_OF_TICKS + 1)
  
  -- ticks
  local N = math.floor((WINDOW_WIDTH - (GAUGE_LEFT + Margin) - 5)/ticks_at)
  for i = 1, N do
    WindowLine (win, WINDOW_WIDTH - 5 - (i * ticks_at), vertical, 
                WINDOW_WIDTH - 5 - (i * ticks_at), vertical + GAUGE_HEIGHT, ColourNameToRGB ("silver"), 0, 1)
  end -- for

  -- draw a box around it
  check (WindowRectOp (win, 1, GAUGE_LEFT + Margin, vertical, WINDOW_WIDTH - 5, vertical + GAUGE_HEIGHT, 
          ColourNameToRGB ("lightgrey")))  -- frame entire box
  
  vertical = vertical + font_height + 3
end -- function

function do_update ()
  -- fill entire box to clear it
  check (WindowRectOp (win, 2, 0, 0, 0, 0, BACKGROUND_COLOUR))  -- fill entire box
  
  -- Edge around box rectangle
  check (WindowCircleOp (win, 3, 0, 0, 0, 0, BORDER_COLOUR, 0, 2, 0, 1))

  vertical = 6  -- pixel to start at

  local total = 0
  local total_max = 1
  for _, stat in pairs(stat_names) do
    local gp, max_gp = tonumber (stats[stat]["current"]),
      tonumber (stats[stat]["max"])

    if (gp < 0) then
      gp = 0
    end
    if (max_gp <1) then
      max_gp = 1
    end
    local gp_percent = 0
    if stat == "Total" then
      gp_percent = gp / max_gp
      total = gp
      total_max = max_gp
    else
      gp_percent = (max_gp + total - total_max) / max_gp
    end

    local left_margin = ((total_max - max_gp)/total_max)*(WINDOW_WIDTH - GAUGE_LEFT-5)
    local short_desc = string.sub(stat, 1, 2)
    local gp_text = string.format(" (%03d/%03d) ", gp, max_gp)
    DoGauge (short_desc .. ":" .. gp_text,   gp_percent,    ColourNameToRGB (stat_colours[stat]), left_margin)
  end

  WindowShow (win, true)
  
end -- draw_bar

function statItem (name, current, max)
  stats[name]["current"] = tonumber (current)
  stats[name]["max"] = tonumber (max) 
  if name == "People" then
    do_update()
  end
end -- stat_item

function OnPluginInstall ()
  
  win = GetPluginID ()
  font_id = "fn"
  
  font_name = "Fixedsys"    -- the actual font

  local x, y, mode, flags = 
      tonumber (GetVariable ("windowx")) or 0,
      tonumber (GetVariable ("windowy")) or 0,
      tonumber (GetVariable ("windowmode")) or 8, -- bottom right
      tonumber (GetVariable ("windowflags")) or 0
    
  -- make miniwindow so I can grab the font info
  check (WindowCreate (win, 
                 x, y, WINDOW_WIDTH, WINDOW_HEIGHT,  
                 mode,   
                 flags,   
                 BACKGROUND_COLOUR) )

  -- make a hotspot
  WindowAddHotspot(win, "hs1",  
                   0, 0, 0, 0,   -- whole window
                   "",   -- MouseOver
                   "",   -- CancelMouseOver
                   "mousedown",
                   "",   -- CancelMouseDown
                   "",   -- MouseUp
                   "Drag to move",  -- tooltip text
                   1, 0)  -- hand cursor
                   
  WindowDragHandler(win, "hs1", "dragmove", "dragrelease", 0) 
                 
  check (WindowFont (win, font_id, font_name, 9, false, false, false, false, 0, 0))  -- normal
  
  font_height = WindowFontInfo (win, font_id, 1)  -- height
  
  if GetVariable ("enabled") == "false" then
    ColourNote ("yellow", "", "Warning: Plugin " .. GetPluginName ().. " is currently disabled.")
    check (EnablePlugin(GetPluginID (), false))
    return
  end -- they didn't enable us last time
  EnableTimer ("adventure_time_gp_timer", true) 
end -- OnPluginInstall

function OnPluginDisable ()
  EnableTimer ("adventure_time_gp_timer", false) 
  WindowShow (win, false)
end -- OnPluginDisable

function OnPluginEnable ()
  WindowShow (win, true)
  EnableTimer ("adventure_time_gp_timer", true) 
end -- OnPluginDisable

function OnPluginSaveState ()
  SetVariable ("enabled", tostring (GetPluginInfo (GetPluginID (), 17)))
  SetVariable ("windowx", tostring (WindowInfo (win, 10)))
  SetVariable ("windowy", tostring (WindowInfo (win, 11)))
  SetVariable ("windowmode", tostring (WindowInfo (win, 7)))
  SetVariable ("windowflags", tostring (WindowInfo (win, 8)))
end -- OnPluginSaveState


]]>
</script>

</muclient>
