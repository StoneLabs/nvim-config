local M = {}

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

local function in_repo()
  return vim.fn.systemlist({ "git", "rev-parse", "--is-inside-work-tree" })[1] == "true"
end

local function git_lines(args)
  return vim.fn.systemlist(vim.list_extend({ "git", "--no-pager" }, args))
end

local function commit_template()
  local lines = { "", "" }
  local branch = vim.fn.systemlist({ "git", "branch", "--show-current" })[1]
  if branch and branch ~= "" then
    lines[#lines + 1] = "# On branch " .. branch
  end
  local staged = vim.fn.systemlist({ "git", "--no-pager", "diff", "--cached", "--name-status" })
  if #staged > 0 then
    lines[#lines + 1] = "# Changes to be committed:"
    for _, entry in ipairs(staged) do
      lines[#lines + 1] = "#\t" .. entry
    end
  end
  lines[#lines + 1] = "#"
  lines[#lines + 1] = "# :w or :wq to commit, :q! to cancel"
  return lines
end

local function parse_commit_message(lines)
  local msg = {}
  for _, line in ipairs(lines) do
    if vim.startswith(line, "#") then
      goto continue
    end
    if line == "" and #msg == 0 then
      goto continue
    end
    msg[#msg + 1] = line
    ::continue::
  end
  while #msg > 0 and msg[#msg] == "" do
    table.remove(msg)
  end
  return msg
end

local function git_commit()
  if not in_repo() then
    vim.notify("Not a git repository", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, commit_template())
  vim.api.nvim_buf_set_name(buf, "git://commit")
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  vim.api.nvim_set_option_value("filetype", "gitcommit", { buf = buf })

  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd("startinsert!")

  vim.api.nvim_buf_set_keymap(buf, "n", "<C-s>", ":write<CR>", { desc = "Commit", silent = true })
  vim.api.nvim_buf_set_keymap(buf, "i", "<C-s>", "<Esc>:write<CR>", { desc = "Commit", silent = true })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local msg = parse_commit_message(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
      if #msg == 0 then
        vim.notify("Empty commit message", vim.log.levels.WARN)
        return
      end

      local msgfile = vim.fn.tempname()
      vim.fn.writefile(msg, msgfile)
      local result = vim.fn.systemlist({ "git", "commit", "-F", msgfile })
      vim.fn.delete(msgfile)

      if vim.v.shell_error ~= 0 then
        vim.notify(table.concat(result, "\n"), vim.log.levels.ERROR)
        return
      end

      vim.api.nvim_set_option_value("modified", false, { buf = buf })
      vim.notify(table.concat(result, "\n"), vim.log.levels.INFO)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })
end

local function show(args, opts)
  opts = opts or {}
  if not in_repo() then
    vim.notify("Not a git repository", vim.log.levels.ERROR)
    return
  end

  local lines = git_lines(args)
  if #lines == 0 then
    lines = { "(empty)" }
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = opts.ft or "git"
  vim.api.nvim_buf_set_name(buf, opts.name or ("git://" .. args[1]))

  if opts.open == "vsplit" then
    vim.cmd("vsplit")
  else
    vim.cmd("split")
  end
  vim.api.nvim_win_set_buf(0, buf)
end

local function show_file(args, opts)
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to show", vim.log.levels.WARN)
    return
  end
  show(vim.list_extend(args, { "--", file }), opts)
end

local function git_terminal(args, opts)
  opts = opts or {}
  if not in_repo() then
    vim.notify("Not a git repository", vim.log.levels.ERROR)
    return
  end

  local cmd = vim.list_extend({ "git", "--no-pager" }, args)
  vim.cmd("botright split")
  vim.cmd("enew")
  vim.bo.bufhidden = "wipe"
  if opts.name then
    vim.api.nvim_buf_set_name(0, opts.name)
  end

  local job_id = vim.fn.termopen(cmd, {
    env = vim.tbl_extend("force", vim.fn.environ(), {
      GIT_PAGER = "cat",
      PAGER = "cat",
    }),
  })
  if job_id <= 0 then
    vim.notify("Failed to open git terminal", vim.log.levels.ERROR)
  end
end

local function git_run(args)
  if not in_repo() then
    vim.notify("Not a git repository", vim.log.levels.ERROR)
    return
  end
  local lines = git_lines(args)
  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR)
    return
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

map("<leader>gs", function()
  git_terminal({ "-c", "color.status=always", "status" }, { name = "git://status" })
end, "Git status")
map("<leader>gw", function() show({ "diff", "--stat" }, { name = "git://diff-stat" }) end, "Git diff stat")
map("<leader>gd", function() show({ "diff" }, { name = "git://diff", ft = "diff" }) end, "Git diff")
map("<leader>gD", function() show({ "diff", "--cached" }, { name = "git://diff-staged", ft = "diff" }) end, "Git diff staged")
map("<leader>gf", function() show_file({ "diff" }, { name = "git://diff-file", ft = "diff" }) end, "Git diff file")
map("<leader>gF", function() show_file({ "diff", "--cached" }, { name = "git://diff-file-staged", ft = "diff" }) end, "Git diff file staged")
map("<leader>gl", function() show({ "log", "--oneline", "-20" }, { name = "git://log" }) end, "Git log")
map("<leader>gL", function()
  show({ "log", "--oneline", "--graph", "--decorate", "--all", "-30" }, { name = "git://log-graph" })
end, "Git log graph")
map("<leader>go", function() show({ "show", "--stat", "HEAD" }, { name = "git://show", ft = "git" }) end, "Git show HEAD")
map("<leader>gR", function() show({ "reflog", "--oneline", "-20" }, { name = "git://reflog" }) end, "Git reflog")
map("<leader>gb", function() show({ "branch", "-vv" }, { name = "git://branch" }) end, "Git branches")
map("<leader>gr", function() show({ "remote", "-v" }, { name = "git://remote" }) end, "Git remotes")
map("<leader>gS", function() show({ "stash", "list" }, { name = "git://stash" }) end, "Git stash list")
map("<leader>gB", function() show_file({ "blame" }, { name = "git://blame", ft = "git" }) end, "Git blame file")
map("<leader>ga", function() git_run({ "add", vim.fn.expand("%") }) end, "Git add file")
map("<leader>gu", function() git_run({ "add", "-u" }) end, "Git add update")
map("<leader>gA", function() git_run({ "add", "-A" }) end, "Git add all")
map("<leader>gc", git_commit, "Git commit")
map("<leader>gp", function() git_terminal({ "push" }) end, "Git push")
map("<leader>gP", function() git_terminal({ "pull" }) end, "Git pull")

return M
