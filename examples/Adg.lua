#! /usr/bin/env lua

-- ADG example.

require('lgob.adg')

pair = adg.Pair.new()
tmp = adg.Pair.new()
map = adg.Matrix.new()


---------------------------------------- PHYSICAL DATA

local part = {
    A    = 62.35,
    B    = 20.6,
    D1   = 9.3,
    D2   = 7.5,
    LD2  = 7,
    D3   = 12.4,
    LD3  = 3.5,
    RD34 = 1,
    D4   = 6.5,
    D5   = 4.5,
    LD5  = 4.5,
    D6   = 7.2,
    LD6  = 1,
    C    = 2,
    D7   = 2.5,
    LD7  = 0.5
}


---------------------------------------- DEFINING THE MODEL

-- path
local path = adg.Path.new()

pair.x = 0
pair.y = part.D1 / 2
path:move_to(pair)

pair.x = part.A - part.B - part.LD2
path:line_to(pair)

pair.y = part.D3 / 2
path:set_named_pair('D2_POS', pair)

pair.x = pair.x + (part.D1 - part.D2) / 2
pair.y = part.D2 / 2
path:line_to(pair)
path:set_named_pair('D2I', pair)

pair.x = part.A - part.B
path:line_to(pair)
path:fillet(0.4)

pair.x = part.A - part.B
pair.y = part.D3 / 2
path:line_to(pair)
path:set_named_pair('D3I', pair)

pair.x = part.A
path:set_named_pair('East', pair)

pair.x = 0
path:set_named_pair('West', pair)

path:chamfer(0.3, 0.3)

pair.x = part.A - part.B + part.LD3
pair.y = part.D3 / 2
path:line_to(pair)

primitive = path:over_primitive()
primitive:put_point(0, tmp)
path:set_named_pair('D3I_X', tmp)

primitive:put_point(-1, tmp)
path:set_named_pair('D3I_Y', tmp)

path:chamfer(0.3, 0.3)

pair.y = part.D4 / 2
path:line_to(pair)

primitive = path:over_primitive()
primitive:put_point(0, tmp)
path:set_named_pair('D3F_Y', tmp)
primitive:put_point(-1, tmp)
path:set_named_pair('D3F_X', tmp)

path:fillet(part.RD34)

pair.x = pair.x + part.RD34
path:set_named_pair('D4I', pair)

pair.x = part.A - part.C - part.LD5
path:line_to(pair)
path:set_named_pair('D4F', pair)

pair.y = part.D3 / 2
path:set_named_pair('D4_POS', pair)

primitive = path:over_primitive()
primitive:put_point(0, tmp)
tmp.x = tmp.x + part.RD34
path:set_named_pair('RD34', tmp)
tmp.x = pair.x
tmp.y = pair.y

tmp.x = tmp.x - math.cos(math.pi / 4) * part.RD34
tmp.y = tmp.y - math.sin(math.pi / 4) * part.RD34
path:set_named_pair('RD34_R', tmp)

tmp.x = tmp.x + part.RD34
tmp.y = tmp.y + part.RD34
path:set_named_pair('RD34_XY', tmp)

pair.x = pair.x + (part.D4 - part.D5) / 2
pair.y = part.D5 / 2
path:line_to(pair)
path:set_named_pair('D5I', pair)

pair.x = part.A - part.C
path:line_to(pair)

path:fillet(0.2)

pair.y = part.D6 / 2
path:line_to(pair)

primitive = path:over_primitive()
primitive:put_point(0, tmp)
path:set_named_pair('D5F', tmp)

path:fillet(0.1)

pair.x = pair.x + part.LD6
path:line_to(pair)
path:set_named_pair('D6F', pair)

primitive = path:over_primitive()
primitive:put_point(0, tmp)
path:set_named_pair('D6I_X', tmp)

primitive = path:over_primitive()
primitive:put_point(-1, tmp)
path:set_named_pair('D6I_Y', tmp)

pair.x = part.A - part.LD7
pair.y = pair.y - (part.C - part.LD7 - part.LD6) / 1.732
path:line_to(pair)
path:set_named_pair('D67', pair)

pair.y = part.D7 / 2
path:line_to(pair)

pair.x = part.A
path:line_to(pair)
path:set_named_pair('D7F', pair)

path:reflect_explicit(1, 0)
path:close()

-- edges
local edges = adg.Edges.new_with_source(path)


---------------------------------------- POPULATING THE CANVAS

local canvas = adg.Canvas.new()
canvas:set_paper('iso_a4', gtk.PAGE_ORIENTATION_LANDSCAPE)
canvas:add(adg.Stroke.new(path))
canvas:add(adg.Stroke.new(edges))

map.x0 = 140; map.y0 = 180
map.xx = 8; map.yy = 8
canvas:set_local_map(map)

local scrolled_window = gtk.ScrolledWindow.new()
scrolled_window:add(adg.GtkLayout.new_with_canvas(canvas))

---------------------------------------- THE RENDERING PROCESS

local window = gtk.Window.new(gtk.WINDOW_TOPLEVEL)
window:set_title('ADG demo')
window:set_window_position(gtk.WIN_POS_CENTER)
window:connect('delete-event', gtk.main_quit)

window:add(scrolled_window)
window:show_all()

gtk.main()
