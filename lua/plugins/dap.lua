return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "igorlfs/nvim-dap-view",
    },
    config = function()
      local dap = require("dap")

      -- Visible breakpoint signs in the gutter
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "", numhl = "" })
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400", bold = true })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#848484", bold = true })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#ffff00", bold = true })

      require("dap-view").setup({
        auto_toggle = true,
      })

      -- easy-dotnet attaches asynchronously after \cd; refresh UI once stopped
      dap.listeners.after.event_stopped["dotnet-dap-view"] = function(session)
        if session.config.type ~= "easy-dotnet" then
          return
        end
        vim.schedule(function()
          require("dap-view").open()
          require("dap-view").show_view("scopes")
        end)
      end

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: step over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: step into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP: step out" })

      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Conditional breakpoint" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP: conditional breakpoint" })
      vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "DAP: run to cursor" })
      vim.keymap.set("n", "<leader>dc", dap.clear_breakpoints, { desc = "DAP: clear breakpoints" })
      vim.keymap.set("n", "<leader>dv", function()
        require("dap-view").toggle()
      end, { desc = "DAP: toggle debug UI" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "DAP: toggle REPL" })
      vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "DAP: terminate" })
    end,
  },
}
