#
# Author:: Mohit Sethi (<mohit@sethis.in>)
# Copyright:: Copyright (c) 2013 Mohit Sethi.
#

require 'vagrant'

module VagrantPlugins
  module HP
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :access_key

      attr_accessor :secret_key

      attr_accessor :tenant_id

      attr_accessor :availability_zone

      attr_accessor :flavor

      attr_accessor :image

      attr_accessor :server_name

      attr_accessor :keypair_name

      attr_accessor :ssh_private_key_path

      attr_accessor :ssh_username

      attr_accessor :security_groups

      attr_accessor :floating_ip

      def initialize(region_specific = false)
        @access_key = UNSET_VALUE
        @secret_key = UNSET_VALUE
        @server_name = UNSET_VALUE
        @private_ip_address = UNSET_VALUE
        @keypair_name = UNSET_VALUE
        @tenant_id = UNSET_VALUE
        @availability_zone = UNSET_VALUE
        @image = UNSET_VALUE
        @ssh_private_key_path = UNSET_VALUE
        @ssh_username = UNSET_VALUE
        @flavor = UNSET_VALUE

        @__compiled_region_configs = {}
        @__finalized = false
        @__region_config = {}
        @__region_specific = region_specific
      end

      #-------------------------------------------------------------------
      # Internal methods.
      #-------------------------------------------------------------------

      def merge(other)
        super.tap do |result|
          # Copy over the region specific flag. "True" is retained if either
          # has it.
          new_region_specific = other.instance_variable_get(
                                                          :@__region_specific)
          result.instance_variable_set(
            :@__region_specific, new_region_specific || @__region_specific)

          # Go through all the region configs and prepend ours onto
          # theirs.
          new_region_config = other.instance_variable_get(:@__region_config)
          @__region_config.each do |key, value|
            new_region_config[key] ||= []
            new_region_config[key] = value + new_region_config[key]
          end

          # Set it
          result.instance_variable_set(:@__region_config, new_region_config)

          # Merge in the tags
          result.tags.merge!(self.tags)
          result.tags.merge!(other.tags)
        end
      end

      def finalize!
        # The access keys default to nil
        @access_key = nil if @access_key == UNSET_VALUE
        @secret_key = nil if @secret_key == UNSET_VALUE
        @tenant_id = nil if @tenant_id == UNSET_VALUE

        @server_name = nil if @server_name == UNSET_VALUE

        # AMI must be nil, since we can't default that
        @image = nil if @image == UNSET_VALUE

        # Default instance type is an standard.small
        @flavor = 'standard.small' if @flavor == UNSET_VALUE

        # Keypair defaults to nil
        @keypair_name = nil if @keypair_name == UNSET_VALUE

        # Default the private IP to nil since VPC is not default
        @private_ip_address = nil if @private_ip_address == UNSET_VALUE

        # Default availability-zone is az1. This is sensible because HP Cloud
        # generally defaults to this as well.
        @availability_zone = 'az1' if @availability_zone == UNSET_VALUE

        # The SSH values by default are nil, and the top-level config
        # `config.ssh` values are used.
        @ssh_private_key_path = nil if @ssh_private_key_path == UNSET_VALUE
        @ssh_username = nil if @ssh_username == UNSET_VALUE

        # Mark that we finalized
        @__finalized = true
      end

      def validate(machine)
        errors = []
        warnings = []
        messages = []

        # access_key: required
        errors << I18n.t('vagrant_hp.config.access_key_required') \
          if @access_key.nil?

        # secret_key: required
        errors << I18n.t('vagrant_hp.config.secret_key_required') \
          if @secret_key.nil?

        # tenant_id: required
        errors << I18n.t('vagrant_hp.config.tenant_id_required') \
          if @tenant_id.nil?

        # keypair_name: required
        errors << I18n.t('vagrant_hp.config.keypair_name_required') \
          if @keypair_name.nil?

        # image: required
        errors << I18n.t('vagrant_hp.config.image_required') \
          if @image.nil?

        # ssh_private_key_path: required
        errors << I18n.t('vagrant_hp.config.ssh_private_key_path') \
          if @ssh_private_key_path.nil?

        { 'HP Provider' => errors }
      end

      # This gets the configuration for a specific region. It shouldn't
      # be called by the general public and is only used internally.
      def get_region_config(name)
        unless @__finalized
          raise 'Configuration must be finalized before calling this method.'
        end

        # Return the compiled region config
        @__compiled_region_configs[name] || self
      end
    end
  end
end
