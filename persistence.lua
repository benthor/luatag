persistence =
   {
   store = function (path, ...)
	      local f, e = io.open(path, "w");
	      if f then
		 f:write("-- Persistent Data\n");
		 f:write("return ");
		 persistence.write(f, select(1,...), 0);
		 for i = 2, select("#", ...) do
		    f:write(",\n");
		    persistence.write(f, select(i,...), 0);
		 end;
		 f:write("\n");
	      else
	      error(e);
	   end;
	   f:close();
	end;
   
   load = function (path)
	     local f, e = loadfile(path);
	     if f then
		return f();
	     else
		--error(e)
		return nil, e;
	     end;
       end;
   
   write = function (f, item, level)
	      local t = type(item);
	      persistence.writers[t](f, item, level);
	   end;
   
   writeIndent = function (f, level)
		 for i = 1, level do
		    f:write("\t");
		 end;
	      end;
   
   writers = {
      ["nil"] = function (f, item, level)
		   f:write("nil");
	     end;
      ["number"] = function (f, item, level)
		      f:write(tostring(item));
		   end;
      ["string"] = function (f, item, level)
		      f:write(string.format("%q", item));
		   end;
      ["boolean"] = function (f, item, level)
		    if item then
		       f:write("true");
		    else
		       f:write("false");
		    end
		 end;
      ["table"] = function (f, item, level)
		     f:write("{\n");
		  for k, v in pairs(item) do
		     persistence.writeIndent(f, level+1);
		     f:write("[");
		     persistence.write(f, k, level+1);
		     f:write("] = ");
		     persistence.write(f, v, level+1);
		     f:write(";\n");
		  end
		  persistence.writeIndent(f, level);
		  f:write("}");
	       end;
      ["function"] = function (f, item, level)
			-- Does only work for "normal" functions, not those
			-- with upvalues or c functions
		     local dInfo = debug.getinfo(item, "uS");
		     if dInfo.nups > 0 then
			f:write("nil -- functions with upvalue not supported\n");
		     elseif dInfo.what ~= "Lua" then
			f:write("nil -- function is not a lua function\n");
		     else
			local r, s = pcall(string.dump,item);
			if r then
			   f:write(string.format("loadstring(%q)", s));
			else
			   f:write("nil -- function could not be dumped\n");
			end
		     end
		  end;
      ["thread"] = function (f, item, level)
		      f:write("nil --thread\n");
		   end;
      ["userdata"] = function (f, item, level)
			f:write("nil --userdata\n");
		     end;
   }
}
