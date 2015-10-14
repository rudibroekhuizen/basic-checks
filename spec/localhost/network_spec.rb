require 'spec_helper'

describe 'basic network checks' do
  gateway = `ip route show | awk '$3 ~ /^[1-9]+/ {print $3;}'`.strip

  describe routing_table do
    it { should have_entry( :destination => 'default') }
  end

  describe host("#{gateway}") do
    it { should be_reachable }
  end

  describe host('google.com') do
    it { should be_resolvable.by('dns') }
  end

  describe host('kilo.naturalis.nl') do
    it { should be_resolvable }
    it { should be_reachable.with( :port => 443, :proto => 'tcp' ) }
  end

  describe host('8.8.8.8') do
    it { should be_reachable.with( :port => 53, :proto => 'udp' ) }
  end
end
