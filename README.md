# string-metrics

[![Build Status](https://travis-ci.org/mlobl/string-metrics.svg?branch=master)](https://travis-ci.org/mlobl/string-metrics)


String metric algorithms for Crystal:
* [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
* [Hamming distance](https://en.wikipedia.org/wiki/Hamming_distance)
* [Damerau–Levenshtein distance](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)
* [Jaro(-Winkler) Distance](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  string-metrics:
    github: mlobl/string-metrics
```

## Usage

```crystal
require "string-metrics"

StringMetrics.damerau_levenshtein("char", "hcar") == 1
StringMetrics.hamming("Micro", "Macro") == 1
StringMetrics.jaro("MARTHA", "MARHTA").round(2) == 0.94
StringMetrics.jaro_winkler("MARTHA", "MARHTA").round(2) == 0.96
StringMetrics.levenshtein("Car", "Char") == 1
```


## Contributing

1. Fork it ( https://github.com/mlobl/string-metrics/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mlobl](https://github.com/mlobl) Meyer Lobl - creator, maintainer
