#!/usr/bin/env ruby

git_bundles = [ 
    "git://github.com/godlygeek/tabular.git",
    "git://github.com/msanders/snipmate.vim.git",
    "git://github.com/tpope/vim-fugitive.git",
    "git://github.com/int3/vim-extradite.git",
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
    "git://github.com/vim-scripts/Gist.vim.git",
    "git://github.com/vim-scripts/go.vim.git",
    "git://github.com/ervandew/supertab.git",
    "git://github.com/vim-scripts/taglist.vim.git",
    "git://github.com/scrooloose/syntastic.git",
    "git://github.com/briangershon/html5.vim.git",
    "git://github.com/fmoralesc/Tumble.git",
    "git://github.com/vim-scripts/greplace.vim.git",
    "git://github.com/gregsexton/gitv.git",
    "https://github.com/msanders/cocoa.vim"
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
