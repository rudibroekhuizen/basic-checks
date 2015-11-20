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

describe 'Check e-journals' do
  ejournals = YAML.load_file('ejournals.yaml')
  ejournals['ejournalurls'].each do |url|
    query = %Q[/usr/bin/curl -L -s -b "cookieSet=1" --head "#{url}" | grep Content-Type | grep 'application/pdf']
    describe command(query) do
      its(:exit_status) { should eq 0 }
    end
  end
end

