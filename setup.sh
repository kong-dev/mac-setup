#!/bin/sh

set -e

# Ask for the administrator password upfront
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo -e "enter git name"
read name
echo -e "enter git email"
read email

echo System Settings...

osascript -e 'tell application "System Preferences" to quit'

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library
# Show path in the finder
defaults write com.apple.finder ShowPathbar -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false
# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 55

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Enable Safari Develop Menu and Web Inspector
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true && \
defaults write com.apple.Safari IncludeDevelopMenu -bool true && \
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true && \
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true && \
defaults write -g WebKitDeveloperExtras -bool true

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

for app in "Dock" \
	"Finder" \
	"SystemUIServer";
do
	killall "${app}" &> /dev/null
done

echo System Settings Finish

# Force use Intel GPU (1 - AMD GPU, 2 - auto)
# sudo pmset -a GPUSwitch 0

echo Install Applications...

# Homebrew, also install Xcode Command Tool
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=- <<EOF
tap "homebrew/bundle"
tap "homebrew/core"
tap "homebrew/cask"
tap "buo/cask-upgrade"
tap "golangci/tap"
tap "hashicorp/tap"
tap "kamilturek/python2"
tap "bigwig-club/brew" # upic
tap "brewforge/chinese" # messauto
tap "brewforge/extras"

brew "act"
brew "bat"
brew "curl"
brew "fzf"
brew "git"
brew "go"
brew "gradle"
brew "jadx"
brew "jq"
brew "m-cli"
brew "mas"
brew "nomad"
brew "node"
brew "openjdk@8"
brew "openjdk@11"
brew "openjdk@17"
brew "pandoc"
brew "php"
brew "pnpm"
brew "protobuf"
brew "protoc-gen-go"
brew "sqlcipher"
brew "thefuck"
brew "tldr"
brew "wget"
brew "yarn"
brew "zsh-autosuggestions"
brew "zsh-completions"
brew "zsh-syntax-highlighting"

cask "adrive"
cask "alfred"
cask "android-platform-tools"
cask "android-studio"
cask "baidunetdisk"
cask "basictex"
cask "calibre"
cask "clashx-pro"
cask "cleanshot"
cask "dash"
cask "db-browser-for-sqlite"
cask "dingtalk"
cask "docker"
cask "easydict"
cask "epic-games"
cask "font-hack-nerd-font"
cask "godot"
cask "google-chrome"
cask "google-earth-pro"
cask "iina"
cask "iina-plus"
cask "intellij-idea"
cask "iterm2"
cask "itsycal"
cask "jd-gui"
cask "maczip"
cask "messauto"
cask "neteasemusic"
cask "obsidian"
cask "omnidisksweeper"
cask "parallels"
cask "postico"
cask "pritunl"
cask "proxyman"
cask "qbittorrent"
cask "qlcolorcode"
cask "qlimagesize"
cask "qlmarkdown"
cask "qlprettypatch"
cask "qlstephen"
cask "qq"
cask "quicklook-csv"
cask "quicklook-json"
cask "sketchbook"
cask "steam"
cask "sunloginclient"
cask "tailscale"
cask "telegram"
cask "upic"
cask "visual-studio-code"
cask "webpquicklook"
cask "wechat"
cask "wechatwebdevtools"

mas "Reeder", id: 1449412482
mas "Xcode", id: 497799835
mas "Pages 文稿", id: 409201541
mas "Numbers 表格", id: 409203825
mas "Keynote 讲演", id: 409183694
mas "iMovie 剪辑", id: 408981434
EOF
brew cleanup -s

pnpm install -g @antfu/ni
pnpm install -g live-server

# Uninstall Google Update
~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall --nuke

echo Install Applications Finish

# Git
git config --global user.name "$name"
git config --global user.email "$email"
git config --global init.defaultBranch master
git config --global core.autocrlf input
git config --global core.excludesfile ~/.gitignore
git config --global pull.rebase true
git config --global push.followTags true
git config --global format.pretty "%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"
git config --global log.abbrevCommit true
git config --global http.postBuffer 524288000
git config --global credential.helper osxkeychain
git config --global alias.co "checkout"
git config --global alias.lg "log --color --graph"
git config --global alias.alias "config --get-regexp alias"
git config --global alias.amend "commit --amend --reuse-message=HEAD"
git config --global alias.rmtag "\!f() { git tag -d \$1 && git push origin :refs/tags/\$1 && git tag; }; f"
git config --global url."git@github.com:".insteadOf "gh:"
git config --global --add url."git@github.com:".insteadOf "github:"
git config --global url."git@gist.github.com:".insteadOf "gist:"

# npm mirror
npm i -g mirror-config-china --registry=https://registry.npm.taobao.org

# gem mirror
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/

# install cocoapods
sudo gem install cocoapods
pod setup

# install Flutter SDK
git clone -b master https://github.com/flutter/flutter.git -b stable --depth 1 ~/.sdk/Flutter
flutter precache
flutter doctor

# install SpaceVim
/bin/bash -c "$(curl -fsSL https://spacevim.org/cn/install.sh)"

# oh-my-zsh insecure warning, remove write permission for group and others
compaudit | xargs chmod g-w,o-w

# install Oh-My-Zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
