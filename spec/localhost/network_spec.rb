require 'spec_helper'
require 'net/ip'
require 'net/http'
require 'yaml'
require 'set'

public
def working_url?(url, max_redirects=8)
  response = nil
  seen = Set.new
  loop do
    url = URI.parse(url)
    break if seen.include? url.to_s
    break if seen.size > max_redirects
    seen.add(url.to_s)
    response = Net::HTTP.new(url.host, url.port).request_head(url.path)
    if response.kind_of?(Net::HTTPRedirection)
      url = response['location']
    else
      break
    end
  end
  response.kind_of?(Net::HTTPSuccess) && url.to_s
end


describe 'Basic network checks' do
  naturl = 'myexternalip.com'
  natip = Net::HTTP.get("#{naturl}", '/raw')
  mygateway = Net::IP.routes.gateways[0].via
  ejournals = YAML.load_file('ejournals.yaml')

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
#       begin
#         RestClient.head(url).code != 404
#       rescue => e
#         e.response
         it { should be_working_url(url) }
#       end
       end 
     end
  end
end
