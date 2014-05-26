# OpenWP Easy Setup WordPress Config Constants Sample

- http://codex.wordpress.org/Editing_wp-config.php
- http://generatewp.com/wp-config

## Compression

```sh
COMPRESS_CSS false
COMPRESS_SCRIPTS false
CONCATENATE_SCRIPTS false
ENFORCE_GZIP false
```

## Cron

- Disable WP cron for managing cron using crontab.

```sh
DISABLE_WP_CRON true
```

## Debug mode for developers

```sh
WP_DEBUG false
WP_DEBUG_LOG false
# Disable prints all non-fatal error messages at the top of the screen.
WP_DEBUG_DISPLAY false
SCRIPT_DEBUG false
SAVEQUERIES false
```

## Localized Language

```sh
WPLANG 'cs_CZ'
```

## Performance

```sh
WP_MEMORY_LIMIT 64M
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
