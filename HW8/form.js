'use strict';
var app = angular.module('productSearch', ['ngMaterial', 'ngMessages','ngAnimate', 'angular-svg-round-progressbar']);


app.controller('formControl', function($scope, $http, $timeout, $q, $log) {
    
    var fetchLocalStorage = function(){
        $scope.wishList = [];
        $scope.wishPrice = 0;
        for(var i = 0 ; i < localStorage.length ; i++){
            var item = JSON.parse(localStorage.getItem(localStorage.key(i)));
            item.index = i + 1;
            $scope.wishList.push(item);
            $scope.wishPrice += parseFloat(item.price);
        }
        $scope.wishPrice = $scope.wishPrice.toFixed(2)
    }
    
    var init = function(){
        $http.get('http://ip-api.com/json')
        .then(function(JSONfile){
            $scope.data.zipcode = '';
            if(JSONfile.data.zip){
                $scope.data.zipcode = JSONfile.data.zip;
            }
        });
        $scope.data = { keyword:'', category:'all', selected:'here', distance:'', button1:'btn-dark', button2:'bg-white', zipcodeInput:'' };
        $scope.data.condition = {'New':false, 'Used':false, 'Unspecified':false };
        $scope.data.shipping = {'LocalPickupOnly':false, 'FreeShippingOnly':false };
        $scope.process = { loading:false, complete:false };
        $scope.pill = true;
        $scope.detailGenerated = { result:"", wish:"" };
        $scope.detailGeneratedData = { result:"", wish:"" };
        $scope.process.detailReady = { result:false, wish:false }; 
        $scope.process.show = { result:"result", wish:"wish" };
        $scope.shareLink = { result:"", wish:"" };
        $scope.details = "";
        $scope.detailsWish = "";
        $scope.photos = "";
        $scope.photosWish = "";
        $scope.similar = "";
        $scope.similarWish = "";
        $scope.results = "";
        $scope.photos = "";
        $scope.detailsClick = false; 
        $scope.listsClick = false; 
        $scope.detailsWishClick = false; 
        $scope.listsWishClick = false; 
        $scope.Options = { option:[{ value: "default", label: "Default" }, { value: "title", label: "Product Name" }, { value: "time", label: "Days Left" }, { value: "price", label: "Price" }, { value: "shipping", label: "Shipping Cost" }], order:[{ value: "false", label: "Ascending" }, { value: "true", label: "Descending Name" }] };
        $scope.sort = { option:'', order:'', optionWish:'', orderWish:'' };
        $scope.sort.option = $scope.Options.option[0];
        $scope.sort.order = $scope.Options.order[0];
        $scope.sort.optionWish = $scope.Options.option[0];
        $scope.sort.orderWish = $scope.Options.order[0];
        fetchLocalStorage();
    };
    
    init();
    
    $scope.deleteInput = function(){
        $scope.myForm.ziptext.$setUntouched();
        $scope.searchText = "";
        $scope.data.zipcodeInput = "";
    }
    
    $scope.checkValid = function(keyword, searchText){
        var regex = /^[ \t]+$/;
        var regex2 = /^\d{5}$/;
        if(keyword === undefined){
            return false;
        }
        if(keyword.length == 0){
            return false;
        }
        if(regex.test(keyword)){
            return false;
        }
        if($scope.data.selected == 'zip'){
            if(searchText === undefined){
                return false;
            }
            if(searchText.length == 0){
                return false;
            }
            if(!regex2.test(searchText)){
                return false;
            }
        }
        if($scope.data.zipcode == '' || $scope.data.zipcode == null){
            return false;
        }
        return true;
    }
    
    
    $scope.reset = function(){
        $scope.myForm.$setUntouched();
        $scope.myForm.$setPristine();
        init();
    };
    
    $scope.swap = function(button){
        if(button == 'wish'){ $scope.pill = false; }
        else{ $scope.pill = true; }
    }
    
    $scope.click = function(button){
        $scope.process.loading = true;
        if(button == 'detail'){ $scope.detailsClick = true; }
        else if(button == 'lists'){ $scope.listsClick = true; }
        else if(button == 'detailWish'){ $scope.detailsWishClick = true; }
        else if(button == 'listsWish'){ $scope.listsWishClick = true; }
        $timeout(function (){ 
        $scope.process.loading = false;
        
        }, 800);
        
    }

    $scope.search = function(){
        
        $scope.process.loading = true;
        $scope.process.complete = false; 
        var url = "/searchProducts?keyword=" + encodeURIComponent($scope.data.keyword) + 
                  "&category=" + encodeURIComponent($scope.data.category) + 
                    "&condition=" + encodeURIComponent(JSON.stringify($scope.data.condition)) + 
                    "&shipping=" + encodeURIComponent(JSON.stringify($scope.data.shipping)) + 
                     "&distance=" + (($scope.data.distance == '') ? "10" : encodeURIComponent($scope.data.distance));
        var zip = ($scope.data.zipcodeInput == "") ? encodeURIComponent($scope.data.zipcode) : encodeURIComponent($scope.data.zipcodeInput);
        
        url += "&zip=" + zip;
        //console.log(url);
        if(navigator.onLine){
            $http.get(url)
                .then(function(response){
                    if(!response.data[0].hasOwnProperty("message")){
                        $scope.results = response.data;
                        $scope.pages = Math.ceil($scope.results.length / 10);
                    }
                    else{
                        $scope.results = "";
                        $scope.pages = 0;
                        $scope.error = response.data[0].message;
                    }
                    $scope.begin = 0;
                    
                    $scope.process.loading = false;
                    $scope.process.complete = true; 
                })
            $scope.process.show.result = 'results';
            $scope.detailGenerated.result = "";
            $scope.details = "";
        }     
        $timeout(function() {
            angular.element(document.getElementById('pills-result-tab')).trigger('click');
        })
    }
    
    $scope.addWish = function(data){
        if(!localStorage.getItem(data.itemId)){
            localStorage.setItem(data.itemId,  JSON.stringify(data));
            fetchLocalStorage();
        }
    }
    
    $scope.getWish = function(id){
        if(!localStorage.getItem(id)){
            return "add_shopping_cart";
        }
        else{
            return "remove_shopping_cart";
        }
    }
    
    $scope.removeWish = function(id){
        if(localStorage.getItem(id)){
            localStorage.removeItem(id);
            fetchLocalStorage();
        }
    }
    
    $scope.editWish = function(data){
        if($scope.getWish(data.itemId) == "add_shopping_cart"){
            return $scope.addWish(data);
        }
        else{
            return $scope.removeWish(data.itemId);
        }
    }
    
    $scope.detail = function(data, tab, move){
        $scope.process.loading = true;
        if(move == 'yes'){ $scope.process.complete = false; };
        $scope.detailClicked = true; 
        if(navigator.onLine){
            $http.get('/searchDetail?id=' + encodeURIComponent(data.itemId))
            .then(function(response){
                
                if(tab == 'result') { $scope.details = response.data; }
                else{ $scope.detailsWish = response.data; }
                
                //$scope.photos = ["https://i.ebayimg.com/images/g/5VAAAOSwHWtbyhiP/s-l1600.jpg", "https://pics.four13.co/AU200s/AU235e.jpg", "https://i.ebayimg.com/images/g/kLUAAOSwj8hbnpnA/s-l1600.jpg", "https://xlntfast.com/Ebay%20Images/Nike%20Satin%20Bomber%20Jacket%20ARIZONA%20WILDCATS%20Red%20Navy%20Thermore%20Mens/Nike%20Satin%20Bomber%20Jacket%20ARIZONA%20WILDCATS%20Red%20Navy%20Thermore%20Mens%201.jpg", "https://i.ebayimg.com/images/g/RCcAAOSwu-BWPqt3/s-l1600.jpg", "https://i.pinimg.com/originals/95/ad/da/95adda8d613b5b544604f0fd80ce5636.jpg", "https://i.ebayimg.com/images/g/8KoAAOSw5V5ac8t0/s-l1600.jpg", "https://i.pinimg.com/originals/d8/52/37/d85237797dd26957e3944d3ceb5882d9.jpg"];
                
                $http.get('/searchPhotos?name=' + encodeURIComponent(data.title))
                .then(function(response){
                    if(tab == 'result') { 
                        if(!response.data[0].hasOwnProperty("message")){
                            $scope.photos = response.data;
                        }
                        else{
                            $scope.photos = "";
                        }
                    }
                    else{ 
                        $scope.photosWish = "";
                        if(response.data.length != 0){
                            if(!response.data[0].hasOwnProperty("message")){
                                $scope.photosWish = response.data;
                            }
                            else{ $scope.photosWish = ""; } 
                        }
                    }

                    $http.get('/searchSimilar?id=' + encodeURIComponent(data.itemId))
                    .then(function(response){
                        if(tab == 'result') { $scope.similar = response.data; }
                        else{ $scope.similarWish = response.data; }
                        //console.log(response.data);
                        $scope.process.loading = false; 
                        $scope.process.complete = true; 
                    })
                })
            })
        }      
        if(tab == 'result'){ 
            $scope.process.detailReady.result = true; if(move == 'yes'){ $scope.process.show.result = 'details'; }
            $scope.detailGenerated.result = data.itemId; $scope.detailGeneratedData.result = data; 
            $scope.nav = 1; 
            $timeout(function() {
                angular.element(document.getElementById('product-tab')).trigger('click');
            })     
            $scope.detailsClick = true;
            $scope.listsClick = true;
            $scope.sort.option = $scope.Options.option[0];
            $scope.sort.order = $scope.Options.order[0];
        }
        else{ 
            $scope.process.detailReady.wish = true; if(move == 'yes'){ $scope.process.show.wish = 'details'; }
            $scope.detailGenerated.wish = data.itemId;  $scope.detailGeneratedData.wish = data; 
            $scope.nav2 = 1; 
            $timeout(function() {
                angular.element(document.getElementById('product-tab-wish')).trigger('click');
            })   
            $scope.detailsWishClick = true;
            $scope.listsWishClick = true;
            $scope.sort.optionWish = $scope.Options.option[0];
            $scope.sort.orderWish = $scope.Options.order[0];
        }
        $scope.itemIndex = data.index - 1;  
        $scope.similarLimit = 5;
        $scope.showText = "Show More";
        $scope.similarLimitWish = 5;
        $scope.showTextWish = "Show More";
        $scope.shareLink.result = "https://www.facebook.com/dialog/share?app_id=XXXXXX&display=popup&href=" + data.itemURL + "&quote=" + encodeURI("Buy " + data.title + " at $" + data.price + " from link below");
    }
    
    $scope.page = function(num) {
        $scope.begin = num * 10;
    }
    
    $scope.prev = function() {
        var current = $scope.begin / 10;
        if(current - 1 >= 0){ $scope.page(current - 1); $scope.first = false; }
        else{ $scope.first = true; }
    }
    
    $scope.next = function() {
        var current = $scope.begin / 10;
        if(current + 1 < $scope.pages){ $scope.page(current + 1); $scope.last = false; }
        else{ $scope.last = true; }
    }
    
    $scope.checkRating = function(rating){
        if(typeof rating != undefined){
            if(rating.includes("Shooting")){ return true; }
            else{ return false; }
        }
    }
    
    $scope.select = function(index, tab){
        if(tab == 'result'){ $scope.nav = index; }
        else{ $scope.nav2 = index; }
    }
    
    $scope.show = function(show){
        if(show == "Show More"){ 
            $scope.similarLimit = 20;  
            $scope.showText = "Show Less";
        }
        else{ 
            $scope.similarLimit = 5; 
            $scope.showText = "Show More";
        }
    }
    
    $scope.showWish = function(show){
        if(show == "Show More"){ 
            $scope.similarLimit = 20;  
            $scope.showTextWish = "Show Less";
        }
        else{ 
            $scope.similarLimit = 5; 
            $scope.showTextWish = "Show More";
        }
    }
    
    $scope.isEmpty = function(){
        if(localStorage.length === 0){ return true; }
        else{ return false; }
    }
    
    $scope.isInteger = function(price){
        if(Number.isInteger(price)){ return true; }
        else{ return false; }
    }
    
    
    
    /*Autocomplete*/
    
    $scope.simulateQuery = false;
    $scope.isDisabled    = false;
    $scope.querySearch   = querySearch;
    
    function querySearch (query) {
        
            $scope.data.zipcodeInput = query;
        
            var results =  $http.post('/location?zip=' + query).then(function(response){
                var autodata = response.data;
                
                var states = "";
                autodata.forEach(function(item) {
                    states += item +", ";
                });
                
                states = states.substring(0, states.length - 2);  
                $scope.states = loadStates(states);
                
                if($scope.states !== undefined) {
                    var final = query ? $scope.states.filter(createFilterFor(query)) :
                    $scope.states, deferred;
                    if ($scope.simulateQuery) {
                        deferred = $q.defer();
                        $timeout(function () { deferred.resolve(results); }, Math.random() * 1000, false);
                        return deferred.promise;
                    } else {
                        return final;
                    }
                }
            });
            return results;
    }
    
    function loadStates(states) {
        return states.split(/, +/g).map( function (state) {
            return {
                value: state.toLowerCase(),
                display: state
            };
        });
    }

   function createFilterFor(query) {
      var lowercaseQuery = query.toLowerCase();

      return function filterFn(state) {
            return (state.value.indexOf(lowercaseQuery) === 0);
      };
   }
    
});
