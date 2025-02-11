# ExtendedChess

## Desription
A gem for creating custom games like chess. With the creation of their figures, fields and rules.
The gem implements checkers, chess and giveaways and the Mongols setup.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'Extended_chess'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install Extended_chess

## Usage
To interact with the examples, initialize the interface class and use the start procedure.
To add new boards, move rules, figure setups and mods, use the add_board, add_movement_rule, add_piece, add_setup, add_mode procedures.

## Notations  
Notations in chess:  
The usual move is [piece name][cell1]-[cell2], that is, pe2-e3.   
Short castling: 0-0.   
Long castling: 0-0-0.   
Checkers notation:   
The usual move is [piece name][cell1]-[cell2], that is, me2-e3.   

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/EnderGolem/Extended_chess. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/EnderGolem/Extended_chess/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ExtendedChess project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/EnderGolem/Extended_chess/blob/master/CODE_OF_CONDUCT.md).
