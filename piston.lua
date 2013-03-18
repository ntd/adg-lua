--[[

This file is part of adg-lua.
Copyright (C) 2012-2013  Nicola Fontana <ntd at entidi.it>

adg-lua is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

adg-lua is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General
Public License along with adg-lua; if not, write to the Free
Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301, USA.

]]

local lgi   = require 'lgi'
local cairo = lgi.require 'cairo'
local Cpml  = lgi.require 'Cpml'
local Adg   = lgi.require 'Adg'

local SQRT3 = math.sqrt(3)


-- Backward compatibility

if not cairo.Status.to_string then
    -- Pull request: http://github.com/pavouk/lgi/pull/44
    local core = require 'lgi.core'
    local ffi  = require 'lgi.ffi'
    local ti   = ffi.types

    cairo._enum.Status.to_string = core.callable.new {
	addr = cairo._module.cairo_status_to_string,
	ret = ti.utf8,
	ti.int
    }
end


-- MODEL
-----------------------------------------------------------------

local model = {}

function model.body(piston)
    local pair = Cpml.Pair {}
    local path = Adg.Path {}

    pair.x = 0
    pair.y = piston.D1 / 2
    path:move_to(pair)
    path:set_named_pair('D1I', pair)

    pair.x = piston.A - piston.B - piston.LD2
    path:line_to(pair)

    pair.y = piston.D3 / 2
    path:set_named_pair('D2_POS', pair)

    pair.x = pair.x + (piston.D1 - piston.D2) / 2
    pair.y = piston.D2 / 2
    path:line_to(pair)
    path:set_named_pair('D2I', pair)

    pair.x = piston.A - piston.B
    path:line_to(pair)
    path:fillet(0.4)

    pair.x = piston.A - piston.B
    pair.y = piston.D3 / 2
    path:line_to(pair)
    path:set_named_pair('D3I', pair)

    pair.x = piston.A
    path:set_named_pair('East', pair)

    pair.x = 0
    path:set_named_pair('West', pair)

    path:chamfer(0.3, 0.3)

    pair.x = piston.A - piston.B + piston.LD3
    pair.y = piston.D3 / 2
    path:line_to(pair)

    local primitive = path:over_primitive()
    local tmp = primitive:put_point(0)
    path:set_named_pair('D3I_X', tmp)

    tmp = primitive:put_point(-1)
    path:set_named_pair('D3I_Y', tmp)

    path:chamfer(0.3, 0.3)

    pair.y = piston.D4 / 2
    path:line_to(pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    path:set_named_pair('D3F_Y', tmp)
    tmp = primitive:put_point(-1)
    path:set_named_pair('D3F_X', tmp)

    path:fillet(piston.RD34)

    pair.x = pair.x + piston.RD34
    path:set_named_pair('D4I', pair)

    pair.x = piston.A - piston.C - piston.LD5
    path:line_to(pair)
    path:set_named_pair('D4F', pair)

    pair.y = piston.D3 / 2
    path:set_named_pair('D4_POS', pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    tmp.x = tmp.x + piston.RD34
    path:set_named_pair('RD34', tmp)

    tmp.x = tmp.x - math.cos(math.pi / 4) * piston.RD34
    tmp.y = tmp.y - math.sin(math.pi / 4) * piston.RD34
    path:set_named_pair('RD34_R', tmp)

    tmp.x = tmp.x + piston.RD34
    tmp.y = tmp.y + piston.RD34
    path:set_named_pair('RD34_XY', tmp)

    pair.x = pair.x + (piston.D4 - piston.D5) / 2
    pair.y = piston.D5 / 2
    path:line_to(pair)
    path:set_named_pair('D5I', pair)

    pair.x = piston.A - piston.C
    path:line_to(pair)

    path:fillet(0.2)

    pair.y = piston.D6 / 2
    path:line_to(pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    path:set_named_pair('D5F', tmp)

    path:fillet(0.1)

    pair.x = pair.x + piston.LD6
    path:line_to(pair)
    path:set_named_pair('D6F', pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    path:set_named_pair('D6I_X', tmp)

    primitive = path:over_primitive()
    tmp = primitive:put_point(-1)
    path:set_named_pair('D6I_Y', tmp)

    pair.x = piston.A - piston.LD7
    pair.y = pair.y - (piston.C - piston.LD7 - piston.LD6) / SQRT3
    path:line_to(pair)
    path:set_named_pair('D67', pair)

    pair.y = piston.D7 / 2
    path:line_to(pair)

    pair.x = piston.A
    path:line_to(pair)
    path:set_named_pair('D7F', pair)

    path:reflect_explicit(1, 0)
    path:close()

    return path
end

function model.edges(piston)
    return Adg.Edges { source = piston.model.body }
end

function model.hole(piston)
    local pair = Cpml.Pair {}
    local tmp = Cpml.Pair {}
    local path = Adg.Path {}

    pair.x = piston.LHOLE
    pair.y = 0
    path:move_to(pair)
    path:set_named_pair('LHOLE', pair)

    tmp.y = piston.DHOLE / 2
    tmp.x = pair.x - tmp.y / SQRT3
    path:line_to(tmp)

    pair.x = 0
    pair.y = tmp.y
    path:line_to(pair)
    path:set_named_pair('DHOLE', pair)

    path:line_to_explicit(0, (piston.D1 + piston.DHOLE) / 4)
    path:curve_to_explicit(piston.LHOLE / 2, piston.DHOLE / 2,
			   piston.LHOLE + 2, piston.D1 / 2,
			   piston.LHOLE + 2, 0)
    path:reflect_explicit(1, 0)
    path:close()

    path:move_to(tmp)
    tmp.y = -tmp.y
    path:line_to(tmp)

    return path
end

function model.dimensions(piston)
    local body = piston.model.body
    local hole = piston.model.hole
    local dims = {}
    local dim

    -- North

    dim = Adg.LDim.new_full_from_model(body, '-D3I_X', '-D3F_X', '-D3F_Y', -math.pi/2)
    dim:set_outside(Adg.ThreeState.OFF)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, '-D6I_X', '-D67', '-East', -math.pi/2)
    dim:set_level(0)
    dim:switch_extension1(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, '-D6I_X', '-D7F', '-East', -math.pi/2)
    dim:set_limits('-0.06', nil)
    table.insert(dims, dim)

    dim = Adg.ADim.new_full_from_model(body, '-D6I_Y', '-D6F', '-D6F', '-D67', '-D6F')
    dim:set_level(2)
    table.insert(dims, dim)

    dim = Adg.RDim.new_full_from_model(body, '-RD34', '-RD34_R', '-RD34_XY')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, '-DGROOVEI_X', '-DGROOVEF_X', '-DGROOVEX_POS', -math.pi/2)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D2I', '-D2I', '-D2_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'DGROOVEI_Y', '-DGROOVEI_Y', '-DGROOVEY_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    -- South

    dim = Adg.ADim.new_full_from_model(body, 'D1F', 'D1I', 'D2I', 'D1F', 'D1F')
    dim:set_level(2)
    dim:switch_extension2(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', nil, 'West', math.pi / 2)
    dim:set_ref2_from_model(hole, '-LHOLE')
    dim:switch_extension1(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', 'DGROOVEI_X', 'West', math.pi / 2)
    dim:switch_extension1(false)
    dim:set_level(2)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D4F', 'D6I_X', 'D4_POS', math.pi / 2)
    dim:set_limits(nil, '+0.2')
    dim:set_outside(Adg.ThreeState.OFF)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1F', 'D3I_X', 'D2_POS', math.pi / 2)
    dim:set_level(2)
    dim:switch_extension2(false)
    dim:set_outside(Adg.ThreeState.OFF)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D3I_X', 'D7F', 'East', math.pi / 2)
    dim:set_limits(nil, '+0.1')
    dim:set_level(2)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:switch_extension2(false)
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', 'D7F', 'D3F_Y', math.pi / 2)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(3)
    table.insert(dims, dim)

    dim = Adg.ADim.new_full_from_model(body, 'D4F', 'D4I', 'D5I', 'D4F', 'D4F')
    dim:set_level(1.5)
    dim:switch_extension2(false)
    table.insert(dims, dim)

    -- East

    dim = Adg.LDim.new_full_from_model(body, 'D6F', '-D6F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(4)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D4F', '-D4F', 'East', 0)
    dim:set_level(3)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D5F', '-D5F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(2)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D7F', '-D7F', 'East', 0)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    -- West

    dim = Adg.LDim.new_full_from_model(hole, 'DHOLE', '-DHOLE', nil, math.pi)
    dim:set_pos_from_model(body, '-West')
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', '-D1I', '-West', math.pi)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(2)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    dim = Adg.LDim.new_full_from_model(body, 'D3I_Y', '-D3I_Y', '-West', math.pi)
    dim:set_limits('-0.25', nil)
    dim:set_level(3)
    dim:set_value('\226\140\128 <>')
    table.insert(dims, dim)

    return dims
end


-- VIEW
-----------------------------------------------------------------

local view = {}

-- Inject the export method into Adg.Canvas
rawset(Adg.Canvas, 'export', function (canvas, file)
    -- The export format is guessed from the file suffix
    local suffix = file:match('%..*$')
    local size = canvas:get_size()
    size.x = size.x + canvas:get_left_margin() + canvas:get_right_margin()
    size.y = size.y + canvas:get_top_margin() + canvas:get_bottom_margin()

    -- Create the cairo surface
    local surface
    if suffix == '.png' and cairo.ImageSurface then
	surface = cairo.ImageSurface.create(cairo.Format.RGB24, size.x, size.y)
    elseif suffix == '.svg' and cairo.SvgSurface then
	surface = cairo.SvgSurface.create(file, size.x, size.y)
    elseif suffix == '.pdf' and cairo.PdfSurface then
	surface = cairo.PdfSurface.create(file, size.x, size.y)
    elseif suffix == '.ps' and cairo.PsSurface then
	-- Pull request: http://github.com/pavouk/lgi/pull/46
	surface = cairo.PsSurface.create(file, size.x, size.y)
	surface:dsc_comment('%%Title: adg-lua demonstration program')
	surface:dsc_comment('%%Copyright: Copyleft (C) 2013  Fontana Nicola')
	surface:dsc_comment('%%Orientation: Portrait')
	surface:dsc_begin_setup()
	surface:dsc_begin_page_setup()
	surface:dsc_comment('%%IncludeFeature: *PageSize A4')
    end
    if not surface then return nil, 'Requested format not supported' end

    -- Render the canvas content
    local cr = cairo.Context.create(surface);
    canvas:render(cr)
    local status

    if cairo.Surface.get_type(surface) == 'IMAGE' then
	status = cairo.Surface.write_to_png(surface, file)
    else
	cr:show_page()
	status = cr.status
    end

    if status ~= 'SUCCESS' then
	return nil, cairo.Status.to_string(cairo.Status[status])
    end
end)

function view.detailed(model)
    local canvas = Adg.Canvas {
	title_block = Adg.TitleBlock {
	    title = 'Detailed view',
	    author = 'adg-demo.lua',
	    date = os.date('%d/%m/%Y'),
	    drawing = '',
	    logo = Adg.Logo {},
	    projection = Adg.Projection { scheme = Adg.ProjectionScheme.FIRST_ANGLE },
	    scale = '---',
	    size = 'A4',
	},
    }

    canvas:add(Adg.Stroke { trail = model.body })
    canvas:add(Adg.Stroke { trail = model.edges })
    canvas:add(Adg.Hatch  { trail = model.hole })
    canvas:add(Adg.Stroke { trail = model.hole })
    for _, dim in pairs(model.dimensions) do canvas:add(dim) end

    return canvas
end


-- CONTROLLER
-----------------------------------------------------------------

local controller = {}

function controller.new(data)
    local part = data or {}

    part.model = {}
    setmetatable(part.model, {
	__index = function (self, key)
	    -- Check if the model name is valid
	    if not model[key] then return end

	    -- Create the model and store it into the cache
	    self[key] = model[key](part)

	    -- Return the cached result
	    return self[key]
	end
    })

    part.view = {}
    setmetatable(part.view, {
	__index = function (self, key)
	    -- Check if the view name is valid
	    if not view[key] then return end

	    -- Create the view and store it into the cache
	    self[key] = view[key](part.model)

	    -- Return the cached result
	    return self[key]
	end
    })

    return part
end


return controller
