# RapSheetParser

Reads RAP sheets (Record of arrest and prosecutions) into Ruby data structures.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rap_sheet_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rap_sheet_parser

## Usage

```ruby
require 'rap_sheet_parser'

rap_sheet_text = <<~TEXT
  blah blah
  * * * *
  ARR/DET/CITE:           NAM:001
  19910105 CAPD CONCORD     TOC:F
  CNT:001 #65131
  496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
  - - - -
  COURT:                 NAM:002
  19820915 CAMC LOS ANGELES METRO

  CNT: 001 #456
  4056 PC-BREAKING AND ENTERING
  *DISPO:CONVICTED
  * * * END OF MESSAGE * * *
TEXT

rap_sheet = RapSheetParser::Parser.new.parse(rap_sheet_text)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codeforamerica/rap_sheet_parser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RapSheetParser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rap_sheet_parser/blob/master/CODE_OF_CONDUCT.md).
