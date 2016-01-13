require 'spec_helper'
describe 'supervisor_provider' do

  context 'with defaults for all parameters' do
    it { should contain_class('supervisor_provider') }
  end
end
