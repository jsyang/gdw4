GDW4
====

# Startup
You'll need nodeJS and Redis installed to run everything locally.

## Client

    # Starts the client files server
    cd client
    http-server
    
## Server

    # Starts the Node game server
    cd server
    node core/server.js
    
    # Starts the Redis server
    cd REDIS_DIRECTORY
    src/redis-server

Go to http://localhost:8080 in your browser

====

Word lists : categorized by subject
http://www.manythings.org/vocabulary/lists/c/

Simple English list
http://www.manythings.org/vocabulary/lists/a/

Using Redis for the data store
http://stackoverflow.com/questions/2608103/is-there-any-nosql-that-is-acid-compliant
http://stackoverflow.com/questions/14929700/what-should-i-be-using-socket-io-rooms-or-redis-pub-sub

http://redis.io/commands/hmset
http://redis.io/commands/lrange

Other notes
http://stackoverflow.com/questions/5756067/how-to-empty-a-redis-database
https://github.com/LearnBoost/Socket.IO/wiki/Configuring-Socket.IO
http://stackoverflow.com/questions/5701491/save-nested-hash-in-redis-via-a-node-js-app
http://stackoverflow.com/questions/5729891/redis-performance-store-json-object-as-a-string
http://stackoverflow.com/questions/14929700/what-should-i-be-using-socket-io-rooms-or-redis-pub-sub
