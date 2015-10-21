require 'spec_helper'
require 'net/http'

describe 'Basic network checks' do
  gateway = `ip route show | awk '$3 ~ /^[1-9]+/ {print $3;}'|head -1`.strip
  naturl = 'myexternalip.com'
  natip = Net::HTTP.get("#{naturl}", '/raw')

  describe 'Check default gateway' do
    describe routing_table do
      it { should have_entry( :destination => 'default', :gateway => "#{gateway}") }
    end
    describe host("#{gateway}") do
      it { should be_reachable }
    end
  end
  describe 'Check name resolving' do
    describe host('google.com') do
      it { should be_resolvable.by('dns') }
    end
  end
  describe 'Check internal connectivity' do
    describe host('kilo.naturalis.nl') do
      it { should be_resolvable }
      it { should be_reachable.with( :port => 443, :proto => 'tcp' ) }
    end
  end
  describe 'Check external connectivity' do
    describe host('8.8.8.8') do
      it { should be_reachable.with( :port => 53, :proto => 'udp' ) }
    end
  end
   describe 'Check outside NAT address' do
    it "#{natip} is the outside, translated ip address" do
    end
  end
end
