<?php

if (isset($_SERVER['PANTHEON_ENVIRONMENT'])) {

    $databases = array();

    $update_free_access = FALSE;

    $drupal_hash_salt = '';

    ini_set('session.gc_probability', 1);
    ini_set('session.gc_divisor', 100);

    ini_set('session.gc_maxlifetime', 200000);

    ini_set('session.cookie_lifetime', 2000000);

    $conf['404_fast_paths_exclude'] = '/\/(?:styles)\//';
    $conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
    $conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';


 } # / if (isset($_SERVER['PANTHEON_ENVIRONMENT'])) {
 else{
    /**
     * Local Development
     */
    error_reporting(E_ALL);
    ini_set('display_errors', TRUE);
    ini_set('display_startup_errors', TRUE);

    $databases = array (
        'default' =>
            array (
                'default' =>
                    array (
                        'database' => 'sonos_studio_drupal_web',
                        'username' => 'drupaluser',
                        'password' => 'scEvYh3oM',
                        'host' => '127.0.0.1',
                        'port' => '',
                        'driver' => 'mysql',
                        'prefix' => '',
                    ),
            ),
    );

    $drupal_hash_salt = 'sS3UPYRIhUJs8XSeCo_Juob3f4MM4-dTJ0dlPZ1GH54';

    /**
     * Some distributions of Linux (most notably Debian) ship their PHP
     * installations with garbage collection (gc) disabled. Since Drupal depends on
     * PHP's garbage collection for clearing sessions, ensure that garbage
     * collection occurs by using the most common settings.
     */
    ini_set('session.gc_probability', 1);
    ini_set('session.gc_divisor', 100);

    /**
     * Set session lifetime (in seconds), i.e. the time from the user's last visit
     * to the active session may be deleted by the session garbage collector. When
     * a session is deleted, authenticated users are logged out, and the contents
     * of the user's $_SESSION variable is discarded.
     */
    ini_set('session.gc_maxlifetime', 200000);

    /**
     * Set session cookie lifetime (in seconds), i.e. the time from the session is
     * created to the cookie expires, i.e. when the browser is expected to discard
     * the cookie. The value 0 means "until the browser is closed".
     */
    ini_set('session.cookie_lifetime', 2000000);

    $conf['404_fast_paths_exclude'] = '/\/(?:styles)\//';
    $conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
    $conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';

    # Redis Settings
    /**
    $conf['redis_client_interface'] = 'PhpRedis';
    $conf['cache_backends'][] = 'sites/all/modules/redis/redis.autoload.inc';
    $conf['cache_default_class'] = 'Redis_Cache';
    $conf['cache_class_cache'] = 'Redis_Cache';
    $conf['cache_class_cache_bootstrap'] = 'Redis_Cache';
    $conf['cache_class_cache_menu'] = 'Redis_Cache';
    $conf['cache_class_cache_block'] = 'Redis_Cache';
    $conf['cache_class_cache_content'] = 'Redis_Cache';
    $conf['cache_class_cache_filter'] = 'Redis_Cache';
    $conf['cache_class_cache_form'] = 'Redis_Cache';
    $conf['cache_class_cache_page'] = 'Redis_Cache';


// The following can be omitted unless you changed the default
    $conf['redis_client_host'] = '127.0.0.1'; // default is localhost
    $conf['redis_client_port'] = 6379; // default is 6379
    $conf['redis_client_base'] = 0; // default database is 0
    $conf['redis_client_password'] = ""; // default is no password

    */

# Varnish / Pound SSL Settings

# Settings for Varnish - tell Drupal that it's behind a reverse proxy
    $conf['reverse_proxy'] = TRUE;
    $conf['reverse_proxy_addresses'] = array('127.0.0.1');

    $conf['page_cache_invoke_hooks'] = FALSE;

# Settings for HTTPS cache - tell Drupal that forwarded https is the real thing
    if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) &&
        $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
        $_SERVER['HTTPS'] = 'on';
    }


 }