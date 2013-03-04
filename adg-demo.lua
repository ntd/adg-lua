#! /usr/bin/env lua

local lgi = require 'lgi'
local cairo = lgi.require 'cairo'
local Gtk = lgi.require 'Gtk'
local Cpml = lgi.require 'Cpml'
local Adg = lgi.require 'Adg'

math.SQRT3 = math.sqrt(3)


-- DEFINING THE MODEL

local part = {
    A     = 55,
    B     = 20.6,
    D1    = 9.3,
    D2    = 7.5,
    LD2   = 7,
    D3    = 12.4,
    LD3   = 3.5,
    RD34  = 1,
    D4    = 6.5,
    D5    = 4.5,
    LD5   = 4.5,
    D6    = 7.2,
    LD6   = 1,
    C     = 2,
    D7    = 2.5,
    LD7   = 0.5,
    LHOLE = 12.5,
    DHOLE = 3,

    cache = {}
}

function part:model()
    if self.cache.model then return self.cache.model end

    local pair = Cpml.Pair {}
    local tmp = Cpml.Pair {}
    local path = Adg.Path {}

    pair.x = 0
    pair.y = self.D1 / 2
    path:move_to(pair)
    path:set_named_pair('D1I', pair)

    pair.x = self.A - self.B - self.LD2
    path:line_to(pair)

    pair.y = self.D3 / 2
    path:set_named_pair('D2_POS', pair)

    pair.x = pair.x + (self.D1 - self.D2) / 2
    pair.y = self.D2 / 2
    path:line_to(pair)
    path:set_named_pair('D2I', pair)

    pair.x = self.A - self.B
    path:line_to(pair)
    path:fillet(0.4)

    pair.x = self.A - self.B
    pair.y = self.D3 / 2
    path:line_to(pair)
    path:set_named_pair('D3I', pair)

    pair.x = self.A
    path:set_named_pair('East', pair)

    pair.x = 0
    path:set_named_pair('West', pair)

    path:chamfer(0.3, 0.3)

    pair.x = self.A - self.B + self.LD3
    pair.y = self.D3 / 2
    path:line_to(pair)

    local primitive = path:over_primitive()
    primitive:put_point(0, tmp)
    path:set_named_pair('D3I_X', tmp)

    primitive:put_point(-1, tmp)
    path:set_named_pair('D3I_Y', tmp)

    path:chamfer(0.3, 0.3)

    pair.y = self.D4 / 2
    path:line_to(pair)

    primitive = path:over_primitive()
    primitive:put_point(0, tmp)
    path:set_named_pair('D3F_Y', tmp)
    primitive:put_point(-1, tmp)
    path:set_named_pair('D3F_X', tmp)

    path:fillet(self.RD34)

    pair.x = pair.x + self.RD34
    path:set_named_pair('D4I', pair)

    pair.x = self.A - self.C - self.LD5
    path:line_to(pair)
    path:set_named_pair('D4F', pair)

    pair.y = self.D3 / 2
    path:set_named_pair('D4_POS', pair)

    primitive = path:over_primitive()
    primitive:put_point(0, tmp)
    tmp.x = tmp.x + self.RD34
    path:set_named_pair('RD34', tmp)

    tmp.x = tmp.x - math.cos(math.pi / 4) * self.RD34
    tmp.y = tmp.y - math.sin(math.pi / 4) * self.RD34
    path:set_named_pair('RD34_R', tmp)

    tmp.x = tmp.x + self.RD34
    tmp.y = tmp.y + self.RD34
    path:set_named_pair('RD34_XY', tmp)

    pair.x = pair.x + (self.D4 - self.D5) / 2
    pair.y = self.D5 / 2
    path:line_to(pair)
    path:set_named_pair('D5I', pair)

    pair.x = self.A - self.C
    path:line_to(pair)

    path:fillet(0.2)

    pair.y = self.D6 / 2
    path:line_to(pair)

    primitive = path:over_primitive()
    primitive:put_point(0, tmp)
    path:set_named_pair('D5F', tmp)

    path:fillet(0.1)

    pair.x = pair.x + self.LD6
    path:line_to(pair)
    path:set_named_pair('D6F', pair)

    primitive = path:over_primitive()
    primitive:put_point(0, tmp)
    path:set_named_pair('D6I_X', tmp)

    primitive = path:over_primitive()
    primitive:put_point(-1, tmp)
    path:set_named_pair('D6I_Y', tmp)

    pair.x = self.A - self.LD7
    pair.y = pair.y - (self.C - self.LD7 - self.LD6) / math.SQRT3
    path:line_to(pair)
    path:set_named_pair('D67', pair)

    pair.y = self.D7 / 2
    path:line_to(pair)

    pair.x = self.A
    path:line_to(pair)
    path:set_named_pair('D7F', pair)

    path:reflect_explicit(1, 0)
    path:close()

    self.cache.model = path
    return path
end

function part:edges()
    if self.cache.edges then return self.cache.edges end

    self.cache.edges = Adg.Edges { source = self:model() }
    return self.cache.edges
end

function part:hole()
    if self.cache.hole then return self.cache.hole end

    local pair = Cpml.Pair {}
    local tmp = Cpml.Pair {}
    local path = Adg.Path {}

    pair.x = self.LHOLE
    pair.y = 0
    path:move_to(pair)
    path:set_named_pair('LHOLE', pair)

    tmp.y = self.DHOLE / 2
    tmp.x = pair.x - tmp.y / math.SQRT3
    path:line_to(tmp)

    pair.x = 0
    pair.y = tmp.y
    path:line_to(pair)
    path:set_named_pair('DHOLE', pair)

    path:line_to_explicit(0, (self.D1 + self.DHOLE) / 4)
    path:curve_to_explicit(self.LHOLE / 2, self.DHOLE / 2, self.LHOLE + 2, self.D1 / 2, self.LHOLE + 2, 0)
    path:reflect_explicit(1, 0)
    path:close()

    path:move_to(tmp)
    tmp.y = -tmp.y
    path:line_to(tmp)

    self.cache.hole = path
    return self.cache.hole
end

function part:dimensions()
    if self.cache.dimensions then return self.cache.dimensions end

    local model = self:model()
    local hole = self:hole()
    local dims = {}
    local dim

    -- North

    dim = Adg.LDim.new_full_from_model(model, '-D3I_X', '-D3F_X', '-D3F_Y', -math.pi/2)
    dim:set_outside(Adg.ThreeState.OFF)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, '-D6I_X', '-D67', '-East', -math.pi/2)
    dim:set_level(0)
    dim:switch_extension1(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, '-D6I_X', '-D7F', '-East', -math.pi/2)
    dim:set_limits('-0.06', nil)
    table.insert(dims, dim)

    dim = Adg.ADim.new_full_from_model(model, '-D6I_Y', '-D6F', '-D6F', '-D67', '-D6F')
    dim:set_level(2)
    table.insert(dims, dim)

    dim = Adg.RDim.new_full_from_model(model, '-RD34', '-RD34_R', '-RD34_XY')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, '-DGROOVEI_X', '-DGROOVEF_X', '-DGROOVEX_POS', -math.pi/2)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D2I', '-D2I', '-D2_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'DGROOVEI_Y', '-DGROOVEI_Y', '-DGROOVEY_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    -- South

    dim = Adg.ADim.new_full_from_model(model, 'D1F', 'D1I', 'D2I', 'D1F', 'D1F')
    dim:set_level(2)
    dim:switch_extension2(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D1I', nil, 'West', math.pi / 2)
    dim:set_ref2_from_model(hole, '-LHOLE')
    dim:switch_extension1(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D1I', 'DGROOVEI_X', 'West', math.pi / 2)
    dim:switch_extension1(false)
    dim:set_level(2)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D4F', 'D6I_X', 'D4_POS', math.pi / 2)
    dim:set_limits(nil, '+0.2')
    dim:set_outside(Adg.ThreeState.OFF)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D1F', 'D3I_X', 'D2_POS', math.pi / 2)
    dim:set_level(2)
    dim:switch_extension2(false)
    dim:set_outside(Adg.ThreeState.OFF)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D3I_X', 'D7F', 'East', math.pi / 2)
    dim:set_limits(nil, '+0.1')
    dim:set_level(2)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:switch_extension2(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D1I', 'D7F', 'D3F_Y', math.pi / 2)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(3)
    table.insert(dims, dim)

    dim = Adg.ADim.new_full_from_model(model, 'D4F', 'D4I', 'D5I', 'D4F', 'D4F')
    dim:set_level(1.5)
    dim:switch_extension2(false)
    table.insert(dims, dim)

    -- East

    dim = Adg.LDim.new_full_from_model(model, 'D6F', '-D6F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(4)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D4F', '-D4F', 'East', 0)
    dim:set_level(3)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D5F', '-D5F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(2)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D7F', '-D7F', 'East', 0)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    -- West

    dim = Adg.LDim.new_full_from_model(hole, 'DHOLE', '-DHOLE', nil, math.pi)
    dim:set_pos_from_model(model, '-West')
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D1I', '-D1I', '-West', math.pi)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(2)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(model, 'D3I_Y', '-D3I_Y', '-West', math.pi)
    dim:set_limits('-0.25', nil)
    dim:set_level(3)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    self.cache.dimensions = dims
    return self.cache.dimensions
end


-- POPULATING THE CANVAS

local canvas = Adg.Canvas {
    title_block = Adg.TitleBlock {
	title = 'TITLE',
	author = 'AUTHOR',
	date = 'DATE',
	drawing = 'DRAWING',
	logo = Adg.Logo {},
	projection = Adg.Projection { scheme = Adg.ProjectionScheme.FIRST_ANGLE },
	scale = '---',
	size = 'A4',
    }
}

canvas:set_paper('iso_a4', Gtk.PageOrientation.LANDSCAPE)
canvas:add(Adg.Stroke { trail = part:model() })
canvas:add(Adg.Stroke { trail = part:edges() })
canvas:add(Adg.Hatch { trail = part:hole() })
canvas:add(Adg.Stroke { trail = part:hole() })

--for _, dim in pairs(part:dimensions()) do canvas:add(dim) end


-- THE RENDERING PROCESS

local window = Gtk.Window {
    type = Gtk.WindowType.TOPLEVEL,
    window_position = Gtk.WindowPosition.CENTER,
    child = Gtk.ScrolledWindow {
	child = Adg.GtkLayout { canvas = canvas },
    },
    on_delete_event = Gtk.main_quit,
}

canvas:autoscale()
window:show_all()
Gtk.main()

print((arg[0] or 'Program') .. ' terminated correctly')
