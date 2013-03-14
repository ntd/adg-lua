--[[

This file is part of adg-lua.

adg-lua is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

adg-lua is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with adg-lua.  If not, see <http://www.gnu.org/licenses/>.

]]

local lgi    = require 'lgi'
local Gtk    = lgi.require 'Gtk'
local Adg    = lgi.require 'Adg'
local Piston = require 'piston'

local piston = Piston.new {
    A       = 55,
    B       = 20.6,
    C       = 2,
    D1      = 9.3,
    D2      = 6.5,
    LD2     = 7,
    D3      = 13.8,
    LD3     = 3.5,
    RD34    = 1,
    D4      = 6.5,
    D5      = 4.5,
    LD5     = 5,
    D6      = 7.2,
    LD6     = 1,
    RD6     = 25,
    D7      = 2,
    LD7     = 0.5,
    DHOLE   = 2,
    LHOLE   = 3,
    DGROOVE = 8.3,
    LGROOVE = 1,
    ZGROOVE = 16,
}

local canvas = piston.view.detailed
canvas:set_paper('iso_a4', Gtk.PageOrientation.LANDSCAPE)

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
