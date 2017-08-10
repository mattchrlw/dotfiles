#!/usr/bin/env bash
set -e
# Ask for the administrator password upfront
sudo -v
# Keep-alive: update existing sudo time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "  > Pulling latest dot-files..."
cd "$HOME/.dotfiles" && git pull 1> /dev/null

echo "  > Linking dotfiles..."
ln -s ~/.dotfiles/bashrc ~/.bashrc 2> /dev/null
ln -s ~/.dotfiles/bash_profile ~/.bash_profile 2> /dev/null
ln -s ~/.dotfiles/gitconfig ~/.gitconfig 2> /dev/null # TODO: prompt for name and email, don't symlink
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf 2> /dev/null

echo "  > Installing homebrew..."
if command -v brew >/dev/null 2>&1; then
  echo "    > (Skipping) Already installed."
else
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
fi

echo "  > Updating homebrew..."
brew update 1> /dev/null

echo "  > Installing brews..."
brew install $(cat Brewfile|grep -v "#") 2> /dev/null

echo "  > Setting up bash..."
if [ "$SHELL" == '/usr/local/bin/bash' ]; then
  echo "    > (Skipping) Already using bash."
else
  # brew install bash && \
  sudo echo $(brew --prefix)/bin/bash >> /etc/shells && \
  chsh -s $(brew --prefix)/bin/bash
  # echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
  # chsh -s /usr/local/bin/bash
fi

echo "  > Installing casks..."
brew cask install $(cat Caskfile|grep -v "#") 2> /dev/null

echo "    > Clearing homebrew cache"
brew cleanup; brew cask cleanup

echo "==> Done with setup."
