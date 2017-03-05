var app = angular.module('gameOnApp', [])

app.controller('GameOnController', function($timeout) {
               
               var gameOn = this;
               
               var websocket = null;
               var websocketUrl = "ws://" + window.document.location.host + "/room";
               
               gameOn.messages = [];//{"origin":"client|server", "username":"user1","content":"Here's the first message"}];
               
               gameOn.inputMessage = {value : ""};
               
               gameOn.connected = {value :false};
               
               gameOn.isClient = {value :false};
               
               var roomId = "GameOn Swift room";
               
               gameOn.connect = function() {
               
                    gameOn.connected.value = true;
               
                    websocket = new WebSocket(websocketUrl);
               
                    websocket.onerror = function ( event ) {
                    if ( websocket !== null ) {
                        websocket.close();
                        websocket = null;
                    }
                    };
               
                    websocket.onclose = function ( event ) {
                        if ( websocket !== null ) {
                            websocket.close();
                            websocket = null;
                        }
                    };
               
                    websocket.onmessage = function(event) {
                        if ( websocket !== null ) {
               
                            var chatMessage = gameOn.extractChatMsg(event.data);
               
                            if ( chatMessage ){
                                var username = gameOn.extractJson(event.data, "username");
                                gameOn.messages.push({"origin": "server", "username":username, "content":chatMessage});
               
                                $timeout(function() {
                                         var scroller = document.getElementById("autoscroll");
                                         scroller.scrollTop = scroller.scrollHeight;
                                         }, 0, false);
                            }
                        }

                    };
               };
               
               gameOn.disconnect = function() {
                    gameOn.connected.value = false;
                    if ( websocket !== null ) {
                        websocket.close();
                        websocket = null;
                    }
               };
               
               gameOn.send = function (payload) {
                    if ( websocket !== null ) {
               
                        var chatMessage = gameOn.extractChatMsg(payload);
               
                        if ( chatMessage ){
                            var username = gameOn.extractJson(payload, "username");
                            gameOn.messages.push({"origin": "client", "username":username, "content":chatMessage});
               
                            $timeout(function() {
                                     var scroller = document.getElementById("autoscroll");
                                     scroller.scrollTop = scroller.scrollHeight;
                            }, 0, false);
                        }
               
                        websocket.send(payload);
                    }
               };
               
               gameOn.evaluateInput = function () {
               
                    var message = {
                        "username": "Robert",
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
               
               };
               
               gameOn.hello = function () {
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
               };
               
               gameOn.goodbye = function () {
               //    roomGoodbye,<roomId>,{
               //        "username": "username",
               //        "userId": "<userId>"
               //    }
                    var roomGoodbye = {
                        "username": "webtest",
                        "userId": "dummyId"
                    };
               
                    gameOn.send("roomGoodbye," + roomId.value + "," + JSON.stringify(roomGoodbye));
               };
               
               gameOn.join = function () {
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
               };
               
               gameOn.part = function () {
               //    roomPart,<roomId>,{
               //        "username": "username",
               //        "userId": "<userId>"
               //    }
                    var roomPart = {
                        "username": "webtest",
                        "userId": "dummyId"
                    };
               
                    gameOn.send("roomPart," + roomId.value + "," + JSON.stringify(roomPart));
               };
               
               gameOn.extractJson = function (str, element) {
               
                    var arr = str.split(",")
               
                    for(var i in arr) {
               
                        if(arr[i].indexOf(element) != -1) {
               
                            var contentArray = arr[i].split(":")
               
                            //strip first char-- quotation mark
                            var content = contentArray[1].replace(/\"/g, "").replace("}","");
                            return content;
                        }
                    }
                    return null;
               };
                                                     
               gameOn.extractChatMsg = function (str) {
                    if ( str.indexOf("room") == 0 ) {
                                                     
                       var arr = str.split(",")
                                                     
                       for(var i in arr) {
                                                     
                           if(arr[i].indexOf("content") != -1) {
                                                     
                               var contentArray = arr[i].split(":")
                                                     
                               //strip first char-- quotation mark
                               var content = contentArray[1].replace(/\"/g, "")
                                                                                           
                               if(content.charAt(0) != "/") {
                                                                                           
                                  var chat = content.replace("/", "");
                                  chat = chat.replace("}", "");
                                  return chat;
                               }
                           }
                      }
                   }
                return null;
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
