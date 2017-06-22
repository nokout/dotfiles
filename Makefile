.PHONY: all dotfiles test shellcheck apt

all: dotfiles apt

# bin:
# 	# add aliases for things in bin
# 	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
# 		f=$$(basename $$file); \
# 		sudo ln -sf $$file /usr/local/bin/$$f; \
# 	done
# 	sudo ln -sf $(CURDIR)/bin/browser-exec /usr/local/bin/xdg-open; \

apt:
	apt-get update
	apt-get -y upgrade

	apt-get install -y \
			xclip \
			terminator \
			docker.io \
			dkms \
			jq \
			--no-install-recommends

		# install icdiff
		curl -sSL https://raw.githubusercontent.com/jeffkaufman/icdiff/master/icdiff > /usr/local/bin/icdiff
		curl -sSL https://raw.githubusercontent.com/jeffkaufman/icdiff/master/git-icdiff > /usr/local/bin/git-icdiff
		chmod +x /usr/local/bin/icdiff
		chmod +x /usr/local/bin/git-icdiff

		# install lolcat
		curl -sSL https://raw.githubusercontent.com/tehmaze/lolcat/master/lolcat > /usr/local/bin/lolcat
		chmod +x /usr/local/bin/lolcat


dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -maxdepth 1 -name ".*" -type f -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".gnupg"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	# ln -sfn $(CURDIR)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf;
	# ln -sfn $(CURDIR)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf;
	# ln -fn $(CURDIR)/gitignore $(HOME)/.gitignore;

# etc:
# 	for file in $(shell find $(CURDIR)/etc -type f -not -name ".*.swp"); do \
# 		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
# 		sudo ln -f $$file $$f; \
# 	done
# 	systemctl --user daemon-reload
# 	sudo systemctl daemon-reload

test: shellcheck

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck:
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh
