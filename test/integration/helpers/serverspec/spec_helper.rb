# encoding: utf-8

require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

require 'mesosphere_installation'
require 'source_installation'
require 'master_configuration'
require 'slave_configuration'
