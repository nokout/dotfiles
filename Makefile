.PHONY: all dotfiles test shellcheck apt

username?=nokout

all: dotfiles apt etc


dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -maxdepth 1 -name ".*" -type f -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".gnupg"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \

	#Add powerline prompt setup from submodule
	ln -sfn $(CURDIR)/bash-powerline/bash-powerline.sh $(HOME)/.bash_powerline

	#Not sure why gitignore needs a harder symlink, but I assume there is a reason
	sudo ln -fn $(CURDIR)/.gitignore $(HOME)/.gitignore;

apt:
	sudo apt-get update
	sudo apt-get -y upgrade

	#add sublime text repo
	
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

	sudo apt-get install -y \
			sublime-text \
			git \
			xclip \
			python-pip \
			terminator \
			docker.io \
			dkms \
			jq \
			curl \
			python3-venv \
			tree \
			nodejs \
			npm \
			--no-install-recommends



etc:
	# Setup the docker user
	sudo usermod -a -G docker $(username)

	# install icdiff in prompt and use it in git
	curl -sSL https://raw.githubusercontent.com/jeffkaufman/icdiff/master/icdiff | sudo dd of=/usr/local/bin/icdiff
	curl -sSL https://raw.githubusercontent.com/jeffkaufman/icdiff/master/git-icdiff | sudo dd of=/usr/local/bin/git-icdiff
	sudo chmod +x /usr/local/bin/icdiff
	sudo chmod +x /usr/local/bin/git-icdiff

	# install lolcat
	curl -sSL https://raw.githubusercontent.com/tehmaze/lolcat/master/lolcat | sudo dd of=/usr/local/bin/lolcat
	sudo chmod +x /usr/local/bin/lolcat

	#Configure Terminator Profile
	sudo ln -sfn $(CURDIR)/terminator_config $(HOME)/.config/terminator/config

# 	for file in $(shell find $(CURDIR)/etc -type f -not -name ".*.swp"); do \
# 		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
# 		sudo ln -f $$file $$f; \
# 	done
#   systemctl --user daemon-reload
#   systemctl daemon-reload

	#Install node tools
	sudo npm install -g nave
	sudo pip install virtualenv
	

test: shellcheck

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(sh    sudo usermod -a -G docker $USERell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck:
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh
