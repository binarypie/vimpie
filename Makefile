install: clean symlinks vundle bundles

clean:
	rm -rf ${PWD}/.vim/bundle/*
	rm -rf ~/.vim
	rm -rf ~/.vimrc

vundle:
	git clone git://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

symlinks:
	ln -s ${PWD}/.vim ~/.vim
	ln -s ${PWD}/.vimrc ~/.vimrc

bundles:
	vim +BundleInstall! +qall
