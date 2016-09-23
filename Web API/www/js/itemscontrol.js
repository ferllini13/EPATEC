(function(){
    var app = angular.module('starter.itemscontrol', [])
        app.factory('ItemsControl', function(){
        var items = [];/*{_id:"-1", nonTaxable: false, _description:"hola", _amount:"10"}*/
        var itemsCart = [];
            return {
                update: function($http) {
                    var ip = "http://webserviceepatec.azurewebsites.net/EPATEC.asmx/Parsear?frase=";
                    var peticion = "listar,productos"
                    var request = "";
                    request = request.concat(ip, peticion);
                    console.log("Request es:", request);
                $http.get(request)
                            .then(function (response) {
                            console.log('Get Post', response);
                            console.log("Get Post status", response.data);
                            var data = response.data;
                            var result = data.substring(70, data.length - 9);
                            console.log("Get Post status", result);
                            var result2 = angular.fromJson(result);
                            console.log("Get Post status 2", result2);                            
                            for(var i in result2) {
                                items.push(result2[i]);
                            }
                    var result3 = items[1]._description;
                            console.log("Result3 ", result3);
                    });
                },
                list: function($http, $scope){
                    return items;
                    
                },
                addCart: function(item){
                    console.log(item);
                    if (!(item._amount > 0)) {
                        alert("There's no more products available");
                    }
                    else {
                        item._amount--;
                        for (var i in itemsCart) {
                            if (itemsCart[i]._id === item._id) {                            
                                itemsCart[i]._amount++;
                                return;
                            }
                        }                  
                        itemsCart.push(item);
                        itemsCart = JSON.parse(JSON.stringify(itemsCart));
                        itemsCart[itemsCart.length -1]._amount = 1;
                    }
                },
                elimCart: function(item){
                    if (!(item._amount > 0)) {
                        alert("There's no more products in your cart");
                    }
                    else {
                        item._amount--;
                        for (var i in items) {
                            if (items[i]._id === item._id) {                            
                                items[i]._amount++;
                            }
                        }
                        for (var i in itemsCart) {
                            if (itemsCart[i]._amount == 0) {
                                //itemsCart.slice(i, 1);
                            }
                        }
                    }
                                   
                },
                listCart: function(){
                    return itemsCart;
                },
                get: function(id){
                    return items.filter(function(item){
                        return item._id === id;
                    })[0];
                },
                getCart: function(id){
                    return itemsCart.filter(function(item){
                        return item._id === id;
                    })[0];
                }
            };
        });
}());