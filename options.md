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
home 'http://example.com'
siteurl 'http://example.com'
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

### iThemes Security

```sh
itsec_brute_force '{"enabled":true, "max_attempts_host":5, "max_attempts_user":10, "check_period":5}' --format=json
itsec_hide_backend '{"enabled":true, "slug":"wplogin"}' --format=json
itsec_strong_passwords '{"enabled":true, "roll":"editor"}' --format=json
itsec_tweaks '{"force_unique_nicename":true}' --format=json
```

### Nginx Helper

```sh
rt_wp_nginx_helper_options '{"enable_purge":1, "purge_homepage_on_edit":1, "purge_homepage_on_del":1, "purge_archive_on_edit":1, "purge_archive_on_del":1, "purge_page_on_mod":1}' --format=json
```

### WooCommerce

```sh
woocommerce_default_country 'CZ'
woocommerce_currency 'CZK'
woocommerce_allowed_countries 'specific'
woocommerce_specific_allowed_countries '{"0":"CZ","1":"SK"}' --format=json
woocommerce_currency_pos 'right_space'
woocommerce_price_thousand_sep ' '
woocommerce_price_decimal_sep ','

woocommerce_email_footer_text 'OpenWP Easy Setup'
woocommerce_email_from_address 'info@example.com'
woocommerce_email_from_name 'OpenWP Easy Setup'

woocommerce_enable_myaccount_registration 'yes'
woocommerce_enable_signup_and_login_from_checkout 'yes'
woocommerce_registration_generate_password 'yes'
woocommerce_registration_generate_username 'yes'

woocommerce_checkout_order_received_endpoint 'objednavka-prijata'
woocommerce_checkout_pay_endpoint 'platba'
woocommerce_logout_endpoint 'odhlaseni'
woocommerce_myaccount_add_payment_method_endpoint 'pridat-platebni-metodu'
woocommerce_myaccount_edit_account_endpoint 'upravit-ucet'
woocommerce_myaccount_edit_address_endpoint 'editovat-adresu'
woocommerce_myaccount_lost_password_endpoint 'zapomenute-heslo'
woocommerce_myaccount_view_order_endpoint 'zobrazit-objednavku'
```
