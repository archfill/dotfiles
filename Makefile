all: init

init:
	bash ./bin/init.sh

neovim-install:
	bash ./bin/linux/neovim_install.sh

neovim-uninstall:
	bash ./bin/linux/neovim_uninstall.sh
