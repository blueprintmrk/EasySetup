# OpenWP Easy Setup WordPress Options Sample for Czech Environment

- http://codex.wordpress.org/Option_Reference
- http://wp-cli.org/commands/option

## Core

### General

```sh
admin_email 'admin@example.com'
blogdescription 'OpenWP Easy Setup'
blogname 'Můj Blog'
date_format 'j.n.Y'
time_format 'G:i'
timezone_string 'Europe/Prague'
```

### Permalinks

```sh
permalink_structure '/%postname%-%year%%monthnum%'
category_base 'rubrika'
tag_base 'stitek'
```

### Privacy

```sh
blog_public 0
```

### Reading

```sh
posts_per_page 10
posts_per_rss 10
```

## Plugins

### Nginx Helper

```sh
rt_wp_nginx_helper_options '{"enable_purge":"1", "purge_homepage_on_edit":"1", "purge_homepage_on_del":"1", "purge_archive_on_edit":"1", "purge_archive_on_del":"1", "purge_page_on_mod":"1"}' --format=json
```

### WooCommerce

```sh
woocommerce_default_country 'CZ'
woocommerce_currency 'CZK'
woocommerce_allowed_countries 'specific'
woocommerce_specific_allowed_countries '{"0":"CZ","1":"SK"}' --format=json
woocommerce_registration_email_for_username 'yes'
woocommerce_lock_down_admin 'no'
woocommerce_allow_customers_to_reorder 'yes'
woocommerce_currency_pos 'right_space'
woocommerce_price_thousand_sep ' '
woocommerce_price_decimal_sep ','
```
