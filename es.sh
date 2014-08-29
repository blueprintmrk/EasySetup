#!/bin/bash

# OpenWP EasySetup for WordPress

# OpenWP EasySetup (es) is command-line setup tool with Markdown config files using WP-CLI
# GitHub: https://github.com/OpenWP/easysetup

# For WordPress Installation use EasyEngine
# GitHub: https://github.com/rtCamp/easyengine

# The MIT License (MIT) Copyright (c) 2014 OpenWP [http://openwp.github.io]

LOG_DIR=/var/log/easysetup
ES_LOG=$LOG_DIR/es.log

DOCUMENT_ROOT=/var/www
DOCUMENT_USER=www-data
# Regex for exclude markdown and blank lines from config files
REGEX_MARKDOWN="^#|^-|^\*|^\`|^$"
SSL_DAYS=3650
WP_DB_PREFIX=wp_


set_local_constants() {
  DOMAIN=$1
  SITE_ROOT=$DOCUMENT_ROOT/$DOMAIN

  WP_CERT=$SITE_ROOT/cert
  WP_CONFIG=$SITE_ROOT/wp-config.php
  WP_ROOT=$SITE_ROOT/htdocs

  WP_COMMANDS=$SITE_ROOT/setup/commands*.md
  WP_CONSTANTS=$SITE_ROOT/setup/constants*.md
  WP_OPTIONS=$SITE_ROOT/setup/options*.md
  WP_GETOPTIONS=$SITE_ROOT/setup/getoptions*.md
  WP_PLUGINS=$SITE_ROOT/setup/plugins*.md
  WP_THEMES=$SITE_ROOT/setup/themes*.md
  WP_VARIABLES=$SITE_ROOT/setup/variables*.md

  SSL_EMAIL=admin@$DOMAIN
  SSL_COUNTRY=$(echo "$DOMAIN" | rev | cut -d'.' -f1 | rev)
}

help() {
  info "Usage: $0 [Options] <domain>"
  info "all <domain>: Run All Tasks"
  info "commands <domain>: Run WP-CLI Commands"
  info "constants <domain>: Set WP Constants"
  info "cron <domain>: Set Crontab"
  info "help: Show Help"
  info "options <domain>: Set WP Options"
  info "getoptions <domain>: Get WP Options in JSON Format"
  info "plugins <domain>: Install WP Plugins"
  info "ssl <domain>: Create Self-signed SSL Certificate"
  info "themes <domain>: Install WP Themes"
  info "update <domain>: Update WP Core, Plugins, Themes"
  info "variables <domain>: Set Variables in WP Options"
  exit 0
}

# Info message in Cyan color
info() {
  echo $(tput setaf 6)$@$(tput sgr0)
}

# Warning message in Yellow color
warn() {
  echo $(date +"%Y-%m-%d-%H:%M:%S ")$(tput setaf 3)$@$(tput sgr0) | tee -ai $ES_LOG
}

# Error message in Red color
err() {
  echo $(date +"%Y-%m-%d-%H:%M:%S ")$(tput setaf 1)$@$(tput sgr0) | tee -ai $ES_LOG
  exit 100
}

check() {
  # Checking Permissions
  if [[ $EUID -ne 0 ]] ; then
    err "Sudo or Root Privilege Required!" \
        "Usage: sudo es all example.com"
  fi

  # Checking Logs Directory
  if [ ! -d $LOG_DIR ] ; then
    info "Creating Log Directory..."
    mkdir -p $LOG_DIR || err "Unable To Create Log Directory $LOG_DIR"
  fi

  # Checking SITE_ROOT Directory
  if [ ! -d $SITE_ROOT ] ; then
    err "SITE_ROOT Directory ($SITE_ROOT) Does Not Exist!"
  fi

  # Checking Crontab
  if [ ! -e /var/spool/cron/crontabs/$USER ] ; then
    err "Need First Run 'sudo crontab -e'" 
  fi
}

# Run WP-CLI as document user, not root
wpc() {
  eval "sudo -u $DOCUMENT_USER -i -- wp $@ --path=$WP_ROOT"
# eval "wp $@ --path=$WP_ROOT --allow-root"
}

install_wp-cli() {
  if [ ! -x /usr/local/bin/wp ] ; then
    warn "WP-CLI Command Not Found (/usr/local/bin/wp)"
    info "Installing WP-CLI, Please Wait..."
    curl -sOL https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar || err "Unable To Download wp-cli.phar"
    php wp-cli.phar --info --allow-root || err "Unable To Run wp-cli.phar"
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp || err "Unable To Move wp-cli.phar To /usr/local/bin/wp"

    # Tab completion script
    curl -sOL https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash || err "Unable To Download wp-completion.bash"
    mv wp-completion.bash /etc/bash_completion.d || err "Unable To Move wp-completion.bash To /etc/bash_completion.d"
    source /etc/bash_completion.d/wp-completion.bash

    # Enable $DOCUMENT_USER account
    # TODO: Add $DOCUMENT_ROOT
    sed -i "s/$DOCUMENT_USER:\/var\/www:\/usr\/sbin\/nologin/$DOCUMENT_USER:\/var\/www:\/bin\/bash/" /etc/passwd
  fi
}

set_crontab() {
  if ! crontab -l -u $DOCUMENT_USER | grep -q $WP_ROOT ; then
    info "Setting Crontab, Please Wait..."
    # Write out current crontab
    crontab -l -u $DOCUMENT_USER > mycron
    # Echo new cron into cron file
    echo "*/15 * * * * /usr/bin/php5 -q $WP_ROOT/wp-cron.php > /dev/null 2>&1" >> mycron
    # Install new cron file
    crontab -u $DOCUMENT_USER mycron
    rm mycron
  else
    warn "Crontab Already Set for $WP_ROOT"
  fi
}

create_ssl() {
  if [ ! -e $WP_CERT/$DOMAIN.crt ] ; then
    info "Creating Self-signed SSL Certificate in $WP_CERT"
    if [ ! -d $WP_CERT ] ; then
      mkdir -p $WP_CERT || err "Unable To Create Directory $WP_CERT"
    fi

    openssl genrsa -out $WP_CERT/$DOMAIN.key 2048
    echo -ne "$SSL_COUNTRY\n$SSL_COUNTRY\n\n$DOMAIN\n$DOMAIN\n$DOMAIN\n$SSL_EMAIL\n" | \
    openssl req -new -key $WP_CERT/$DOMAIN.key -x509 -out $WP_CERT/$DOMAIN.crt -days $SSL_DAYS
  else
    warn "Certificate Already Exist in $WP_CERT/$DOMAIN.crt"
  fi
}

run_wp_commands() {
  if ls $WP_COMMANDS &> /dev/null; then
    info "Running WP-CLI Commands for $WP_ROOT"
    while read command ; do
      info "Running Command: $command"
      wpc $command
    done < <(cat $WP_COMMANDS | grep -vE $REGEX_MARKDOWN)
  else
    warn "Files $WP_COMMANDS (WP_COMMANDS) Does Not Exist!"
  fi
}

set_wp_constants() {
  if ls $WP_CONSTANTS &> /dev/null; then
    info "Setting WordPress Constants in $WP_CONFIG"
    # Skip new lines and lines with chars "#-`" at start
    while IFS=' ' read -r constant_key constant_value ; do
      if grep -q $constant_key $WP_CONFIG ; then
        info "Updating Constant: $constant_key $constant_value"
        sed -i "s/define('$constant_key'.*/define('$constant_key', ${constant_value});/" $WP_CONFIG
      else
        info "Adding Constant: $constant_key $constant_value"
        sed -i "/<?php/adefine('$constant_key', $constant_value);" $WP_CONFIG
      fi
    done < <(cat $WP_CONSTANTS | grep -vE $REGEX_MARKDOWN)

    info "Replace _domain_ with $DOMAIN"
    sed -i "s/_domain_/$DOMAIN/g" $WP_CONFIG
  else
    warn "Files $WP_CONSTANTS (WP_CONSTANTS) Does Not Exist!"
  fi
}

get_wp_options() {
  if ls $WP_GETOPTIONS &> /dev/null; then
    info "Getting WordPress Options for $WP_ROOT"
    while read option ; do
      info "Getting Option: $option"
      wpc option get $option --format=json | jq '.' > $option.json
    done < <(cat $WP_GETOPTIONS | grep -vE $REGEX_MARKDOWN)
  else
    warn "Files $WP_GETOPTIONS (WP_GETOPTIONS) Does Not Exist!"
  fi
}

set_wp_options() {
  if ls $WP_OPTIONS &> /dev/null; then
    info "Setting WordPress Options for $WP_ROOT"
    while read option ; do
      option_arr=(${option// / })
      file_type=`echo ${option_arr[1]} | cut -d. -f2`
      if [ "$file_type" == "json" ]; then
        info "Getting Option: $option"
        wpc option get ${option_arr[0]} --format=json > temp.json
        info "Merge Option: $option"
        jq -s add temp.json ${option_arr[1]} > temp.json
        wpc option update ${option_arr[0]} --format=json < temp.json
      else
        info "Update Option: $option"
        wpc option update $option
      fi
    done < <(cat $WP_OPTIONS | grep -vE $REGEX_MARKDOWN)
    rm temp.json
  else
    warn "Files $WP_OPTIONS (WP_OPTIONS) Does Not Exist!"
  fi
}

set_wp_variables() {
  if ls $WP_VARIABLES &> /dev/null; then
    info "Setting Variables in WordPress Options for $WP_ROOT"
    while read variable ; do
      info "Setting Variable: $variable"
      wpc search-replace $variable $WP_DB_PREFIXoptions
    done < <(cat $WP_VARIABLES | grep -vE $REGEX_MARKDOWN)
  else
    warn "Files $WP_VARIABLES (WP_VARIABLES) Does Not Exist!"
  fi
}

install_wp_plugins() {
  if ls $WP_PLUGINS &> /dev/null; then
    info "Installing WordPress Plugins for $WP_ROOT"
    while read plugin ; do
      info "Installing Plugin: $plugin"
      wpc plugin install $plugin
    done < <(cat $WP_PLUGINS | grep -vE $REGEX_MARKDOWN)
  else
    warn "Files $WP_PLUGINS (WP_PLUGINS) Does Not Exist!"
  fi
}

install_wp_themes() {
  if ls $WP_THEMES &> /dev/null; then
    info "Installing WordPress Themes for $WP_ROOT"
    while read theme ; do
      info "Installing Theme: $theme"
      wpc theme install $theme
    done < <(cat $WP_THEMES | grep -vE $REGEX_MARKDOWN)
  else
    warn "Files $WP_THEMES (WP_THEMES) Does Not Exist!"
  fi
}

update_wp() {
  info "Updating WordPress Plugins, Themes, Core, Please Wait..."
  wpc plugin update --all
  wpc theme update --all
  wpc core update
}

run_all() {
  info "Running All Tasks, Please Wait..."
  set_crontab
  create_ssl
  install_wp_plugins
  install_wp_themes
  set_wp_constants
  set_wp_options
  set_wp_variables
  run_wp_commands
  update_wp
}

init() {
  domain=$1
  set_local_constants $domain
  check
  install_wp-cli
}

info "OpenWP EasySetup for WordPress"

# Handle Options
case "$1" in
  all|commands|constants|cron|getoptions|options|plugins|ssl|themes|update|variables) init $2;;
  *) help;
esac

case "$1" in
  all) run_all;;
  commands) run_wp_commands;;
  constants) set_wp_constants;;
  cron) set_crontab;;
  getoptions) get_wp_options;;
  help) help;;
  options) set_wp_options;;
  plugins) install_wp_plugins;;
  ssl) create_ssl;;
  themes) install_wp_themes;;
  update) update_wp;;
  variables) set_wp_variables;;
esac
