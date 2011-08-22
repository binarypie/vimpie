#!/usr/bin/env ruby

git_bundles = [ 
    "https://github.com/godlygeek/tabular.git",
    "https://github.com/msanders/snipmate.vim.git",
    "https://github.com/tpope/vim-fugitive.git",
    "https://github.com/int3/vim-extradite.git",
    "https://github.com/tpope/vim-git.git",
    "https://github.com/tpope/vim-markdown.git",
    "https://github.com/tpope/vim-repeat.git",
    "https://github.com/tpope/vim-surround.git",
    "https://github.com/nathanaelkane/vim-indent-guides.git",
    "https://github.com/tsaleh/vim-tcomment.git",
    "https://github.com/altercation/vim-colors-solarized.git",
    "https://github.com/wincent/Command-T.git",
    "https://github.com/pangloss/vim-javascript.git",
    "https://github.com/vim-scripts/python.vim--Vasiliev.git",
    "https://github.com/paulyg/Vim-PHP-Stuff.git",
    "https://github.com/vim-scripts/Gist.vim.git",
    "https://github.com/vim-scripts/go.vim.git",
    "https://github.com/ervandew/supertab.git",
    "https://github.com/vim-scripts/taglist.vim.git",
    "https://github.com/scrooloose/syntastic.git",
    "https://github.com/briangershon/html5.vim.git",
    "https://github.com/fmoralesc/Tumble.git",
    "https://github.com/vim-scripts/greplace.vim.git",
    "https://github.com/gregsexton/gitv.git",
    "https://github.com/msanders/cocoa.vim.git"
]

require 'fileutils'

puts "Starting..."

bundles_dir = File.join(File.dirname(__FILE__), "vim/bundle")
FileUtils.cd(bundles_dir)

puts "        Emptying Bundle Directory!"
Dir["*"].each {|d| FileUtils.rm_rf d }

git_bundles.each do |url|
  dir = url.split('/').last.sub(/\.git$/, '')
  puts "        Downloading #{dir}"
  `git clone #{url} #{dir}`
  FileUtils.rm_rf(File.join(dir, ".git"))
end

puts "        Building Command-T"
commandt_dir = File.join(File.dirname(__FILE__), "command-t")
FileUtils.cd(commandt_dir)
`rake make`

puts "Finished!"
