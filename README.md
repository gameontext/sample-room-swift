# Game On! Microservices and Swift

[![Build Status](https://travis-ci.org/gameontext/sample-room-swift.svg?branch=master)](https://travis-ci.org/gameontext/sample-room-swift)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4d099084aab34a57893e8fd29df79ae3)](https://www.codacy.com/app/gameontext/sample-room-java?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=gameontext/sample-room-java&amp;utm_campaign=Badge_Grade)

[Game On!](https://game-on.org/) is both a sample microservices application, and a throwback text adventure brought to you by the WASdev team at IBM. This application demonstrates how microservice architectures work from two points of view:

1. As a Player: navigate through a network/maze of rooms, and interact with other players and the items or actions available in each room.
2. As a Developer: extend the game by creating simple services that define rooms. Learn about microservice architectures and their supporting infrastructure as you build and scale your service.

You can learn more about Game On! at [http://game-on.org/](http://game-on.org/).

## Introduction

This walkthrough will guide you through creating and deploying a simple room (a microservice) to the running Game On! application. This microservice is written in Swift as a server-side Kitura application.

The microservice can be (a) deployed as a Cloud Foundry application or (b) built into a docker container.

Game On! communicates with this service (a room) over WebSockets using the [Game On! WebSocket protocol](https://book.game-on.org/microservices/WebSocketProtocol.html). Consider this a stand-in for asynchronous messaging like MQTT, which requires a lot more setup than a simple WebSocket does.

## Quick start for local development:

You can set up your development environment and use XCode 8 for editing, building, debugging, and testing your server application. To use XCode, you must use the command line tools for generating an XCode project.

1. Download [Xcode 8](https://swift.org/download/)

2. Create your own fork of this repository ([what's a fork?](https://help.github.com/articles/fork-a-repo/))

3. Create a local clone of your fork ([Cloning a repository](https://help.github.com/articles/cloning-a-repository/))

  `git clone https://github.com/<your-forked-repo>/sample-room-swift.git`
  
4. Make an XCode project

  `swift package generate-xcodeproj`
  
5. Install front-end dependencies including gulp and webpack
  
  `npm install`
  
6. Install Swift dependencies using gulp

  `gulp`
  
7. Run the server

  `.build/debug/GameOn`
  
  Then access [http://localhost:8080/](http://localhost:8080/) in your browser. Visiting this page provides a small form you can use to test the WebSocket endpoint in your service directly.
 
## Make your room public!

For Game On! to include your room, you need to tell it where the publicly reachable WebSocket endpoint is. This usually requires two steps:

* [hosting your service somewhere with a publicly reachable endpoint](https://book.gameontext.org/walkthroughs/deployRoom.html), and then
* [registering your room with the game](https://book.gameontext.org/walkthroughs/registerRoom.html).

## Build a docker container

Creating a Docker image is straight-up: `docker build .` right from the root menu.

A `docker-compose.yml` file is also there, which can be used to specify overlay volumes to allow local development without restarting the container. See the [Advanced Adventure for local development with Docker](https://book.game-on.org/v/walkthrough/walkthroughs/local-docker.html) for a more detailed walkthrough.

## Ok. So this thing is running... Now what?

We know, this walkthrough was simple. You have a nice shiny service that emulates async messaging behavior via a WebSocket. So?

The purpose of this text-based adventure is to help you grapple with microservices concepts and technologies
while building something other than what you do for your day job (it can be easier to learn new things
when not bogged down with old habits). This means that the simple service that should be humming along
merrily with your name on it is the beginning of your adventures, rather than the end.

Here is a small roadmap to this basic service, so you can go about making it your own:

* `Sources/gameontext/swiftroom/RoomImplementation.swift`
   This is class contains the core elements that make your microservice unique from others.
   Custom commands and items can be added here (via the `org.gameontext.sample.RoomDescription`
   member variable). The imaginatively named `handleMessage` method, in particular, is called
   when new messages arrive.

* `Sources/gameontext/Protocol/*`
   This package contains a collection of classes that deal with the mechanics of the websocket
   connection that the game uses to allow players to interact with this service. `RoomEndpoint`
   is what it says: that is the WebSocket endpoint for the service.

* `Tests/*` -- Yes! There are tests!

Things you might try:

* Use ??? to manage all of the connected WebSockets together as one event stream.
* Call out to another API (Watson API, Weather API) to perform actions in the room.
* Integrate this room with IFTTT, or Slack, or ...
* .. other [Advanced Adventures](https://book.game-on.org/v/walkthrough/walkthroughs/createMore.html)!

Remember our https://game-on.org/#/terms. Most importantly, there are kids around: make your parents proud.

### Testing

 Run `swift test` to run test cases.
