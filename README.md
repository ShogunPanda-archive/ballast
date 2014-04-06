# ballast

[![Gem Version](https://badge.fury.io/rb/ballast.png)](http://badge.fury.io/rb/ballast)
[![Dependency Status](https://gemnasium.com/ShogunPanda/ballast.png?travis)](https://gemnasium.com/ShogunPanda/ballast)
[![Build Status](https://secure.travis-ci.org/ShogunPanda/ballast.png?branch=master)](https://travis-ci.org/ShogunPanda/ballast)
[![Code Climate](https://codeclimate.com/github/ShogunPanda/ballast.png)](https://codeclimate.com/github/ShogunPanda/ballast)
[![Coverage Status](https://coveralls.io/repos/ShogunPanda/ballast/badge.png)](https://coveralls.io/r/ShogunPanda/ballast)
[![Bitdeli Trend](https://d2weczhvl823v0.cloudfront.net/ShogunPanda/ballast/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
<iframe src="http://ghbtns.com/github-btn.html?user=ShogunPanda&repo=ballast&type=fork&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="135" height="20"></iframe>

A collection of base utilities for Ruby on Rails.

http://sw.cow.tc/ballast

http://rdoc.info/gems/ballast

# Description

Ballast is a gem which tries to solve common issues which we all (or, at least, me) usually encounter when we develop with Ruby On Rails.

The first big issue is having fat controllers. To solve this, ballast enbraces the idea of the [interactor](https://github.com/collectiveidea/interactor) gem and it extends it using operations and operations chains.

The second issue is handling AJAX actions in a short way. To solve this, ballast provides the Ajax concern to ease the handling of JSON data, both inbound and outbound.

Finally, minor concerns are provided to scope CSS and handling errors.

## Contributing to ballast
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (C) 2013 and above Shogun (shogun@cowtech.it).

Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
