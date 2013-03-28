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


local lgi    = require 'lgi'
local Adg    = lgi.require 'Adg'
local Piston = require 'piston'


-- Command line parsing
-----------------------------------------------------------------


local request = {}
for n, s in ipairs(arg) do
    -- Arguments are expected in k=v tuples
    local k, v = s:match('(.-)=(.*)')
    if not k then error('Invalid argument ' .. n) end
    request[k] = v
end

-- Provide fallback values
for k, v in pairs {
    A       = 55,
    B       = 20.6,
    C       = 2,
    DHOLE   = 2,
    LHOLE   = 3,
    D1      = 9.3,
    D2      = 6.5,
    D3      = 13.8,
    D4      = 6.5,
    D5      = 4.5,
    D6      = 7.2,
    D7      = 2,
    RD34    = 1,
    RD56    = 0.2,
    LD2     = 7,
    LD3     = 3.5,
    LD5     = 5,
    LD6     = 1,
    LD7     = 0.5,
    GROOVE  = false,
    ZGROOVE = 16,
    DGROOVE = 8.3,
    LGROOVE = 1,
    CHAMFER = 0.3,

    -- Metadata
    TITLE   = 'SAMPLE DRAWING',
    DRAWING = 'PISTON',
    AUTHOR  = 'adg-web',
    DATE    = os.date('%d/%m/%Y'),
} do
    if not request[k] then request[k] = v end
end


-- Part definition
-----------------------------------------------------------------

local piston = Piston.new(request)


-- Canvas settings
-----------------------------------------------------------------

local n = 1
local canvas = piston.view.detailed
canvas:set_size_explicit(800 - 20, 600 - 20)
canvas:set_top_margin(10)
canvas:set_bottom_margin(10)
canvas:set_left_margin(10)
canvas:set_right_margin(10)

piston:refresh()
canvas:autoscale()


-- File generation
-----------------------------------------------------------------

local _, err = canvas:export('/dev/stdout', 'png')
if err then error(err) end
