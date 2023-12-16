-- see if the filfe exists
local function file_exists(file_name)
  local f = io.open(file_name, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file_name, returns an empty
-- list/table if the file_name does not exist
local function lines_from(file_name)
  if not file_exists(file_name) then return {} end
  local lines = {}
  for line in io.lines(file_name) do
    lines[#lines + 1] = line
  end

  return lines
end


-- print all line numbers and their contents
local function add_dynamic_java_ali(file_name, root_dir)
  if file_name == nil or root_dir == nil then
    error("[Add_dynamic_java_ali] File name or root dir is null")
  end
  if(not file_exists(root_dir.."/target")) then
    error("[Add_dynamic_java_ali] /target directory wasn't found in ".. root_dir)
  end
  local f = io.open(file_name, "w+")
  if (f == nil) then
    error("[Add_dynamic_java_ali] File wasn't found" .. file_name)
    return
  end

  print("[Add_dynamic_java_ali] Bin alias added in file " .. file_name)

  --adding /bin path
  f:write("target=\"", root_dir, "/target/classes\"", "\n");
  f:write("alias ja=\"java -cp $target\"",   "\n")

  io.close(f)
end

---- tests the functions above
---- adds alies to /home/deuru/.bash_aliases_dyn'
---- by REPLACING ALL ITS CONTENTS
---- 
function Add_java_alies()
  local file_name = '/home/deuru/.bash_aliases_dyn'
  local root_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h')

  if(root_dir == nil or  not file_exists(root_dir .. '/target')) then
    return
  end

  add_dynamic_java_ali(file_name, root_dir)
  print("Added alies to ", file_name)
end

Add_java_alies()

--notes
--  local lines = lines_from(file_name)
--  local line_id;
--  for k, v in pairs(lines) do
--    print(v)
--    if string.find(v, "bin") then
--      line_id = k
--    end
--  end
