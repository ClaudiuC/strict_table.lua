strict_table.lua
================

A Github mirror of http://snippets.luacode.org/snippets/Strict_Tables_132. You
can read more at
http://steved-imaginaryreal.blogspot.com/2011/09/strict-tables-in-lua.html.

Usage:
======

```
local Strict = require 'strict_table'
 
Strict.Alice {
  x = 1;
  y = 2;
  name = '';
}
 
a = Alice {x = 10, y = 20, name = "alice"}
 
--print(a.z) --> error: field 'z' is not in Alice
 
print(a) --> has a default __tostring
 
Strict.Boo {
  name = 'unknown';
  age = 0;
  __tostring = function(self) -- can override __tostring
    return '#'..self.name
  end;
  __eq = true;   --- default member-equals comparison
  __lt = 'age';  --- use this field for less-than comparison
}
```
