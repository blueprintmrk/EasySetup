# OpenWP Easy Setup for WordPress

Easy Setup (es) is command-line setup tool with Markdown config files using [WP-CLI](http://wp-cli.org)

For WordPress Installation use [OpenWP Turbo Engine](https://github.com/OpenWP/turbo-engine)

Easy Setup is tested on `Ubuntu` and `Debian`.

## Instalation

```sh
git clone https://github.com/OpenWP/easy-setup
cd easy-setup
chmod +x es.sh
sudo mv es.sh /usr/local/bin/es
sudo cp *.md /var/www/example.com
```

### Config Files

Move this config files to `SITE_ROOT` (/var/www/example.com)

- `constants.md`
- `options.md`
- `plugins.md`
- `themes.md`

### Changeable Variables in `es.sh`

```sh
LOG_DIR=/var/log/easy-setup
ERROR_LOG=$LOG_DIR/error.log

DOCUMENT_ROOT=/var/www
DOCUMENT_USER=www-data
# Regex for exclude markdown lines from config files
REGEX_MARKDOWN="^$|^#|^-|^\`"
SSL_DAYS=3650

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
```

## Usage

```sh
es [Options] <domain>
  all <domain>: Run All Tasks
  constants <domain>: Set WP Constants
  cron <domain>: Set Crontab
  help: Show Help
  options <domain>: Set WP Options
  plugins <domain>: Install WP Plugins
  ssl <domain>: Create Self-signed SSL Certificate
  themes <domain>: Install WP Themes
  update <domain>: Update WP Core, Plugins, Themes
```
