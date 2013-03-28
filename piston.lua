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
local generator = {}


-- Backward compatibility

if not cairo.Status.to_string then
    -- Pull request: http://github.com/pavouk/lgi/pull/44
    local core = require 'lgi.core'
    local ffi  = require 'lgi.ffi'
    local ti   = ffi.types

    cairo._enum.Status.to_string = core.callable.new {
	addr = cairo._module.cairo_status_to_string,
	ret = ti.utf8,
	cairo.Status
    }
end


-- MODEL
-----------------------------------------------------------------

generator.model = {}
local constructor = {}

-- Inject the regenerate method into Adg.Model
--
-- Rebuilding the model *without* destroying it is the quickest method
-- to change a drawing: the notification mechanism will change only the
-- entities that effectively need to be modified.
--
-- Another (easier) option would be to regenerate everything - that is
-- models and views - from scratch.
rawset(Adg.Model, 'regenerate', function (model, part)
    -- Call the original constructor of model, registered during the first call
    -- to the same constructor, to regenerate it with the data stored in part.
    constructor[model](part, model)
end)

function generator.model.hole(part, path)
    path = path or Adg.Path {}
    constructor[path] = generator.model.hole

    local data = part.data

    local pair = Cpml.Pair { x = data.LHOLE, y = 0 }
    path:move_to(pair)
    path:set_named_pair('LHOLE', pair)

    pair.y = data.DHOLE / 2
    pair.x = pair.x - pair.y / SQRT3
    path:line_to(pair)
    local edge = pair:dup()

    pair.x = 0
    path:line_to(pair)
    path:set_named_pair('DHOLE', pair)

    path:line_to_explicit(0, (data.D1 + data.DHOLE) / 4)
    path:curve_to_explicit(data.LHOLE / 2, data.DHOLE / 2,
			   data.LHOLE + 2, data.D1 / 2,
			   data.LHOLE + 2, 0)
    path:reflect()
    path:close()

    -- No need to incomodate an AdgEdge model for two reasons:
    -- it is only a single line and it is always needed
    path:move_to(edge)
    edge.y = -edge.y
    path:line_to(edge)

    return path
end

local function add_groove(path, part)
    local data = part.data
    local pair = Cpml.Pair { x = data.ZGROOVE, y = data.D1 / 2 }

    path:line_to(pair)
    path:set_named_pair('DGROOVEI_X', pair)

    pair.y = data.D3 / 2
    path:set_named_pair('DGROOVEY_POS', pair)

    pair.y = data.DGROOVE / 2
    path:line_to(pair)
    path:set_named_pair('DGROOVEI_Y', pair)

    pair.x = pair.x + data.LGROOVE
    path:line_to(pair)

    pair.y = data.D3 / 2
    path:set_named_pair('DGROOVEX_POS', pair)

    pair.y = data.D1 / 2
    path:line_to(pair)
    path:set_named_pair('DGROOVEF_X', pair)
end

function generator.model.body(part, path)
    path = path or Adg.Path {}
    constructor[path] = generator.model.body

    local data = part.data

    local pair = Cpml.Pair { x = 0, y = data.D1 / 2 }
    path:move_to(pair)
    path:set_named_pair('D1I', pair)

    if data.GROOVE then add_groove(path, part) end

    pair.x = data.A - data.B - data.LD2
    path:line_to(pair)

    pair.y = data.D3 / 2
    path:set_named_pair('D2_POS', pair)

    pair.x = pair.x + (data.D1 - data.D2) / 2
    pair.y = data.D2 / 2
    path:line_to(pair)
    path:set_named_pair('D2I', pair)

    pair.x = data.A - data.B
    path:line_to(pair)
    path:fillet(0.4)

    pair.x = data.A - data.B
    pair.y = data.D3 / 2
    path:line_to(pair)
    path:set_named_pair('D3I', pair)

    pair.x = data.A
    path:set_named_pair('East', pair)

    pair.x = 0
    path:set_named_pair('West', pair)

    path:chamfer(data.CHAMFER, data.CHAMFER)

    pair.x = data.A - data.B + data.LD3
    pair.y = data.D3 / 2
    path:line_to(pair)

    local primitive = path:over_primitive()
    local tmp = primitive:put_point(0)
    path:set_named_pair('D3I_X', tmp)

    tmp = primitive:put_point(-1)
    path:set_named_pair('D3I_Y', tmp)

    path:chamfer(data.CHAMFER, data.CHAMFER)

    pair.y = data.D4 / 2
    path:line_to(pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    path:set_named_pair('D3F_Y', tmp)
    tmp = primitive:put_point(-1)
    path:set_named_pair('D3F_X', tmp)

    path:fillet(data.RD34)

    pair.x = pair.x + data.RD34
    path:set_named_pair('D4I', pair)

    pair.x = data.A - data.C - data.LD5
    path:line_to(pair)
    path:set_named_pair('D4F', pair)

    pair.y = data.D3 / 2
    path:set_named_pair('D4_POS', pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    tmp.x = tmp.x + data.RD34
    path:set_named_pair('RD34', tmp)

    tmp.x = tmp.x - math.cos(math.pi / 4) * data.RD34
    tmp.y = tmp.y - math.sin(math.pi / 4) * data.RD34
    path:set_named_pair('RD34_R', tmp)

    tmp.x = tmp.x + data.RD34
    tmp.y = tmp.y + data.RD34
    path:set_named_pair('RD34_XY', tmp)

    pair.x = pair.x + (data.D4 - data.D5) / 2
    pair.y = data.D5 / 2
    path:line_to(pair)
    path:set_named_pair('D5I', pair)

    pair.x = data.A - data.C
    path:line_to(pair)

    path:fillet(0.2)

    pair.y = data.D6 / 2
    path:line_to(pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    path:set_named_pair('D5F', tmp)

    path:fillet(0.1)

    pair.x = pair.x + data.LD6
    path:line_to(pair)
    path:set_named_pair('D6F', pair)

    primitive = path:over_primitive()
    tmp = primitive:put_point(0)
    path:set_named_pair('D6I_X', tmp)

    primitive = path:over_primitive()
    tmp = primitive:put_point(-1)
    path:set_named_pair('D6I_Y', tmp)

    pair.x = data.A - data.LD7
    pair.y = pair.y - (data.C - data.LD7 - data.LD6) / SQRT3
    path:line_to(pair)
    path:set_named_pair('D67', pair)

    pair.y = data.D7 / 2
    path:line_to(pair)

    pair.x = data.A
    path:line_to(pair)
    path:set_named_pair('D7F', pair)

    path:reflect_explicit(1, 0)
    path:close()

    return path
end

function generator.model.edges(part, edges)
    edges = edges or Adg.Edges {}
    constructor[edges] = generator.model.edges

    edges:set_source(part.model.body)

    return edges
end

function generator.model.axis(part, path)
    --[[
	XXX: actually the end points can extend outside the body
	only in local space. The proper extension values should be
	expressed in global space but actually is impossible to
	combine local and global space in the AdgPath API.
    --]]
    path = path or Adg.Path {}
    constructor[path] = generator.model.axis

    local data = part.data

    path:move_to_explicit(-1, 0)
    path:line_to_explicit(data.A + 1, 0)

    return path
end


-- VIEW
-----------------------------------------------------------------

generator.view = {}

-- Inject the export method into Adg.Canvas
rawset(Adg.Canvas, 'export', function (canvas, file, format)
    -- The not explicitely set, the export format is guessed from the file suffix
    if not format then format = file:match('%.(.*)$') end

    local size = canvas:get_size()
    size.x = size.x + canvas:get_left_margin() + canvas:get_right_margin()
    size.y = size.y + canvas:get_top_margin() + canvas:get_bottom_margin()

    -- Create the cairo surface
    local surface
    if format == 'png' and cairo.ImageSurface then
	surface = cairo.ImageSurface.create(cairo.Format.RGB24, size.x, size.y)
    elseif format == 'svg' and cairo.SvgSurface then
	surface = cairo.SvgSurface.create(file, size.x, size.y)
    elseif format == 'pdf' and cairo.PdfSurface then
	surface = cairo.PdfSurface.create(file, size.x, size.y)
    elseif format == 'ps' and cairo.PsSurface then
	-- Pull request: http://github.com/pavouk/lgi/pull/46
	surface = cairo.PsSurface.create(file, size.x, size.y)
	surface:dsc_comment('%%Title: adg-lua demonstration program')
	surface:dsc_comment('%%Copyright: Copyleft (C) 2013  Fontana Nicola')
	surface:dsc_comment('%%Orientation: Portrait')
	surface:dsc_begin_setup()
	surface:dsc_begin_page_setup()
	surface:dsc_comment('%%IncludeFeature: *PageSize A4')
    elseif not format then
	format = '<nil>'
    end
    if not surface then
	return nil, 'Requested format not supported (' .. format .. ')'
    end

    -- Render the canvas content
    local cr = cairo.Context.create(surface)
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

local function add_title_block(canvas)
    canvas:set_title_block(Adg.TitleBlock {
	title      = '',
	author     = '',
	date       = '',
	drawing    = '',
	logo       = Adg.Logo {},
	projection = Adg.Projection { scheme = Adg.ProjectionScheme.FIRST_ANGLE },
	size       = 'A4',
    })
end

local function add_dimensions(canvas, model)
    local body = model.body
    local hole = model.hole
    local dim


    -- North

    dim = Adg.LDim.new_full_from_model(body, '-D3I_X', '-D3F_X', '-D3F_Y', -math.pi/2)
    dim:set_outside(Adg.ThreeState.OFF)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, '-D6I_X', '-D67', '-East', -math.pi/2)
    dim:set_level(0)
    dim:switch_extension1(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, '-D6I_X', '-D7F', '-East', -math.pi/2)
    dim:set_limits('-0.06', nil)
    canvas:add(dim)

    dim = Adg.ADim.new_full_from_model(body, '-D6I_Y', '-D6F', '-D6F', '-D67', '-D6F')
    dim:set_level(2)
    canvas:add(dim)

    dim = Adg.RDim.new_full_from_model(body, '-RD34', '-RD34_R', '-RD34_XY')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, '-DGROOVEI_X', '-DGROOVEF_X', '-DGROOVEX_POS', -math.pi/2)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D2I', '-D2I', '-D2_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'DGROOVEI_Y', '-DGROOVEI_Y', '-DGROOVEY_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)


    -- South

    dim = Adg.ADim.new_full_from_model(body, 'D1F', 'D1I', 'D2I', 'D1F', 'D1F')
    dim:set_level(2)
    dim:switch_extension2(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', nil, 'West', math.pi / 2)
    dim:set_ref2_from_model(hole, '-LHOLE')
    dim:switch_extension1(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', 'DGROOVEI_X', 'West', math.pi / 2)
    dim:switch_extension1(false)
    dim:set_level(2)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D4F', 'D6I_X', 'D4_POS', math.pi / 2)
    dim:set_limits(nil, '+0.2')
    dim:set_outside(Adg.ThreeState.OFF)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1F', 'D3I_X', 'D2_POS', math.pi / 2)
    dim:set_level(2)
    dim:switch_extension2(false)
    dim:set_outside(Adg.ThreeState.OFF)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D3I_X', 'D7F', 'East', math.pi / 2)
    dim:set_limits(nil, '+0.1')
    dim:set_level(2)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:switch_extension2(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', 'D7F', 'D3F_Y', math.pi / 2)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(3)
    canvas:add(dim)

    dim = Adg.ADim.new_full_from_model(body, 'D4F', 'D4I', 'D5I', 'D4F', 'D4F')
    dim:set_level(1.5)
    dim:switch_extension2(false)
    canvas:add(dim)


    -- East

    dim = Adg.LDim.new_full_from_model(body, 'D6F', '-D6F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(4)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D4F', '-D4F', 'East', 0)
    dim:set_level(3)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D5F', '-D5F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(2)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D7F', '-D7F', 'East', 0)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)


    -- West

    dim = Adg.LDim.new_full_from_model(hole, 'DHOLE', '-DHOLE', nil, math.pi)
    dim:set_pos_from_model(body, '-West')
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', '-D1I', '-West', math.pi)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(2)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D3I_Y', '-D3I_Y', '-West', math.pi)
    dim:set_limits('-0.25', nil)
    dim:set_level(3)
    dim:set_value('\226\140\128 <>')
    canvas:add(dim)
end

function generator.view.detailed(part)
    local canvas = Adg.Canvas {}
    local model = part.model

    add_title_block(canvas)
    canvas:add(Adg.Stroke { trail = model.body })
    canvas:add(Adg.Stroke { trail = model.edges })
    canvas:add(Adg.Hatch  { trail = model.hole })
    canvas:add(Adg.Stroke { trail = model.hole })
    canvas:add(Adg.Stroke {
	trail = model.axis,
	line_dress = Adg.Dress.LINE_AXIS
    })
    add_dimensions(canvas, model)

    return canvas
end


-- CONTROLLER
-----------------------------------------------------------------

local controller = {}

function controller.new(data)
    local part = {}

    local function generate(class, method)
	local constructor = generator[class][method]
	local result = constructor and constructor(part) or false
	part[class][method] = result
	return result
    end

    -- data: numbers and strings needed to define the whole part
    part.data = data or {}

    -- model: different models (AdgModel instances) generated from data
    part.model = {}
    setmetatable(part.model, {
	__index = function (self, key)
	    return generate('model', key)
	end
    })

    -- view: drawings (AdgCanvas) availables for a single set of data
    part.view = {}
    setmetatable(part.view, {
	__index = function (self, key)
	    return generate('view', key)
	end
    })

    return part
end


return controller
