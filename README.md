# Distil

### What is it?

Distil is a *request routing* and *parameter validation* DSL.  It is designed for rapid development of small API services.  It is easy to use, read, maintain, and extend.  It promotes some useful conventions for application design without Doing Too Much.

It is a Racktivesupport web framework like those to which you are probably accustomed.  We will have proper documentation soon.

#### I hate reading and want to use this right now!

Ok... https://github.com/vitrue/distil/tree/master/lib/distil/examples

#### Quick philosophical point

In Distil, the API flows in the direction that the request would be serviced.  You define first the route, then a set of acceptable parameters for that route, and finally designate a handler.  

#### Request routing

In this regard, Distil looks a lot like Sinatra.  Writing (and reading) routes and handlers is simple.  There is no need to have multiple open files to figure out what code responds to `GET /foo`.

#### Parameter Validation

Inside of a route's DSL block (or in a named parameter block which can be used later from any route) you define a set of acceptable (required/optional/header) parameters.  You may also define a set of transformations on each parameter, to be run before or after validation.  For invalid requests, information about which parameters failed validation and which validations they failed is returned.  Otherwise, the (optionally transformed) parameters are yielded to the route handler.

-----------

## Contributing

We welcome pull requests.  With specs.

## Open Source

The MIT License (MIT)
Copyright (c) Vitrue

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Versions

We will stick to Semantic Versioning (http://semver.org/), as closely as Bundler will allow.