local platform = require('utils.platform')

local options = {
   default_prog = {},
   launch_menu = {},
}

if platform.is_win then
   options.default_prog = { 'nu' }
   options.launch_menu = {
      { label = 'WSL Arch', domain = { DomainName = 'WSL:Arch' } },
      { label = 'Nushell', domain = { DomainName = 'local' }, args = { 'nu' } },
      {
         label = 'PowerShell',
         domain = { DomainName = 'local' },
         args = { 'pwsh', '-NoLogo' },
      },
      { label = 'Command Prompt', domain = { DomainName = 'local' }, args = { 'cmd' } },
      { label = 'Windows PowerShell', domain = { DomainName = 'local' }, args = { 'powershell' } },
   }
elseif platform.is_mac then
   options.default_prog = { '/opt/homebrew/bin/nu', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { '/opt/homebrew/bin/fish', '-l' } },
      { label = 'Nushell', args = { '/opt/homebrew/bin/nu', '-l' } },
      { label = 'Zsh', args = { 'zsh', '-l' } },
   }
elseif platform.is_linux then
   options.default_prog = { 'fish', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { 'fish', '-l' } },
      { label = 'Zsh', args = { 'zsh', '-l' } },
   }
end

return options
