var app = angular.module('gameOnApp', [])

app.controller('GameOnController', function($timeout) {
            var gameOn = this;
            
            var websocket = null;
            var websocketUrl = "ws://" + window.document.location.host + "/room";
            
            gameOn.messages = [];//{"username":"user1","content":"Here's the first message"}];
            
            gameOn.inputMessage = {value : ""};
               
            gameOn.connected = {value :false};
               
            gameOn.isClient = {value :false};
               
            var roomId = "GameOn Swift room";
               
            gameOn.connect = function() {
//                console.log("connect %o", websocket);
               
               gameOn.connected.value = true;
            
//                if ( websocket === null ) {
            
                    websocket = new WebSocket(websocketUrl);
                    console.log("new websocket: %o", websocket);
            
                    websocket.onerror = function(event) {
                        console.log("error! "+ event.data)
                        if ( websocket !== null ) {
                            websocket.close();
                            websocket = null;
                        }

                    };
            
                    websocket.onclose = function(event) {
                        console.log("closing connection")
                        if ( websocket !== null ) {
                            websocket.close();
                            websocket = null;
                        }

                    };
            
                    websocket.onmessage = function(event) {
                        console.log("ON MESSAGE")
                        //event.data is payload from server
//                        console.log("server--> " + event.data)
                        //gameOn.isClient.value = false;
                        gameOn.messages.push({"username":"server", "content":event.data})
                    }
//                };
            }
            
            gameOn.disconnect = function() {
            
                console.log("disconnect %o", websocket);
                gameOn.connected.value = false;
                if ( websocket !== null ) {
                    websocket.close();
                    websocket = null;
                }
            }
            
            gameOn.send = function (payload) {
//                console.log("sendSocket %o, %o", websocket, payload);
                if ( websocket !== null ) {
               
               gameOn.messages.push({"username":"client", "content":payload})
                    websocket.send(payload);
                }
               
               $timeout(function() {
                        var scroller = document.getElementById("autoscroll");
                        scroller.scrollTop = scroller.scrollHeight;
                        }, 0, false);
            }
               
            gameOn.evaluateInput = function () {
               console.log("emulateClient %o", websocket);
               
               var message = {
                "username": "webtest",
                "userId": "dummyId"
               };
               
               var txt = gameOn.inputMessage.value;
               gameOn.inputMessage.value = "";
               
               if ( txt.indexOf("clear") >= 0) {
                    gameOn.messages = [];
               } else {
                    message.content = txt;
                    gameOn.send("room," + roomId + "," + JSON.stringify(message));
               }

            }
               
            gameOn.hello = function () {
               console.log("hello %o", websocket);
               //    roomHello,<roomId>,{
               //        "username": "username",
               //        "userId": "<userId>",
               //        "version": 1|2
               //    }
               var roomHello = {
               "username": "webtest",
               "userId": "dummyId",
               "version": 2
               };
               
               gameOn.send("roomHello," + roomId + "," + JSON.stringify(roomHello));
            }

            gameOn.goodbye = function () {
               console.log("goodbye %o", websocket);
               //    roomGoodbye,<roomId>,{
               //        "username": "username",
               //        "userId": "<userId>"
               //    }
               var roomGoodbye = {
               "username": "webtest",
               "userId": "dummyId"
               };
               
               gameOn.send("roomGoodbye," + roomId.value + "," + JSON.stringify(roomGoodbye));
            }
               
            gameOn.join = function () {
               console.log("join %o", websocket);
               //    roomJoin,<roomId>,{
               //        "username": "username",
               //        "userId": "<userId>",
               //        "version": 2
               //    }
               var roomJoin = {
               "username": "webtest",
               "userId": "dummyId",
               "version": 2
               };
               
               gameOn.send("roomJoin," + roomId.value + "," + JSON.stringify(roomJoin));
            }
               
            gameOn.part = function () {
               console.log("part %o", websocket);
               //    roomPart,<roomId>,{
               //        "username": "username",
               //        "userId": "<userId>"
               //    }
               var roomPart = {
               "username": "webtest",
               "userId": "dummyId"
               };
               
               gameOn.send("roomPart," + roomId.value + "," + JSON.stringify(roomPart));
            }
               
            
            

            
            });

app.directive('ngEnter', function () {
            return function (scope, element, attrs) {
              element.bind("keydown keypress", function (event) {
                           if (event.which === 13) {
                           scope.$apply(function () {
                                        scope.$eval(attrs.ngEnter);
                                        });
                           
                           event.preventDefault();
                           }
                           });
              };
              });
