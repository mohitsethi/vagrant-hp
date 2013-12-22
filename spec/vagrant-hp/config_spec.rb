require 'vagrant-hp/config'
require 'coveralls'
Coveralls.wear!

describe VagrantPlugins::HP::Config do
  let(:instance) { described_class.new }

  describe 'defaults' do
    subject do
      instance.tap do |o|
        o.finalize!
      end
    end

    its('access_key')                   { should be_nil }
    its('tenant_id')                    { should be_nil }
    its('availability_zone')            { should == 'az1' }
    its('image')                        { should be_nil }
    its('keypair_name')                 { should be_nil }
    its('secret_key')                   { should be_nil }
    its('ssh_private_key_path')         { should be_nil }
    its('ssh_username')                 { should be_nil }
    its('flavor')                       { should == 'standard.small' }
    its('tenant_id')                    { should be_nil }
    its('server_name')                  { should be_nil }
  end

  describe "overriding defaults" do
    # I typically don't meta-program in tests, but this is a very
    # simple boilerplate test, so I cut corners here. It just sets
    # each of these attributes to "foo" in isolation, and reads the value
    # and asserts the proper result comes back out.
    [:access_key, :tenant_id, :availability_zone, :image,
      :keypair_name,:secret_key,:ssh_private_key_path,:ssh_username,
      :flavor,:tenant_id,:server_name].each do |attribute|

      it "should not default #{attribute} if overridden" do
        instance.send("#{attribute}=".to_sym, "foo")
        instance.finalize!
        instance.send(attribute).should == "foo"
      end
    end
  end
end
