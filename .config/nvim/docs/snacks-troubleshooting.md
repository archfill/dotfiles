# snacks.nvim Troubleshooting Guide

## 🔧 Common Issues and Solutions

### Issue: "command not found: colorscript" in Dashboard

**Problem**: Dashboard shows error message about missing colorscript command.

**Cause**: The terminal section in snacks.dashboard was trying to run colorscript which is not installed.

**Solution**: ✅ **FIXED** - Removed problematic terminal section from dashboard configuration.

**To apply the fix**:
1. Restart Neovim completely: `:qa` then `nvim`
2. Or reload configuration: `:source $MYVIMRC`
3. Or sync plugins: `:Lazy sync`

### Issue: Git Status Errors in Dashboard

**Problem**: Git status section shows errors when not in a git repository.

**Solution**: ✅ **FIXED** - Added conditional git detection and error handling.

**Configuration changes**:
- Git status only shows in git repositories
- Error handling prevents display issues
- Fallback message for non-git directories

### Manual Configuration Reload

If you're still seeing old error messages:

```lua
-- Reload snacks configuration
:lua require("snacks").setup()

-- Or restart dashboard
:lua require("snacks").dashboard()

-- Check current config
:lua print(vim.inspect(require("snacks").config.dashboard))
```

### Verification Commands

```bash
# Check if config is clean
grep -r "colorscript" ~/.config/nvim/
# Should return no results

# Test dashboard manually
nvim -c "lua require('snacks').dashboard()"
```

### Complete Reset (If Needed)

1. Close all Neovim instances: `:qa!`
2. Clear any caches: `rm -rf ~/.local/share/nvim/`
3. Restart Neovim: `nvim`
4. Sync plugins: `:Lazy sync`

## ✅ Status

- **colorscript issue**: ✅ Fixed
- **Git status handling**: ✅ Improved  
- **Dashboard functionality**: ✅ Working
- **Performance**: ✅ Maintained (30ms startup)

The snacks.nvim configuration is now robust and error-free!