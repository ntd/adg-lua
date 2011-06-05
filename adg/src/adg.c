/*
 * This file needs lgob although it is not officialy part of it.
 *
 * lgob is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * lgob is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with lgob.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (C) 2011  Nicola Fontana
 */

#include <lua.h>
#include <lauxlib.h>
#include <string.h>

#include <adg.h>
#include <glib-object.h>
#include <lgob/common/types.h>


static const struct luaL_reg _global[];
static const struct luaL_reg adg[] = {
    { NULL, NULL }
};


static void
copy_interface(lua_State *L, const char *iface,
               const char *target, const luaL_Reg *fnames)
{
    lua_getfield(L, -1, iface);
    lua_getfield(L, -2, target);

    while (fnames->name) {
        lua_getfield(L, -2, fnames->name);
        lua_setfield(L, -2, fnames->name);
        ++ fnames;
    }

    lua_pop(L, 2);
}

static void
object_new(lua_State* L, gpointer ptr, gboolean constructor)
{
    lua_pushliteral(L, "lgobObjectNew");
    lua_rawget(L, LUA_REGISTRYINDEX);
    lua_pushlightuserdata(L, ptr);
    lua_pushboolean(L, constructor); 
    lua_call(L, 2, 1);
}

static void
register_class(lua_State *L, const char *name,
               const char *base, const luaL_Reg *reg)
{
    lua_pushstring(L, name);
    lua_newtable(L);
    luaL_register(L, NULL, reg);

    if (base) {
        lua_newtable(L);
        lua_pushliteral(L, "__index");
        lua_pushstring(L, base);
        lua_rawget(L, -6);
        lua_rawset(L, -3);
        lua_setmetatable(L, -2);
    }

    lua_rawset(L, -3); 
}

static void
special_type_new(lua_State *L, const gchar *mt, gpointer ptr)
{
    Object *object;

    if (ptr == NULL) {
        lua_pushnil(L);
        return;
    }

    object = lua_newuserdata(L, sizeof(Object));
    object->pointer = ptr;
    object->need_unref = TRUE;
    lua_getfield(L, LUA_REGISTRYINDEX, mt);
    lua_setmetatable(L, -2);
}

static int
special_gc(lua_State *L)
{
    Object *object = (Object *) lua_touserdata(L, 1);

    if (object != NULL) {
        g_free(object->pointer);
        object->pointer = NULL;
    }

    return 0;
}

static gpointer
l_checkspecial(lua_State *L, int n)
{
    Object *object = (Object *) lua_touserdata(L, n);
    gpointer pointer = NULL;

    if (object != NULL)
        pointer = object->pointer;

    if (pointer == NULL)
        luaL_typerror(L, n, "special type");

    return pointer;
}


/**
 * l_checkpairfield:
 * @L: lua state
 * @n: index in the stack of the AdgPair
 *
 * Given an AdgPair special object at index n and a key at index n+1,
 * returns a pointer to the requested field on the provided instance.
 * An exception is raised on errors or if the field name is invalid.
 *
 * Returns: a pointer to the field on the AdgPair instance.
 **/
static gdouble *
l_checkpairfield(lua_State *L, int n)
{
    AdgPair *pair = (AdgPair *) l_checkspecial(L, n);
    const gchar *key = luaL_checkstring(L, n + 1);

    if (strcmp(key, "x") == 0) {
        return & pair->x;
    } else if (strcmp(key, "y") == 0) {
        return & pair->y;
    }

    luaL_argerror(L, n + 1, "field not found");
    return NULL;
}

static int
l_pair_index(lua_State *L)
{
    gdouble *value = l_checkpairfield(L, 1);
    lua_pushnumber(L, *value);
    return 1;
}

static int
l_pair_newindex(lua_State *L)
{
    gdouble *value = l_checkpairfield(L, 1);
    *value = lua_tonumber(L, 3);
    return 0;
}

static int
l_pair_tostring(lua_State *L)
{
    AdgPair *pair = (AdgPair *) l_checkspecial(L, 1);
    lua_pushfstring(L, "(%f, %f)", pair->x, pair->y);
    return 1;
}


static void
_wrap_adg_init(lua_State *L)
{
    luaL_register(L, "adg", adg);
    luaL_register(L, NULL, _global);

    luaL_loadstring(L, "require('lgob.cpml')");
    lua_call(L, 0, 0);
    luaL_loadstring(L, "require('lgob.gtk')");
    lua_call(L, 0, 0);

    lua_getfield(L, LUA_REGISTRYINDEX, "lgobPrefix");
    lua_pushliteral(L, "Adg");
    lua_pushliteral(L, "adg");
    lua_rawset(L, -3);
    lua_pop(L, 1);

    luaL_loadstring(L, "glib.handle_log('Adg')");
    lua_call(L, 0, 0);
}

static void
_wrap_adg_ret(lua_State *L)
{
    static const luaL_reg meta_methods[] = {
        { "__index",    l_pair_index },
        { "__newindex", l_pair_newindex },
        { "__tostring", l_pair_tostring },
        { "__gc",       special_gc },
        { NULL, NULL }
    };

    /* Register additional meta methods */
    luaL_getmetatable(L, "adgPairMT");
    luaL_register(L, NULL, meta_methods);
    lua_pop(L, 1);
}
