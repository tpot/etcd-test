require 'spec_helper'

context 'when etcd client and server installed' do

  describe service('etcd') do
    it { should be_enabled }
    it { should be_running }
  end

  ports = [2379, 2380]

  ports.each do |p|
    describe port(p) do
      it { should be_listening }
    end
  end

  describe command('etcdctl cluster-health') do
    its(:stdout) { should match /cluster is healthy/ }
    its(:exit_status) { should eq 0 }
  end
    
end
