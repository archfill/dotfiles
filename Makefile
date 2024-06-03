all: init

init:
	bash ./bin/init.sh

neovim-install:
	bash ./bin/linux/apps/neovim_install.sh

neovim-uninstall:
	bash ./bin/linux/apps/neovim_uninstall.sh
