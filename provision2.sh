#!/usr/bin/env bash

#install gpg-key
cd ~
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
#again, incase something went wrong
command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -

#Install RVM
curl -L dspr.tk/1t | bash
 
#Set up RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" >> ~/.bashrc
#if we don't have sudo, enable next line
#rvm autolibs read-fail'
rvm install ruby-2.1

#Get the source
cd ~
git clone -b master https://github.com/diaspora/diaspora.git

#configuration
#copy files
cp /vagrant/database.yml ~/diaspora/config
cp /vagrant/diaspora.yml ~/diaspora/config

#bundle
cd ~/diaspora
rvm use --default 2.1
gem install bundler
RAILS_ENV=production ~/diaspora/bin/bundle install --without test development

#Database setup
RAILS_ENV=production ~/diaspora/bin/rake db:create db:schema:load

#Precompile assets
RAILS_ENV=production ~/diaspora/bin/rake assets:precompile
