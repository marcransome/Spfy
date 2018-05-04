# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Start using [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).
- A separate version file, lib/spfy/version.rb
- Lots of Yard docs.
- Specs.
- Command line options to control the meta-data of a playlist.
- Option to prettify the output via `tidy`

### Changed

- Start following [SemVer](http://semver.org) properly.
- Updated gemspec to current standards (2018) e.g. a separate version file, git ls-files etc
- Moved executable from bin/ to exe/ so as not to get caught up with binstubs.
- Using docopt for parsing, it's so much easier to work with than other opt-parsers.
- Moved from building up the XML line by line, tag by tag, to running it through ERB templates.
- More object orientated design.
- Some of the options for suppressing output.

## [1.0.0]

- A working product at this point.