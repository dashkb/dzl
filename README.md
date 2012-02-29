# Diesel

### What is it?

Diesel is a *request routing* and *parameter validation* DSL.  It is designed for rapid development of small API services.  It is easy to use, read, maintain, and extend.  It promotes some useful conventions for application design without Doing Too Much.

#### Quick philosophical point

In Diesel, the API flows in the direction that the request would be serviced.  You define first the route, then a set of acceptable parameters for that route, and finally designate a handler.  

#### Request routing

In this regard, Diesel looks a lot like Sinatra.  Writing (and reading) routes and handlers is simple.  There is no need to have multiple open files to figure out what code responds to `GET /foo`.

#### Parameter Validation

Inside of a route's DSL block (or in a named parameter block which can be used later from any route) you define a set of acceptable (required/optional/header) parameters.  You may also define a set of transformations on each parameter, to be run before or after validation.  For invalid requests, information about which parameters failed validation and which validations they failed is returned.  Otherwise, the (optionally transformed) parameters are yielded to the route handler.

-----------

### Why are we doing it?

We want to steadily add service-orientedness to the platform.  Rails is big and slow and hogs memory.  It provides us with features that we don't need and costs us extra time and money to deploy and maintain.  Rails seems to encourage us to cram everything we possibly can into each application, because someone already crammed everything they possibly could into the framework.

Sinatra is a great answer to Rails, and we tried it for Trey.  (With success, I might add.)  But not only did Sinatra not give us everything we needed it really ended up not providing us with very much.  The only feature of Sinatra we really use in Trey is the DSL, which is actually rather similar to Rack's DSL.

Why is Diesel special?  Because the only features in it are things that answer this question: "What drove me crazy while I was writing Trey?"  The two things that we have the most generalized-but-not-part-of-the-framework code for are, you guessed it, routing & parameter validation.  We had some parameters (like `:metrics, :interval, :since, :until`) that applied to lots of routes and got validated the same way on each route.  We had others (like `:sort, :limit, :order`) that only apply to one or a couple of routes.  Each parameter needed to be validated a different way based on the route, but also they shared some similarities.  (i.e. `:post_ids` is always an array of integers, but on `/posts` is limited to a size of 10 and on `/post_insights` is limited to a size of 15.)

It also turns out that APIs written in Diesel will be self documenting.  If reading the API definition isn't good enough, it will be trivial to dump HTML/Markdown/Whatever formatted documentation for each route and its parameters.  If we add specifications for the output format to the DSL, we will also be able to document the types of responses to expect from each route.

Completed, Diesel should be a just-add-water (`diesel new my_awesome_api; cd my_awesome_api; hack; hack; deploy`) solution for quickly developing and deploying APIs with a very short list of dependencies and small memory footprints.
