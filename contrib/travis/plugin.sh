#!/bin/bash

GITHUB_USER=${GITHUB_USER:-jbox-web}
GITHUB_PROJECT=${GITHUB_PROJECT:-redmine_git_hosting}

GITHUB_SOURCE="${GITHUB_USER}/${GITHUB_PROJECT}"
PLUGIN_PATH=${PLUGIN_PATH:-$GITHUB_SOURCE}
PLUGIN_NAME=${PLUGIN_NAME:-$GITHUB_PROJECT}
PLUGIN_DIR="redmine/plugins/${PLUGIN_NAME}"
CONTRIB_DATA_DIR="${PLUGIN_DIR}/contrib/travis/data"

function install_plugin() {
  install_plugin_libs
  move_plugin
  install_database
  install_gemfile
  install_rspec
  install_plugin_dependencies
}


## PRIVATE


function install_plugin_libs() {
  log_title "INSTALL ADDITIONAL PACKAGES"
  sudo apt-get install -qq libicu-dev libssh2-1 libssh2-1-dev cmake
  log_ok
}


function move_plugin() {
  log_title "MOVE PLUGIN"
  # Move GITHUB_USER/GITHUB_PROJECT to redmine/plugins dir
  mv "${PLUGIN_PATH}" "${REDMINE_NAME}/plugins"
  # Remove parent dir (GITHUB_USER)
  rmdir $(dirname ${PLUGIN_PATH})
  log_ok

  log_title "CREATE SYMLINK"
  ln -s "${REDMINE_NAME}" "redmine"
  log_ok
}


function install_database() {
  log_title "INSTALL DATABASE FILE"
  if [ "$DATABASE_ADAPTER" == "mysql" ] ; then
    echo "Type : mysql"
    cp "${CONTRIB_DATA_DIR}/db_files/database_mysql.yml" "redmine/config/database.yml"
  else
    echo "Type : postgres"
    cp "${CONTRIB_DATA_DIR}/db_files/database_postgres.yml" "redmine/config/database.yml"
  fi

  log_ok
}


function install_gemfile() {
  log_title "INSTALL GEMFILE"

  if [ "$major" == "3" ] ; then
    if [ -f "${CONTRIB_DATA_DIR}/gem_files/rails4.gemfile" ] ; then
      log_title "INSTALL RAILS 4 VERSION"
      cp "${CONTRIB_DATA_DIR}/gem_files/rails4.gemfile" "${PLUGIN_DIR}/Gemfile"
      log_ok
    fi
  else

    if [ -f "${CONTRIB_DATA_DIR}/gem_files/rails3.gemfile" ] ; then
      log_title "INSTALL RAILS 3 VERSION"
      cp "${CONTRIB_DATA_DIR}/gem_files/rails3.gemfile" "${PLUGIN_DIR}/Gemfile"
      log_ok
    fi

    log_title "RAILS 3 : UPDATE REDMINE GEMFILE"

    echo "Update shoulda to 3.5.0"
    sed -i 's/gem "shoulda", "~> 3.3.2"/gem "shoulda", "~> 3.5.0"/' "redmine/Gemfile"
    log_ok

    echo "Let update shoulda-matchers to 2.7.0"
    sed -i 's/gem "shoulda-matchers", "1.4.1"/#gem "shoulda-matchers", "1.4.1"/' "redmine/Gemfile"
    log_ok

    echo "Update capybara to 2.2.0"
    sed -i 's/gem "capybara", "~> 2.1.0"/gem "capybara", "~> 2.2.0"/' "redmine/Gemfile"
    log_ok
  fi
}


function install_rspec() {
  log_title "INSTALL RSPEC FILE"
  mkdir "redmine/spec"
  cp "${PLUGIN_DIR}/spec/root_spec_helper.rb" "redmine/spec/spec_helper.rb"
  log_ok
}


function install_plugin_dependencies() {
  git_clone 'redmine_bootstrap_kit' 'https://github.com/jbox-web/redmine_bootstrap_kit.git'
  git_clone 'redmine_sidekiq'       'https://github.com/ogom/redmine_sidekiq.git'
  install_ssh_key
  install_gitolite
}


function install_ssh_key() {
  log_title "INSTALL ADMIN SSH KEY"
  ssh-keygen -N '' -f "${PLUGIN_DIR}/ssh_keys/redmine_gitolite_admin_id_rsa"
  log_ok
}


function install_gitolite() {
  log_title "INSTALL GITOLITE V3"

  sudo useradd --create-home git
  sudo -n -u git -i git clone https://github.com/sitaramc/gitolite.git
  sudo -n -u git -i mkdir bin
  sudo -n -u git -i gitolite/install -to /home/git/bin
  sudo cp "${PLUGIN_DIR}/ssh_keys/redmine_gitolite_admin_id_rsa.pub" /home/git/
  sudo chown git.git /home/git/redmine_gitolite_admin_id_rsa.pub
  sudo -n -u git -i gitolite setup -pk redmine_gitolite_admin_id_rsa.pub

  log_ok
}
