-- clink completions: npm, git, node. requires clink: https://chrisant996.github.io/clink/
-- tab / ctrl+space for completions; right/end to accept suggestion (built-in autosuggestions).

local npm_parser = clink.arg.new_parser()
npm_parser:set_arguments({ "run", "install", "uninstall", "update", "list", "init", "test", "start", "stop" })
clink.arg.register_parser("npm", npm_parser)

local git_parser = clink.arg.new_parser()
git_parser:set_arguments(
  { "checkout", "status", "branch", "pull", "push", "add", "commit", "log", "diff", "merge", "clone", "init", "stash" }
)
clink.arg.register_parser("git", git_parser)

local node_parser = clink.arg.new_parser()
node_parser:set_arguments({ "wt-sphere.js" }, { "--generate", "--set-default", "--set-powershell-default" })
clink.arg.register_parser("node", node_parser)
