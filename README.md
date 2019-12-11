# ballast

## END OF DEVELOPMENT NOTICE - This gem has been discontinued

A collection of base utilities for web frameworks.

# Description

Ballast is a gem which tries to solve common issues which we all (or, at least, me) usually encounter when we develop with Ruby On Rails or other web frameworks.

The first big issue is having fat controllers. To solve this, ballast enbraces the idea of the [interactor](https://github.com/collectiveidea/interactor) gem and it implements a service interface.

The second issue is handling AJAX actions in a short way. To solve this, ballast provides the Ajax concern to ease the handling of JSON data, both inbound and outbound.

Finally, minor concerns are provided to scope CSS and handling errors.

## API Documentation

The API documentation can be found [here](https://sw.cowtech.it/ballast/docs).

## Contributing to ballast

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
- Fork the project.
- Start a feature/bugfix branch.
- Commit and push until you are happy with your contribution.
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (C) 2013 and above Shogun (shogun@cowtech.it).

Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
