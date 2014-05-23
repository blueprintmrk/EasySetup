# OpenWP Easy Setup WordPress Config Constants Sample

- http://codex.wordpress.org/Editing_wp-config.php

## Cron

- Disable WP cron for managing cron using crontab.

```sh
DISABLE_WP_CRON true
```

## Debug mode

```sh
WP_DEBUG false

# Disable prints all non-fatal error messages at the top of the screen.
WP_DEBUG_DISPLAY false
```

## Locale

```sh
WPLANG 'cs_CZ'
```

## SSL

- Allow HTTPS for back-end.

```sh
FORCE_SSL_ADMIN true
FORCE_SSL_LOGIN true
```

## Tweak

```sh
# Disable theme and plugin editors.
DISALLOW_FILE_EDIT true

# Disable theme and plugin updating and installing via admin area.
DISALLOW_FILE_MODS true

# Limit number of revisions to keep.
WP_POST_REVISIONS 10
```
