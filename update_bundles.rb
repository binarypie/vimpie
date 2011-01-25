#!/usr/bin/env ruby

git_bundles = [ 
    "git://github.com/godlygeek/tabular.git",
    "git://github.com/msanders/snipmate.vim.git",
    "git://github.com/tpope/vim-fugitive.git",
    "git://github.com/tpope/vim-git.git",
    "git://github.com/tpope/vim-markdown.git",
    "git://github.com/tpope/vim-repeat.git",
    "git://github.com/tpope/vim-surround.git",
    "git://github.com/nathanaelkane/vim-indent-guides.git",
    "git://github.com/tsaleh/vim-tcomment.git",
    "git://github.com/jsahlen/vim-ir_black.git",
    "git://github.com/wincent/Command-T.git",
    "git://github.com/pangloss/vim-javascript.git",
    "git://github.com/vim-scripts/python.vim--Vasiliev.git",
    "git://github.com/paulyg/Vim-PHP-Stuff.git",
    "git://github.com/skwp/greplace.vim.git",
    "https://github.com/vim-scripts/Gist.vim.git",
    "git://github.com/vim-scripts/go.vim.git"
]

vim_org_scripts = [
]

require 'fileutils'
require 'open-uri'

bundles_dir = File.join(File.dirname(__FILE__), "vim/bundle")
FileUtils.cd(bundles_dir)

puts "Trashing everything (lookout!)"
Dir["*"].each {|d| FileUtils.rm_rf d }

git_bundles.each do |url|
  dir = url.split('/').last.sub(/\.git$/, '')
  puts "  Unpacking #{url} into #{dir}"
  `git clone #{url} #{dir}`
  FileUtils.rm_rf(File.join(dir, ".git"))
end

vim_org_scripts.each do |name, script_id, script_type|
  puts "  Downloading #{name}"
  local_file = File.join(name, script_type, "#{name}.vim")
  FileUtils.mkdir_p(File.dirname(local_file))
  File.open(local_file, "w") do |file|
    file << open("http://www.vim.org/scripts/download_script.php?src_id=#{script_id}").read
  end
end

commandt_dir = File.join(File.dirname(__FILE__), "command-t")
FileUtils.cd(commandt_dir)
`rake make`
