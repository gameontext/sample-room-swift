angular.module('gameOnApp', [])
.controller('GameOnController', function() {
            var gameOn = this;
            
            var websocket = null;
            var websocketUrl = "ws://" + window.document.location.host + "/room";
            
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
            
                };
            }
            
            gameOn.disconnect = function() {
            
            console.log("disconnect %o", websocket);
            console.log("setting connected to false HERE")
            gameOn.connected.value = false;
            if ( websocket !== null ) {
                websocket.close();
            
            }
            }
            
            angular.element(document).ready(function () {
//                                            gameOn.connect();
                                            });
            

            
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
