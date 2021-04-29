# StrMetrics

[![checks](https://github.com/anirbanmu/str_metrics/workflows/checks/badge.svg)](https://github.com/anirbanmu/str_metrics/actions?query=workflow%3Achecks)
[![Gem Version](https://badge.fury.io/rb/str_metrics.svg)](https://rubygems.org/gems/str_metrics)
[![license](https://img.shields.io/github/license/anirbanmu/str_metrics?style=plastic)](LICENSE)

Ruby gem (native extension in Rust) providing implementations of various string metrics. Current metrics supported are: Sørensen–Dice, Levenshtein, Damerau–Levenshtein, Jaro & Jaro–Winkler. Strings that are UTF-8 encodable (convertible to UTF-8 representation) are supported. All comparison of strings is done at the grapheme cluster level as described by [Unicode Standard Annex #29](https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries); this may be different from many gems that calculate string metrics. See [here](#known-compatibility) for known compatibility.

## Getting Started
### Prerequisites

Install Rust (tested with version `>= 1.38.0`) with:

```sh
curl https://sh.rustup.rs -sSf | sh
```

### Known compatibility

#### Ruby
`3.0`, `2.7`, `2.6`, `2.5`, `2.4`, `2.3`, `jruby`, `truffleruby`

#### Rust
`1.51.0`, `1.50.0`, `1.49.0`, `1.48.0`, `1.47.0`, `1.46.0`, `1.45.2`, `1.44.1`, `1.43.1`, `1.42.0`, `1.41.1`, `1.40.0`, `1.39.0`, `1.38.0`

#### Platforms
`Linux`, `MacOS`, `Windows`

### Installation

#### With [`bundler`](https://bundler.io/)

Add this line to your application's Gemfile:

```ruby
gem 'str_metrics'
```

And then execute:

    $ bundle install

#### Without `bundler`

    $ gem install str_metrics

## Usage

All you need to do to use the metrics provided in this gem is to make sure `str_metrics` is required like:

```ruby
require 'str_metrics'
```

Each metric is shown below with an example & meanings of optional parameters.

### Sørensen–Dice

```ruby
StrMetrics::SorensenDice.coefficient('abc', 'bcd', ignore_case: false)
 => 0.5
```
Options:

Keyword | Type | Default | Description
--- | --- | --- | ---
`ignore_case` | boolean | `false` | Case insensitive comparison?

### Levenshtein

```ruby
StrMetrics::Levenshtein.distance('abc', 'acb', ignore_case: false)
 => 2
```
Options:

Keyword | Type | Default | Description
--- | --- | --- | ---
`ignore_case` | boolean | `false` | Case insensitive comparison?

### Damerau–Levenshtein

```ruby
StrMetrics::DamerauLevenshtein.distance('abc', 'acb', ignore_case: false)
 => 1
```
Options:

Keyword | Type | Default | Description
--- | --- | --- | ---
`ignore_case` | boolean | `false` | Case insensitive comparison?

### Jaro

```ruby
StrMetrics::Jaro.similarity('abc', 'aac', ignore_case: false)
 => 0.7777777777777777
```
Options:

Keyword | Type | Default | Description
--- | --- | --- | ---
`ignore_case` | boolean | `false` | Case insensitive comparison?

### Jaro–Winkler

```ruby
StrMetrics::JaroWinkler.similarity('abc', 'aac', ignore_case: false, prefix_scaling_factor: 0.1, prefix_scaling_bonus_threshold: 0.7)
 => 0.7999999999999999

StrMetrics::JaroWinkler.distance('abc', 'aac', ignore_case: false, prefix_scaling_factor: 0.1, prefix_scaling_bonus_threshold: 0.7)
 => 0.20000000000000007
```
Options:

Keyword | Type | Default | Description
--- | --- | --- | ---
`ignore_case` | boolean | `false` | Case insensitive comparison?
`prefix_scaling_factor` | decimal | `0.1` | Constant scaling factor for how much to weight common prefixes. Should not exceed 0.25.
`prefix_scaling_bonus_threshold` | decimal | `0.7` | Prefix bonus weighting will only be applied if the Jaro similarity is greater given value.

## Motivation

The main motivation was to have a central gem which can provide a variety of string metric calculations. Secondary motivation was to experiment with writing a native extension in Rust (instead of C).

## Development

### Getting started

```bash
gem install bundler
git clone https://github.com/anirbanmu/str_metrics.git
cd ./str_metrics
bundle install
```

### Building (for native component)

```bash
rake rust_build
```

### Testing (will build native component before running tests)
```bash
rake spec
```

### Local installation
```bash
rake install
```

### Deploying a new version
To deploy a new version of the gem to rubygems:

1. Bump version in [version.rb](lib/str_metrics/version.rb) according to [SemVer](https://semver.org/).
2. Get your code merged to `main` branch
3. After a `git pull` on `main` branch:

```bash
rake build && rake release
```

## Authors
- [Anirban Mukhopadhyay](https://github.com/anirbanmu)

See all repo contributors [here](https://github.com/anirbanmu/str_metrics/contributors).

## Versioning

[SemVer](https://semver.org/) is employed. See [tags](https://github.com/anirbanmu/str_metrics/tags) for released versions.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anirbanmu/str_metrics.

## Code of Conduct

Everyone interacting in this project's codebase, issue trackers etc. are expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
