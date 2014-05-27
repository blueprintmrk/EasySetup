#!/bin/bash

# OpenWP Easy Setup for WordPress

# Easy Setup (es) is command-line setup tool with Markdown config files using WP-CLI
# GitHub: https://github.com/OpenWP/easy-setup

# For WordPress Installation use OpenWP Turbo Engine
# GitHub: https://github.com/OpenWP/turbo-engine

LOG_DIR=/var/log/easy-setup
ERROR_LOG=$LOG_DIR/error.log

DOCUMENT_ROOT=/var/www
DOCUMENT_USER=www-data
# Regex for exclude markdown lines from config files
REGEX_MARKDOWN="^$|^#|^-|^\`"
SSL_DAYS=3650


set_local_constants() {
  DOMAIN=$1
  SITE_ROOT=$DOCUMENT_ROOT/$DOMAIN

  WP_CERT=$SITE_ROOT/cert
  WP_CONFIG=$SITE_ROOT/wp-config.php
  WP_ROOT=$SITE_ROOT/htdocs
  WP_SETTINGS=$SITE_ROOT/wp-settings.php

  WP_CONSTANTS=$SITE_ROOT/constants.md
  WP_OPTIONS=$SITE_ROOT/options.md
  WP_PLUGINS=$SITE_ROOT/plugins.md
  WP_THEMES=$SITE_ROOT/themes.md

  SSL_EMAIL=admin@$DOMAIN
  SSL_COUNTRY=$(echo "$DOMAIN" | rev | cut -d'.' -f1 | rev)
}

help() {
  info "Usage: $0 [Options] <domain>"
  info "all <domain>: Run All Tasks"
  info "constants <domain>: Set WP Constants"
  info "cron <domain>: Set Crontab"
  info "help: Show Help"
  info "options <domain>: Set WP Options"
  info "plugins <domain>: Install WP Plugins"
  info "ssl <domain>: Create Self-signed SSL Certificate"
  info "themes <domain>: Install WP Themes"
  info "update <domain>: Update WP Core, Plugins, Themes"
  exit 0
}

# Info message
info() {
  echo -e "\033[96m$@\e[0m"
}

# Warning message
warn() {
  echo -e "\033[93m$@\e[0m"
}

# Error message
err() {
  echo -e "$(date +"%Y-%m-%d-%H:%M:%S") \033[91m$@\e[0m" | tee -ai $ERROR_LOG
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
  sudo -u $DOCUMENT_USER -i -- wp $@ --path=$WP_ROOT
#  wp $@ --path=$WP_ROOT --allow-root
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
  fi
}

set_crontab() {
  if ! crontab -l | grep -q $WP_ROOT ; then
    info "Setting Crontab, Please Wait..."
    # Write out current crontab
    crontab -l > mycron
    # Echo new cron into cron file
    echo "*/15 * * * * /usr/bin/php5 -q $WP_ROOT/wp-cron.php > /dev/null 2>&1" >> mycron
    # Install new cron file
    crontab mycron
    rm mycron
  else
    info "Already Set Crontab for $WP_ROOT"
  fi
}

create_ssl() {
  info "Creating Self-signed SSL Certificate in $WP_CERT"
  if [ ! -d $WP_CERT ] ; then
    mkdir -p $WP_CERT || err "Unable To Create Directory $WP_CERT"
  fi

  openssl genrsa -out $WP_CERT/$DOMAIN.key 1024
  echo -ne "$SSL_COUNTRY\n$SSL_COUNTRY\n\n$DOMAIN\n$DOMAIN\n$DOMAIN\n$SSL_EMAIL\n" | \
  openssl req -new -key $WP_CERT/$DOMAIN.key -x509 -out $WP_CERT/$DOMAIN.crt -days $SSL_DAYS
}

install_wp_plugins() {
  if [ -e "${WP_PLUGINS}" ] ; then
    info "Installing WordPress Plugins for $WP_ROOT"
    # Skip new lines and lines with chars "#-`" at start
    while read plugin ; do
      info "Installing Plugin: $plugin"
      wpc plugin install $plugin
    done < <(grep -vE $REGEX_MARKDOWN ${WP_PLUGINS})
  else
    err "File $WP_PLUGINS (WP_PLUGINS) Does Not Exist!"
  fi
}

install_wp_themes() {
  if [ -e "${WP_THEMES}" ] ; then
    info "Installing WordPress Themes for $WP_ROOT"
    # Skip new lines and lines with chars "#-`" at start
    while read theme ; do
      info "Installing Theme: $theme"
      wpc theme install $theme
    done < <(grep -vE $REGEX_MARKDOWN ${WP_THEMES})
  else
    err "File $WP_THEMES (WP_THEMES) Does Not Exist!"
  fi
}

set_wp_options() {
  if [ -e "${WP_OPTIONS}" ] ; then
    info "Setting WordPress Options for $WP_ROOT"
    # Skip new lines and lines with chars "#-`" at start
    while read option ; do
      info "Setting Option: $option"
      wpc option update $option
    done < <(grep -vE $REGEX_MARKDOWN ${WP_OPTIONS})
  else
    err "File $WP_OPTIONS (WP_OPTIONS) Does Not Exist!"
  fi
}

set_wp_constants() {
  if [ -e "${WP_CONSTANTS}" ] ; then
    info "Setting WordPress Constants in $WP_CONFIG"
    # Skip new lines and lines with chars "#-`" at start
    while IFS=' ' read -r constant_key constant_value ; do
      if grep -q $constant_key $WP_CONFIG ; then
        info "Setting Constant: $constant_key $constant_value"
        sed -i "s/define('$constant_key'.*/define('$constant_key', ${constant_value});/" $WP_CONFIG
      else
        info "Adding Constant: $constant_key $constant_value"
        echo "define('$constant_key', $constant_value);" >> $WP_CONFIG
      fi
    done < <(grep -vE $REGEX_MARKDOWN ${WP_CONSTANTS})
  else
    err "File $WP_CONSTANTS (WP_CONSTANTS) Does Not Exist!"
  fi
}

update_wp() {
  info "Updating WordPress Core, Plugins, Themes, Please Wait..."
  wpc core update
  wpc plugin update --all
  wpc theme update --all
}

run_all() {
  info "Running All Tasks, Please Wait..."
  set_crontab
  create_ssl
  set_wp_constants
  update_wp
  install_wp_plugins
  install_wp_themes
  set_wp_options
}

init() {
  domain=$1
  set_local_constants $domain
  check
  install_wp-cli
}

info "OpenWP Easy Setup for WordPress"

# Handle Options
case "$1" in
  all|constants|cron|options|plugins|ssl|themes|update) init $2;;
  *) help;
esac

case "$1" in
  all) run_all;;
  constants) set_wp_constants;;
  cron) set_crontab;;
  help) help;;
  options) set_wp_options;;
  plugins) install_wp_plugins;;
  ssl) create_ssl;;
  themes) install_wp_themes;;
  update) update_wp;;
esac
