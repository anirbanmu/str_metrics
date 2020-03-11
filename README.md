# StrMetrics

[![checks](https://github.com/anirbanmu/str_metrics/workflows/checks/badge.svg)](https://github.com/anirbanmu/str_metrics/actions?query=workflow%3Achecks)

Ruby gem (native extension in Rust) providing implementations of various string metrics

## Getting Started
### Prerequisites

Install Rust (tested with version `>= 1.38.0`) with:

```sh
curl https://sh.rustup.rs -sSf | sh
```

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'str_metrics'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install str_metrics

## Usage

All metrics in this gem will work with any UTF-8 encodable (convertible to UTF-8 representation) Ruby string. Of note (and possibly different from other libraries of this nature) is the fact that all comparisons are done based on grapheme clusters, utilizing functionality provided by [unicode-segmentation](https://crates.io/crates/unicode-segmentation) & as described by [Unicode Standard Annex #29](https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries).

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
2. Get your code merged to master
3. After a `git pull` on master:

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
