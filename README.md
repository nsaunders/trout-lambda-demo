# trout-lambda-demo
A Trout-based API on AWS Lambda

This project tests the concept of deploying a [Nodetrout](https://github.com/nsaunders/purescript-nodetrout)-powered API on AWS Lambda.

To do this, you'll need [Up](http://up.docs.apex.sh). The [`up.json` config](up.json) assumes you have a profile named _trout-lambda-demo_ in your `~/.aws/credentials` file.

Build: `spago bundle-app --to app.js`

Commit `app.js` after building.

Deploy: `up`
