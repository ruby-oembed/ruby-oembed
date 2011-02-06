# CHANGELOG

## Unreleased

* Fixed several errors that cropped up when the json gem wasn't installed. (Marcos Wright Kuhns)

## 0.8.0 - 6 February 2011

* Added OEmbed::Formatter Backends, to remove the dependency on the json gem and make adding support for other parsing libraries easier. This also fixes GitHub Issue #1. (Marcos Wright Kuhns)
* Catch invalid endpoint URLs on OEmbed::Provider instantiation. (Marcos Wright Kuhns)
* Jeweler uses the new OEmbed::Version Class. (Marcos Wright Kuhns)
* Corrected syntax for Youtube provider in the README (Ryan Richards)
* Removed the deprecated rails/init.rb file. (Marcos Wright Kuhns)

## 0.7.6 - 11 October 2010

* Released all recent changes to judofyr/master on GitHub. (Marcos Wright Kuhns)
* Added CHANGELOG & LICENSE information. (Marcos Wright Kuhns)

## 0.7.5 - 29 September 2010

* Updated the list of [Embedly][embedly] URL schemes. (Aris Bartee)
* [rvmrc file](http://rvm.beginrescueend.com/workflow/rvmrc/) added. (Aris Bartee)

## 0.7.0 - 23 August 2010

* Gemified. (Aris Bartee)
* Added the [Embedly][embedly] Provider. (Alex Kessinger)
* OEmbed::Response now includes the original request url. (Colin Shea)
* Unregistering providers with duplicate URL patterns works. (Marcos Wright Kuhns)

## 0.0.0 - May 2008 - July 2010

* Initial work & release as a library (Magnus Holm, et al.)
* Many Providers supported, including [OohEmbed][oohembed].
* Support for JSON (via the json gem) and XML (via the xml-simple gem).

[ruby-oembed]: http://github.com/judofyr/ruby-oembed "The ruby-oembed Library"
[oembed]: http://oembed.com "The oEmbed protocol"
[oohembed]: http://oohembed.com
[embedly]: http://embed.ly