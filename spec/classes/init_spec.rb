require 'spec_helper'
describe 'sfu_yaml_to_puppetdsl' do

  context 'with defaults for all parameters' do
    it { should contain_class('sfu_yaml_to_puppetdsl') }
  end
end
