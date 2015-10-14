## Setup

### Setup Requirements
git and bundler installed, intenet acess

### Install
`git clone https://github.com/naturalis/basic-checks.git`

`cd basic-checks`

`bundle install --path vendor/bundle`

### Running
Human readable

`bundle exec rspec`

Nagios format

`bundle exec rspec -f RSpec::Nagios::Formatter`
