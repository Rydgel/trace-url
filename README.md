# trace-url

Trace-url is a toy url expander/tracer written with Haskell.

## Install

With cabal

    cabal configure
    cabal build
    cabal install


## Usage

    trace-url your_url

## Example

    trace-url http://httpbin.org/redirect/5
    This URL has 5 redirect hop(s) to the destination.
    Redirect Log:
    http://httpbin.org/redirect/5
    http://httpbin.org/redirect/4
    http://httpbin.org/redirect/3
    http://httpbin.org/redirect/2
    http://httpbin.org/redirect/1
    http://httpbin.org/get

