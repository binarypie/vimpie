install: clean symlinks vundle bundles

clean:
	rm -rf ${PWD}/.vim/bundle/*
	rm -rf ~/.vim
	rm -rf ~/.vimrc

vundle:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

symlinks:
	ln -s ${PWD}/.vim ~/.vim
	ln -s ${PWD}/.vimrc ~/.vimrc

bundles:
	vim +BundleInstall! +qall

bundles-clean:
	rm -rf ${PWD}/.vim/bundle/*
	make vundle
	make bundles
