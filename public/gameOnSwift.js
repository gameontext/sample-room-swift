var app = angular.module('gameOnApp', [])

app.controller('GameOnController', function() {
            var gameOn = this;
            
            var websocket = null;
            var websocketUrl = "ws://" + window.document.location.host + "/room";
            
               gameOn.messages = [];
            gameOn.message = {value:"here"};
            
            console.log("setting connected to false")
            gameOn.connected = {value :false};
               
            
            
            gameOn.connect = function() {
                console.log("connect %o", websocket);
                console.log("setting connected to true")
                gameOn.connected.value = true;
            
                if ( websocket === null ) {
            
                    websocket = new WebSocket(websocketUrl);
                    console.log("new websocket: %o", websocket);
            
                    websocket.onerror = function(event) {
                        console.log("error! "+ event.data)
                    };
            
            
                    websocket.onclose = function(event) {
                        websocket = null;
                    };
            
                    websocket.onmessage = function(event) {
                        //event.data is payload from server
                        console.log("server--> " + event.data)
                    }
                };
            }
            
            gameOn.disconnect = function() {
            
                console.log("disconnect %o", websocket);
                gameOn.connected.value = false;
                if ( websocket !== null ) {
                    websocket.close();
            
                }
            }
            
            gameOn.send = function(payload) {
                console.log("sendSocket %o, %o", websocket, payload);
                if ( websocket !== null ) {
//                    response.innerHTML += "&rarr; " + payload + "<br />";
                    console.log("client<-- "+ payload);
               gameOn.messages.push({"username":"client", "content":payload})
                    websocket.send(payload);
                }
            }

            
            
            angular.element(document).ready(function () {
//                                            gameOn.connect();
                                            });
            

            
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


//
//
//
//angular.module('gameOnSwiftApp', [])
//.controller('GameOnController ', function(){
//
//            alert("in controller")
//
//            var gameOn = this;
//            gameOn.checked = true;
////            this.checked = false;
////              this.checked = true;
//
//
//            });
