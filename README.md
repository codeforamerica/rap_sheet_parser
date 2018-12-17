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

In order to protect CJI/PII the rap sheet parser will suppress exceptions. To see full error output set the `VERBOSE_PARSER_EXCEPTIONS` env variable.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the unit tests and linter. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Integration tests
This repo also includes an integration test suite which has the ability to take in a set of RAP sheet files and expectations and ensure that the parsed RAP sheets agree with the expectations.

You can run the integration tests with `rake integration`.
 
By default, it expects an Amazon S3 bucket containing `.txt` files that contain RAP sheet text.  It will attempt to parse every RAP sheet in this folder
in order to ensure that no exceptions are thrown.
 
It also expects a subfolder called `with_assertions` that contains RAP sheet `.txt` files paired with `.json` files with the same filename.

For example:
```
rap_sheet_1.txt
rap_sheet_2.txt
with_assertions/
    rap_sheet_3.txt
    rap_sheet_3.json
```

For files in the `with_assertions` folder, it will match the output of the parser against the structure specified in the JSON file. 
The structure of the JSON file is as follows:
```json
{
  "personal_info":{
    "cii": "A01234557",
    "sex": "M",
    "names": {"01": "LAST, FIRST", "02": "COSTANZA, GEORGE"},
    "date_of_birth": "10/31/1967",
    "race": "WHITE"
  },
  "cycles": [
    {
      "events": [
        {
          "header": "arrest",
          "date": "04/20/1994",
          "agency": "CAPD SAN FRANCISCO",
          "counts": [
            {
              "code_section": "PC 602(g)",
              "code_section_description": "TRESPASSING:OYSTER AND SHELLFISH FARM"
            },
            {
              "code_section": "PC 602(e)",
              "code_section_description": "TRESPASSING:DIGGING"
            }
          ]
        },
        {
          "header": "court",
          "date": "08/19/1994",
          "agency": "CAMC San Francisco",
          "counts": [
            {
              "code_section": "PC 602(g)",
              "code_section_description": "TRESPASSING:OYSTER AND SHELLFISH FARM",
              "disposition": {
                "type": "dismissed",
                "text": "DISPO:DISMISSED/FURTHERANCE OF JUSTICE"
              }
            }
          ]
        }
      ]
    }
  ]
}
``` 

In order to use AWS S3, ensure the following environment variables are set:
```
RAP_SHEETS_BUCKET
AWS_ACCESS_KEY_ID
AWS_SECRET_KEY
```

Alternatively, you can read files from a local directory by setting the environment variable `LOCAL_RAP_SHEETS_DIR`.
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codeforamerica/rap_sheet_parser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RapSheetParser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rap_sheet_parser/blob/master/CODE_OF_CONDUCT.md).
