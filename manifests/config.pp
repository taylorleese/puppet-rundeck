# Author::    Liam Bennett (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class rundeck::config
#
# This private class is called from `rundeck` to manage the configuration
#
class rundeck::config(
  $auth_type             = $rundeck::auth_type,
  $auth_users            = $rundeck::auth_users,
  $user                  = $rundeck::user,
  $group                 = $rundeck::group,
  $ssl_enabled           = $rundeck::ssl_enabled,
  $framework_config      = $rundeck::framework_config,
  $projects_organization = $rundeck::projects_default_org,
  $projects_description  = $rundeck::projects_default_desc,
  $rd_loglevel           = $rundeck::rd_loglevel,
  $rss_enabled           = $rundeck::rss_enabled,
  $grails_server_url     = $rundeck::grails_server_url,
  $dataSource_dbCreate   = $rundeck::dataSource_dbCreate,
  $dataSource_url        = $rundeck::dataSource_url,
  $keystore              = $rundeck::keystore,
  $keystore_password     = $rundeck::keystore_password,
  $key_password          = $rundeck::key_password,
  $truststore            = $rundeck::truststore,
  $truststore_password   = $rundeck::truststore_password,
  $service_logs_dir      = $rundeck::service_logs_dir,
  $mail_config           = $rundeck::mail_config,
) inherits rundeck::params {

  $framework_properties = merge($rundeck::params::framework_defaults, $framework_config)

  $logs_dir = $framework_properties['framework.logs.dir']
  $rdeck_base = $framework_properties['rdeck.base']
  $projects_dir = $framework_properties['framework.projects.dir']
  $admin_user = $framework_properties['framework.server.username']
  $admin_password = $framework_properties['framework.server.password']
  $properties_dir = $framework_properties['framework.etc.dir']

  ensure_resource('file', $properties_dir, {'ensure' => 'directory', 'owner' => $user, 'group' => $group} )



  if $auth_type == 'file' {
    file { "${properties_dir}/jaas-loginmodule.conf":
      owner   => $user,
      group   => $group,
      mode    => '0640',
      content => template('rundeck/jaas-loginmodule.conf.erb'),
      require => File[$properties_dir]
    }

    file { "${properties_dir}/realm.properties":
      owner   => $user,
      group   => $group,
      mode    => '0640',
      content => template('rundeck/realm.properties.erb'),
      require => File[$properties_dir]
    }
  }

  file { "${properties_dir}/log4j.properties":
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template('rundeck/log4j.properties.erb'),
    require => File[$properties_dir]
  }

  file { "${properties_dir}/admin.aclpolicy":
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template('rundeck/admin.aclpolicy.erb'),
    require => File[$properties_dir]
  }

  file { "${properties_dir}/apitoken.aclpolicy":
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template('rundeck/apitoken.aclpolicy.erb'),
    require => File[$properties_dir]
  }

  file { "${properties_dir}/profile":
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template('rundeck/profile.erb'),
    require => File[$properties_dir]
  }

  class { 'rundeck::config::global::framework': } ->
  class { 'rundeck::config::global::project': } ->
  class { 'rundeck::config::global::rundeck_config': } ->
  class { 'rundeck::config::global::ssl': }
}
