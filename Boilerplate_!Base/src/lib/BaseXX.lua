--------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : BaseXX ����ģ��
-- @copyright: Copyright (c) 2009 Kingsoft Co., Ltd.
--------------------------------------------------------
-- Base64-encoding
-- Sourced from https://github.com/aiq/basexx/blob/master/lib/basexx.lua
-------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall, select = ipairs, pairs, next, pcall, select
local byte, char, len, find, format = string.byte, string.char, string.len, string.find, string.format
local gmatch, gsub, dump, reverse = string.gmatch, string.gsub, string.dump, string.reverse
local match, rep, sub, upper, lower = string.match, string.rep, string.sub, string.upper, string.lower
local type, tonumber, tostring = type, tonumber, tostring
local HUGE, PI, random, randomseed = math.huge, math.pi, math.random, math.randomseed
local min, max, floor, ceil, abs = math.min, math.max, math.floor, math.ceil, math.abs
local mod, modf, pow, sqrt = math['mod'] or math['fmod'], math.modf, math.pow, math.sqrt
local sin, cos, tan, atan, atan2 = math.sin, math.cos, math.tan, math.atan, math.atan2
local insert, remove, concat = table.insert, table.remove, table.concat
local pack, unpack = table['pack'] or function(...) return {...} end, table['unpack'] or unpack
local sort, getn = table.sort, table['getn'] or function(t) return #t end
local iif = function(expr, truepart, falsepart) if expr then return truepart end return falsepart end
-- jx3 apis caching
local wlen, wfind, wgsub, wlower = wstring.len, StringFindW, StringReplaceW, StringLowerW
local GetTime, GetLogicFrameCount, GetCurrentTime = GetTime, GetLogicFrameCount, GetCurrentTime
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
-- lib apis caching
local LIB = Boilerplate
local UI, GLOBAL, CONSTANT = LIB.UI, LIB.GLOBAL, LIB.CONSTANT
local PACKET_INFO, DEBUG_LEVEL, PATH_TYPE = LIB.PACKET_INFO, LIB.DEBUG_LEVEL, LIB.PATH_TYPE
local wsub, count_c, lodash = LIB.wsub, LIB.count_c, LIB.lodash
local pairs_c, ipairs_c, ipairs_r = LIB.pairs_c, LIB.ipairs_c, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local IsNil, IsEmpty, IsEquals, IsString = LIB.IsNil, LIB.IsEmpty, LIB.IsEquals, LIB.IsString
local IsBoolean, IsNumber, IsHugeNumber = LIB.IsBoolean, LIB.IsNumber, LIB.IsHugeNumber
local IsTable, IsArray, IsDictionary = LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsFunction, IsUserdata, IsElement = LIB.IsFunction, LIB.IsUserdata, LIB.IsElement
local EncodeLUAData, DecodeLUAData, Schema = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.Schema
local GetTraceback, RandomChild, GetGameAPI = LIB.GetTraceback, LIB.RandomChild, LIB.GetGameAPI
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local Call, XpCall, SafeCall, NSFormatString = LIB.Call, LIB.XpCall, LIB.SafeCall, LIB.NSFormatString
-------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- util functions
--------------------------------------------------------------------------------

local function divide_string( str, max )
   local result = {}

   local start = 1
   for i = 1, #str do
      if i % max == 0 then
         table.insert( result, str:sub( start, i ) )
         start = i + 1
      elseif i == #str then
         table.insert( result, str:sub( start, i ) )
      end
   end

   return result
end

local function number_to_bit( num, length )
   local bits = {}

   while num > 0 do
      local rest = math.floor( math.fmod( num, 2 ) )
      table.insert( bits, rest )
      num = ( num - rest ) / 2
   end

   while #bits < length do
      table.insert( bits, "0" )
   end

   return string.reverse( table.concat( bits ) )
end

local function ignore_set( str, set )
   if set then
      str = str:gsub( "["..set.."]", "" )
   end
   return str
end

local function pure_from_bit( str )
   return ( str:gsub( '........', function ( cc )
               return string.char( tonumber( cc, 2 ) )
            end ) )
end

local function unexpected_char_error( str, pos )
   local c = string.sub( str, pos, pos )
   return string.format( "unexpected character at position %d: '%s'", pos, c )
end

--------------------------------------------------------------------------------

local basexx = {}

--------------------------------------------------------------------------------
-- base2(bitfield) decode and encode function
--------------------------------------------------------------------------------

local bitMap = { o = "0", i = "1", l = "1" }

function basexx.from_bit( str, ignore )
   str = ignore_set( str, ignore )
   str = string.lower( str )
   str = str:gsub( '[ilo]', function( c ) return bitMap[ c ] end )
   local pos = string.find( str, "[^01]" )
   if pos then return nil, unexpected_char_error( str, pos ) end

   return pure_from_bit( str )
end

function basexx.to_bit( str )
   return ( str:gsub( '.', function ( c )
               local byte = string.byte( c )
               local bits = {}
               for _ = 1,8 do
                  table.insert( bits, byte % 2 )
                  byte = math.floor( byte / 2 )
               end
               return table.concat( bits ):reverse()
            end ) )
end

--------------------------------------------------------------------------------
-- base16(hex) decode and encode function
--------------------------------------------------------------------------------

function basexx.from_hex( str, ignore )
   str = ignore_set( str, ignore )
   local pos = string.find( str, "[^%x]" )
   if pos then return nil, unexpected_char_error( str, pos ) end

   return ( str:gsub( '..', function ( cc )
               return string.char( tonumber( cc, 16 ) )
            end ) )
end

function basexx.to_hex( str )
   return ( str:gsub( '.', function ( c )
               return string.format('%02X', string.byte( c ) )
            end ) )
end

--------------------------------------------------------------------------------
-- generic function to decode and encode base32/base64
--------------------------------------------------------------------------------

local function from_basexx( str, alphabet, bits )
   local result = {}
   for i = 1, #str do
      local c = string.sub( str, i, i )
      if c ~= '=' then
         local index = string.find( alphabet, c, 1, true )
         if not index then
            return nil, unexpected_char_error( str, i )
         end
         table.insert( result, number_to_bit( index - 1, bits ) )
      end
   end

   local value = table.concat( result )
   local pad = #value % 8
   return pure_from_bit( string.sub( value, 1, #value - pad ) )
end

local function to_basexx( str, alphabet, bits, pad )
   local bitString = basexx.to_bit( str )

   local chunks = divide_string( bitString, bits )
   local result = {}
   for _,value in ipairs( chunks ) do
      if ( #value < bits ) then
         value = value .. string.rep( '0', bits - #value )
      end
      local pos = tonumber( value, 2 ) + 1
      table.insert( result, alphabet:sub( pos, pos ) )
   end

   table.insert( result, pad )
   return table.concat( result )
end

--------------------------------------------------------------------------------
-- rfc 3548: http://www.rfc-editor.org/rfc/rfc3548.txt
--------------------------------------------------------------------------------

local base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
local base32PadMap = { "", "======", "====", "===", "=" }

function basexx.from_base32( str, ignore )
   str = ignore_set( str, ignore )
   return from_basexx( string.upper( str ), base32Alphabet, 5 )
end

function basexx.to_base32( str )
   return to_basexx( str, base32Alphabet, 5, base32PadMap[ #str % 5 + 1 ] )
end

--------------------------------------------------------------------------------
-- crockford: http://www.crockford.com/wrmg/base32.html
--------------------------------------------------------------------------------

local crockfordAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
local crockfordMap = { O = "0", I = "1", L = "1" }

function basexx.from_crockford( str, ignore )
   str = ignore_set( str, ignore )
   str = string.upper( str )
   str = str:gsub( '[ILOU]', function( c ) return crockfordMap[ c ] end )
   return from_basexx( str, crockfordAlphabet, 5 )
end

function basexx.to_crockford( str )
   return to_basexx( str, crockfordAlphabet, 5, "" )
end

--------------------------------------------------------------------------------
-- base64 decode and encode function
--------------------------------------------------------------------------------

local base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
                       "abcdefghijklmnopqrstuvwxyz"..
                       "0123456789+/"
local base64PadMap = { "", "==", "=" }

function basexx.from_base64( str, ignore )
   str = ignore_set( str, ignore )
   return from_basexx( str, base64Alphabet, 6 )
end

function basexx.to_base64( str )
   return to_basexx( str, base64Alphabet, 6, base64PadMap[ #str % 3 + 1 ] )
end

--------------------------------------------------------------------------------
-- URL safe base64 decode and encode function
--------------------------------------------------------------------------------

local url64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
                      "abcdefghijklmnopqrstuvwxyz"..
                      "0123456789-_"

function basexx.from_url64( str, ignore )
   str = ignore_set( str, ignore )
   return from_basexx( str, url64Alphabet, 6 )
end

function basexx.to_url64( str )
   return to_basexx( str, url64Alphabet, 6, "" )
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------

local function length_error( len, d )
   return string.format( "invalid length: %d - must be a multiple of %d", len, d )
end

local z85Decoder = { 0x00, 0x44, 0x00, 0x54, 0x53, 0x52, 0x48, 0x00,
                     0x4B, 0x4C, 0x46, 0x41, 0x00, 0x3F, 0x3E, 0x45,
                     0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                     0x08, 0x09, 0x40, 0x00, 0x49, 0x42, 0x4A, 0x47,
                     0x51, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A,
                     0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32,
                     0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A,
                     0x3B, 0x3C, 0x3D, 0x4D, 0x00, 0x4E, 0x43, 0x00,
                     0x00, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                     0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
                     0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20,
                     0x21, 0x22, 0x23, 0x4F, 0x00, 0x50, 0x00, 0x00 }

function basexx.from_z85( str, ignore )
   str = ignore_set( str, ignore )
   if ( #str % 5 ) ~= 0 then
      return nil, length_error( #str, 5 )
   end

   local result = {}

   local value = 0
   for i = 1, #str do
      local index = string.byte( str, i ) - 31
      if index < 1 or index >= #z85Decoder then
         return nil, unexpected_char_error( str, i )
      end
      value = ( value * 85 ) + z85Decoder[ index ]
      if ( i % 5 ) == 0 then
         local divisor = 256 * 256 * 256
         while divisor ~= 0 do
            local b = math.floor( value / divisor ) % 256
            table.insert( result, string.char( b ) )
            divisor = math.floor( divisor / 256 )
         end
         value = 0
      end
   end

   return table.concat( result )
end

local z85Encoder = "0123456789"..
                   "abcdefghijklmnopqrstuvwxyz"..
                   "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
                   ".-:+=^!/*?&<>()[]{}@%$#"

function basexx.to_z85( str )
   if ( #str % 4 ) ~= 0 then
      return nil, length_error( #str, 4 )
   end

   local result = {}

   local value = 0
   for i = 1, #str do
      local b = string.byte( str, i )
      value = ( value * 256 ) + b
      if ( i % 4 ) == 0 then
         local divisor = 85 * 85 * 85 * 85
         while divisor ~= 0 do
            local index = ( math.floor( value / divisor ) % 85 ) + 1
            table.insert( result, z85Encoder:sub( index, index ) )
            divisor = math.floor( divisor / 85 )
         end
         value = 0
      end
   end

   return table.concat( result )
end

--------------------------------------------------------------------------------

-- return basexx

LIB.DecodeBit = basexx.from_bit
LIB.EncodeBit = basexx.to_bit
LIB.DecodeHex = basexx.from_hex
LIB.EncodeHex = basexx.to_hex
LIB.DecodeBase32 = basexx.from_base32
LIB.EncodeBase32 = basexx.to_base32
LIB.DecodeCrockford = basexx.from_crockford
LIB.EncodeCrockford = basexx.to_crockford
LIB.DecodeBase64 = basexx.from_base64
LIB.EncodeBase64 = basexx.to_base64
LIB.DecodeUrl64 = basexx.from_url64
LIB.EncodeUrl64 = basexx.to_url64
LIB.DecodeZ85 = basexx.from_z85
LIB.EncodeZ85 = basexx.to_z85
