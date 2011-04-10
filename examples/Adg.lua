#! /usr/bin/env lua

-- ADG example.

require("lgob.adg")

pair = {}
tmp = {}


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
    LD7  = 0
}


---------------------------------------- DEFINING THE MODEL

-- path
local path = adg.Path.new()

pair.x = 0
pair.y = part.D1 / 2
path:move_to_explicit(pair.x, pair.y)

pair.x = part.A - part.B - part.LD2
path:line_to_explicit(pair.x, pair.y)

pair.y = part.D3 / 2
path:set_named_pair_explicit('D2_POS', pair.x, pair.y)

pair.x = pair.x + (part.D1 - part.D2) / 2
pair.y = part.D2 / 2
path:line_to_explicit(pair.x, pair.y)
path:set_named_pair_explicit('D2I', pair.x, pair.y)

pair.x = part.A - part.B
path:line_to_explicit(pair.x, pair.y)
path:fillet(0.4)

pair.x = part.A - part.B
pair.y = part.D3 / 2
path:line_to_explicit(pair.x, pair.y)
path:set_named_pair_explicit('D3I', pair.x, pair.y)

pair.x = part.A
path:set_named_pair_explicit('East', pair.x, pair.y)

pair.x = 0
path:set_named_pair_explicit('West', pair.x, pair.y)

path:chamfer(0.3, 0.3)

pair.x = part.A - part.B + part.LD3
pair.y = part.D3 / 2
path:line_to_explicit(pair.x, pair.y)

--primitive = adg_path_over_primitive(path)
--cpml_primitive_put_point(primitive, 0, tmp)
--path:set_named_pair("D3I_X", tmp)

--cpml_primitive_put_point(primitive, -1, tmp)
--path:set_named_pair("D3I_Y", tmp)

path:chamfer(0.3, 0.3)

pair.y = part.D4 / 2
path:line_to_explicit(pair.x, pair.y)

--primitive = adg_path_over_primitive(path)
--cpml_primitive_put_point(primitive, 0, tmp)
--path:set_named_pair("D3F_Y", tmp)
--cpml_primitive_put_point(primitive, -1, tmp)
--path:set_named_pair("D3F_X", tmp)

path:fillet(part.RD34)

pair.x = pair.x + part.RD34
path:set_named_pair_explicit('D4I', pair.x, pair.y)

pair.x = part.A - part.C - part.LD5
path:line_to_explicit(pair.x, pair.y)
path:set_named_pair_explicit('D4F', pair.x, pair.y)

pair.y = part.D3 / 2
path:set_named_pair_explicit('D4_POS', pair.x, pair.y)

--primitive = adg_path_over_primitive(path)
--cpml_primitive_put_point(primitive, 0, tmp)
--tmp.x = tmp.x + part.RD34
--path:set_named_pair("RD34", tmp)
tmp.x = pair.x
tmp.y = pair.y

tmp.x = tmp.x - math.cos(math.pi / 4) * part.RD34
tmp.y = tmp.y - math.sin(math.pi / 4) * part.RD34
path:set_named_pair_explicit('RD34_R', tmp.x, tmp.y)

tmp.x = tmp.x + part.RD34
tmp.y = tmp.y + part.RD34
path:set_named_pair_explicit('RD34_XY', tmp.x, tmp.y)

pair.x = pair.x + (part.D4 - part.D5) / 2
pair.y = part.D5 / 2
path:line_to_explicit(pair.x, pair.y)
path:set_named_pair_explicit('D5I', pair.x, pair.y)

pair.x = part.A - part.C
path:line_to_explicit(pair.x, pair.y)

path:fillet(0.2)

pair.y = part.D6 / 2
path:line_to_explicit(pair.x, pair.y)

--primitive = adg_path_over_primitive(path)
--cpml_primitive_put_point(primitive, 0, tmp)
--path:set_named_pair_explicit('D5F', tmp.x, tmp.y)

path:fillet(0.1)

pair.x = pair.x + part.LD6
path:line_to_explicit(pair.x, pair.y)
path:set_named_pair_explicit('D6F', pair.x, pair.y)

--primitive = adg_path_over_primitive(path)
--cpml_primitive_put_point(primitive, 0, tmp)
--path:set_named_pair("D6I_X", tmp)

--primitive = adg_path_over_primitive(path)
--cpml_primitive_put_point(primitive, -1, tmp)
--path:set_named_pair("D6I_Y", tmp)

pair.x = part.A - part.LD7
pair.y = pair.y - (part.C - part.LD7 - part.LD6) / 1.732
path:line_to_explicit(pair.x, pair.y)
path:set_named_pair_explicit('D67', pair.x, pair.y)

pair.y = part.D7 / 2
path:line_to_explicit(pair.x, pair.y)

pair.x = part.A
path:line_to_explicit(pair.x, pair.y)
path:set_named_pair_explicit('D7F', pair.x, pair.y)

path:reflect_explicit(1, 0)
path:close()

-- edges
local edges = adg.Edges.new_with_source(path)


---------------------------------------- POPULATING THE CANVAS

local canvas = adg.Canvas.new()
canvas:set_paper('iso_a4', gtk.PAGE_ORIENTATION_LANDSCAPE)
canvas:add(adg.Stroke.new(path))
canvas:add(adg.Stroke.new(edges))

--cairo_matrix_init_translate(&map, 140, 180);
--cairo_matrix_scale(&map, 8, 8);
--canvas:set_local_map(map);

local scrolled_window = gtk.ScrolledWindow.new()
scrolled_window:add(adg.GtkLayout.new_with_canvas(canvas))

---------------------------------------- THE RENDERING PROCESS

local window = gtk.Window.new(gtk.WINDOW_TOPLEVEL)
window:set("title", "ADG demo", "window-position", gtk.WIN_POS_CENTER)
window:connect("delete-event", gtk.main_quit) 

window:add(scrolled_window)
window:show_all()

gtk.main()
