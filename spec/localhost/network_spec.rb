require 'spec_helper'
require 'net/ip'
require 'net/http'
require 'yaml'

public def working_url?(url_str)
  url = URI.parse(url_str)
  Net::HTTP.start(url.host, url.port) do |http|
    http.head(url.request_uri).code == '200'
  end
#  true
rescue
  false
end


describe 'Basic network checks' do
  naturl = 'myexternalip.com'
  natip = Net::HTTP.get("#{naturl}", '/raw')
  mygateway = Net::IP.routes.gateways[0].via

  ejournals = YAML.load_file('ejournals.yaml')
#  puts ejournals['ejournalurls']

  describe 'Check default gateway' do
    describe routing_table do
      it { should have_entry( :destination => 'default', :gateway => "#{mygateway}") }
    end
    describe host("#{mygateway}") do
      it { should be_reachable }
    end
  end
  describe 'Check name resolving' do
    describe host('google.com') do
      it { should be_resolvable.by('dns') }
    end
  end
  describe 'Check internal connectivity' do
    describe host('stack.naturalis.nl') do
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

  describe 'Check e-journals' do
     ejournals['ejournalurls'].each do |url|
       describe url do
         it { should be_working_url(url) }
       end 
#       it "#{url} can be downloaded" do
#         working_url(url)
#       end
     end
  end
end
