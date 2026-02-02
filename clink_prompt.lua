-- clink prompt: path red, status green/red, git branch cyan. requires clink: https://chrisant996.github.io/clink/

local function ansi(c) return "\x1b[" .. c .. "m" end
local red = ansi("31")
local green = ansi("32")
local magenta = ansi("35")
local cyan = ansi("36")
local yellow = ansi("33")
local reset = ansi("0")

local function get_git_branch()
  local f = io.popen("git branch --show-current 2>nul")
  if not f then return nil end
  local branch = f:read("*l")
  f:close()
  return branch and #branch > 0 and branch or nil
end

local function get_git_status()
  local f = io.popen("git status --short 2>nul")
  if not f then return nil end
  local line = f:read("*l")
  f:close()
  return line
end

local function prompt_filter()
  local cwd = clink.get_cwd()
  if not cwd then cwd = "" end
  if #cwd > 45 then cwd = "..." .. cwd:sub(-42) end
  local code = tonumber(os.getenv("ERRORLEVEL") or "0") or 0
  local status_color = (code == 0) and green or red
  local out = status_color .. " " .. red .. cwd .. reset
  local branch = get_git_branch()
  if branch then
    local dirty = get_git_status() and yellow .. "*" or ""
    out = out .. " " .. cyan .. "(" .. branch .. ")" .. dirty .. reset
  end
  clink.prompt.value = out .. "> "
  return false
end

clink.prompt.register_filter(prompt_filter, 50)
