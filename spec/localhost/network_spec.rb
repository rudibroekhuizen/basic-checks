require 'spec_helper'
require 'net/ip'
require 'net/http'
require 'yaml'

public
def working_url(url)
  uri = URI.parse(url)
  if uri.path == ""
   uri.path = '/'
  end
  result = Net::HTTP.start(uri.host, uri.port) { |http| http.get(uri.path) }
  return result.code.to_i
end

def pdf_url(url)
  query = %Q[/usr/bin/curl -L -s -b "cookieSet=1" --head "#{url}" | grep Content-Type]
  result = `#{query}`
  if result.include? "application/pdf"
    return true
  else
    return false
  end
end

describe 'Basic network checks' do
  naturl = 'myexternalip.com'
  natip = Net::HTTP.get("#{naturl}", '/raw')
  mygateway = Net::IP.routes.gateways[0].via
#  ejournals = YAML.load_file('ejournals.yaml')

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
end

describe 'Check e-journals' do
  ejournals = YAML.load_file('ejournals.yaml')
  ejournals['ejournalurls'].each do |url|
    query = %Q[/usr/bin/curl -L -s -b "cookieSet=1" --head "#{url}" | grep Content-Type | grep 'application/pdf']
    describe command(query) do
      its(:exit_status) { should eq 0 }
    end
  end
end

