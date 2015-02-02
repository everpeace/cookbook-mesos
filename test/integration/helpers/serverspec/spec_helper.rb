# encoding: utf-8
require 'serverspec'

set :backend, :exec

require 'mesosphere_installation'
require 'source_installation'
require 'master_configuration'
require 'slave_configuration'
