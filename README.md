# elm-translations-app

## Overview

This is a sample application made with [Elm](https://elm-lang.org).
It is simply a page with a form, where user can provide translations for arbitrary strings (received from server) to a selected language.

## Building

```
$ elm make src/Main.elm
```

## Running

One will need a mock HTTP server with just two methods:

1. `GET /translations`, responding with a simple JSON object `{ "key": "translation" }` representing strings available for translating and their translated value (empty for no translation)
2. `POST /translations`, responding with `HTTP 204` (empty success), imitating translations saving process

I have used an [online tool](https://beeceptor.com/) for the matter, but something like `http-server` (NPM) would also suffice. One has to change the base URL in the HTTP helpers, though.

