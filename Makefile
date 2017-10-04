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

	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

	wget -qO - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google.list

	# Green recorder repo
	sudo add-apt-repository ppa:fossproject/ppa

	curl https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
	echo "deb [arch=amd64] https://repo.skype.com/deb/ stable main" | sudo tee /etc/apt/sources.list.d/skypeforlinux.list

	#Git Kraken - note for personal use only
	wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
	sudo dpkg -i gitkraken-amd64.deb

	sudo apt-get install -y \
			dkms \
			jq \
			curl \
			tree \
			xclip \
			terminator \
			git \
			docker.io \
			python-pip \
			python3-venv \
			sublime-text \
			meld \
			nodejs \
			npm \
			google-chrome-stable \
			vlc \
			gimp \
			bleachbit \
			glipper \
			skypeforlinux \
			--no-install-recommends

# Consider evernote and dropbox


	# Remove the stupid amazon stuff - if its there (errors suppressed)
	sudo gio trash  \
		/usr/share/applications/ubuntu-amazon-default.desktop \
		/usr/share/unity-webapps/userscripts/unity-webapps-amazon/Amazon.user.js \
		/usr/share/unity-webapps/userscripts/unity-webapps-amazon/manifest.json \
		&>/dev/null

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
	sudo pip install virtualenv sphinx
	

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
