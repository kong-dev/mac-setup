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
tap "homebrew/cask-versions"
tap "homebrew/cask-fonts"
tap "dteoh/sqa"  # for slowquitapps

brew "curl"
brew "git"
brew "go"
brew "gradle"
brew "jadx"
brew "m-cli"
brew "mas"
brew "n"
brew "node"
brew "openjdk@8"
brew "openjdk@11"
brew "php"
brew "protobuf"
brew "sqlcipher"
brew "thefuck"
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
cask "bob"
cask "clashx-pro"
cask "dash"
cask "db-browser-for-sqlite"
cask "dingtalk"
cask "docker"
cask "epic-games"
cask "evernote"
cask "godot"
cask "google-chrome"
cask "hiddenbar"
cask "iina"
cask "iina-plus"
cask "intellij-idea"
cask "iterm2"
cask "itsycal"
cask "jd-gui"
cask "keka"
cask "maczip"
cask "neteasemusic"
cask "omnidisksweeper"
cask "parallels"
cask "postico"
cask "postman"
cask "pritunl"
cask "qbittorrent"
cask "qlcolorcode"
cask "qlimagesize"
cask "qlmarkdown"
cask "qlprettypatch"
cask "qlstephen"
cask "qq"
cask "quicklook-csv"
cask "quicklook-json"
# cask "epubquicklook"
cask "webpquicklook"
cask "slowquitapps"
cask "sourcetree"
cask "steam"
cask "sunloginclient"
cask "switchkey"
cask "telegram"
cask "tencent-lemon"
cask "typora"
cask "upic"
cask "visual-studio-code"
cask "wechat"
cask "wechatwebdevtools"

cask "font-hack-nerd-font"

mas "iShot", id: 1485844094
mas "Reeder", id: 1449412482
mas "Xcode", id: 497799835
mas "Pages 文稿", id: 409201541
mas "Numbers 表格", id: 409203825
mas "Keynote 讲演", id: 409183694
mas "iMovie 剪辑", id: 408981434
# mas "库乐队", id: 682658836
EOF
brew cleanup -s

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
