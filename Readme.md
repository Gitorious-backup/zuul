# Zuul: The Gitorious gatekeeper (aka API)

Zuul is a stand-alone application that serves an HTTP Hypermedia API for
interacting with Gitorious. It speaks the Hypermedia Application Language (HAL):
http://stateless.co/hal_specification.html
http://tools.ietf.org/html/draft-kelly-json-hal-05

Simply stated, HAL specifies how to embed links in resource payloads for XML and
JSON. Zuul only uses JSON.

Zuul also uses JSON schema to describe the payloads it serves and accepts,
though clients are not specifically required to do anything with them. The
schemas are provided first and foremost as a formal type of documentation.

# Browsing the API

Zuul bundles the HAL browser, which is useful to manually explore the API and
read documentation and JSON schemas. Visit it starting the application (see
below) and visit http://localhost:9292/browser/

# Running the application

Zuul can run in two modes: The dummy mode, which is provided for development
purposes, and production mode, which requires a working Gitorious 3.x instance.

## Running the dummy mode

Zuul ships a very minimal `config/environment.rb` that shims the Gitorious APIs
used by the application. Specify the path to Zuul as `GITORIOUS_HOME` to run in
this mode:

    $ env GITORIOUS_HOME=. rackup -Ilib

## Running the production mode

Zuul depends on Gitorious 3.x (currently the next branch). In order to run Zuul
with the Gitorious application loaded, you need to start it with Bundler, using
Gitorious' Gemfile. The reason for this is that you're loading the Gitorious
application within Zuul, thus depending on gems that are not required to run
Zuul in dummy mode (in fact, this is one of the reasons why the dummy mode even
exists - it's a lot fast to boot up).

    $ env GITORIOUS_HOME=/path/to/gitorious3 \
        BUNDLE_GEMFILE=$GITORIOUS_HOME/Gemfile \
        bundle exec rackup -Ilib

You can also start Zuul from `GITORIOUS_HOME`:

    $ env GITORIOUS_HOME=. \
        bundle exec rackup /path/to/zuul/config.ru -I/path/to/zuul/lib

# Architecture

Zuul is a Sinatra application. However, to avoid bloat, each API endpoint/action
is implemented as a separate endpoint class. These are found in
`lib/zuul/endpoint/*.rb`. The endpoints are associated with URLs and HTTP verbs
through the `config/routes.rb` file. This file typically wires together endpoint
objects with URL patterns/HTTP verbs and dependencies from Gitorious. This file
is the only file that should refer to global Gitorious classes.

Endpoints typically return an object wrapped in a serializer. Serializers live
in `lib/zuul/serializer/*.rb` and specify how model objects are expressed as
hashes, whether the endpoint result was successful etc. Every endpoint returns
something that can be serialized as a hash, and the application then JSON
encodes the hash.

Many endpoints use "mutations" from Gitorious. Most serializers can wrap an
`Outcome` instance, and communicate failure/success etc.
