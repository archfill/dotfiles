all: init

init:
	./bin/init.sh

neovim-install:
	./bin/linux/neovim_install.sh

neovim-uninstall:
	./bin/linux/neovim_uninstall.sh
