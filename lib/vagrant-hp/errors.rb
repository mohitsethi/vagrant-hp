#
# Author:: Mohit Sethi (<mohit@sethis.in>)
# Copyright:: Copyright (c) 2013 Mohit Sethi.
#

require 'vagrant'

module VagrantPlugins
  module HP
    module Errors
      class VagrantHPError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_hp.errors')
      end

      class FogError < VagrantHPError
        error_key(:fog_error)
      end

      class RsyncError < VagrantHPError
        error_key(:rsync_error)
      end
      
      class NoMatchingFloatingIp < VagrantHPError
          error_key(:floating_ip_error)
      end
    end
  end
end
