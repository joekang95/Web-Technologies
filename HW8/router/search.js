var express = require('express');
var router = express.Router();
var path = require('path');
path = path.resolve(__dirname);

router.get("/searchProducts",function(req,res){
    
    const http = require('http');
    var Keyword = req.query.keyword;
    var Category = req.query.category;
    var Condition = JSON.parse(req.query.condition);
    var Shipping = JSON.parse(req.query.shipping);
    var Distance = JSON.parse(req.query.distance);
    var Zipcode = JSON.parse(req.query.zip);
    
    
    var APP_ID = "";
    var url = "http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=" + encodeURIComponent(APP_ID) + "&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=50&keywords="+ encodeURIComponent(Keyword) + "&";
    
    var cat = (Category != 'all') ? "categoryId=" + req.query.category + "&" : "";
    
    var alt = "buyerPostalCode=" + Zipcode + "&itemFilter(0).name=MaxDistance&itemFilter(0).value=" + Distance + "&";
    

    var filter = "itemFilter(1).name=FreeShippingOnly&itemFilter(1).value=" + Shipping.FreeShippingOnly + "&itemFilter(2).name=LocalPickupOnly&itemFilter(2).value=" + Shipping.LocalPickupOnly + "&itemFilter(3).name=HideDuplicateItems&itemFilter(3).value=true";
    
    
    var counter = 0;
    var conditionSet = false;
    
    for(var condition in Condition){
        if(Condition[condition] == true){
            if(!conditionSet){
                filter += "&itemFilter(4).name=Condition";
                conditionSet = true;
            }
            filter += "&itemFilter(4).value(" + counter + ")=" + condition;
            counter++;
        }
    }
    
    filter += "&outputSelector(0)=SellerInfo&outputSelector(1)=StoreInfo";
    
    
    var final = url+cat+alt+filter; 
    
    //console.log(final);
    
    http.get(final, (resp) => {
    let data = '';

    // A chunk of data has been recieved.
    resp.on('data', (chunk) => {
        data += chunk;
    });

    // The whole response has been received. Print out the result.
    resp.on('end', () => {
        var raw = JSON.parse(data)
        var file = [];
        if(raw.findItemsAdvancedResponse[0].ack[0] == 'Success') {
            var itemCount = raw.findItemsAdvancedResponse[0].searchResult[0]['@count'];
            var item = raw.findItemsAdvancedResponse[0].searchResult[0].item;
            var counter = 0;
            //console.log(item[0]);
            if(itemCount != 0){
                for(var i = 0 ; i < item.length ; i++){
                    var items = {};
                    items.index = ++counter;
                    items.itemId = item[i].itemId[0];

                    /*Product Info*/
                    if(item[i].hasOwnProperty("title")){
                        items.title = item[i].title[0];
                        items.short = (item[i].title[0].length > 35) ? 
                            ((item[i].title[0].charAt(34) == ' ') ? 
                                item[i].title[0].substr(0, 34) + "..." :
                                item[i].title[0].substr(0, findSpace(item[i].title[0])) + "...")
                        : item[i].title[0];
                    }
                    else{
                        items.title = "N/A";
                        items.short = "N/A";
                    }
                    
                    if(item[i].hasOwnProperty("galleryURL")){
                        items.galleryURL = item[i].galleryURL[0];
                    }
                    else{
                        items.galleryURL = "N/A";
                    }
                    
                    if(item[i].hasOwnProperty("viewItemURL")){
                        items.itemURL = item[i].viewItemURL[0];
                    }
                    
                    if(item[i].hasOwnProperty("sellingStatus")){
                        items.price = parseFloat(item[i].sellingStatus[0].currentPrice[0].__value__).toFixed(2);
                    }
                    else{
                        items.price = "N/A";
                    }
                    
                    if(item[i].hasOwnProperty("postalCode")){
                        items.zip = item[i].postalCode[0];
                    }
                    else{
                        items.zip = "N/A";
                    }

                    /*Shipping Info*/
                    if(item[i].hasOwnProperty("shippingInfo")){
                        
                        if(item[i].shippingInfo[0].hasOwnProperty("shippingServiceCost")){
                            items.shippingCost = (item[i].shippingInfo[0].shippingServiceCost[0].__value__ == "0.0") ? 
                            "Free Shipping"    
                            : 
                            "$" + parseFloat(item[i].shippingInfo[0].shippingServiceCost[0].__value__).toFixed(2);
                        }
                        else{
                            items.shippingCost = "N/A";
                        }
                        
                        if(item[i].shippingInfo[0].hasOwnProperty("shipToLocations")){
                            items.shippingLocation = item[i].shippingInfo[0].shipToLocations[0];
                        }
                        else{
                            items.shippingLocation = "N/A";
                        }
                        
                        if(item[i].shippingInfo[0].hasOwnProperty("handlingTime")){
                            items.handleTime = item[i].shippingInfo[0].handlingTime[0] + " Day";
                            if(parseInt(item[i].shippingInfo[0].handlingTime[0]) > 1){
                                items.handleTime += "s";
                            }
                        }
                        
                        if(item[i].shippingInfo[0].hasOwnProperty("expeditedShipping")){
                            items.expectedShip = item[i].shippingInfo[0].expeditedShipping[0];
                        }
                        if(item[i].shippingInfo[0].hasOwnProperty("oneDayShippingAvailable")){
                            items.oneDayShip = item[i].shippingInfo[0].oneDayShippingAvailable[0];
                        }
                        if(item[i].hasOwnProperty("returnsAccepted")){
                            items.return = item[i].returnsAccepted[0];
                        }
                    }

                    /*Seller Info*/
                    if(item[i].hasOwnProperty("sellerInfo")){
                        if(item[i].sellerInfo[0].hasOwnProperty("sellerUserName")){
                            items.seller = item[i].sellerInfo[0].sellerUserName[0].toUpperCase();
                        }
                        else{
                            items.seller = "N/A";
                        }
                    }
                    else{
                        items.seller = "N/A";
                    }

                    file.push(items);
                }
            }
            else{
                var error = {};
                error.message = "";
                file.push(error);
            }
        }
        else{
            var error = {};
            error.message = raw.findItemsAdvancedResponse[0].errorMessage[0].error[0].message[0];
            file.push(error);
        }
        res.send(file);
    });
})
    .on("error", (err) => {
        console.log("Error: " + err.message);
    });
    
    function findSpace(string){
        for(var i = 34 ; i >= 0 ; i-- ){
            if(string.charAt(i) == ' '){
                return i;
            }
        }
    }
});

router.get("/searchDetail",function(req,res){
    
    const http = require('http');
    var itemID = req.query.id;
    var APP_ID = "";
    
    var url = "http://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid=" + encodeURIComponent(APP_ID) + "&siteid=0&version=967&ItemID=" + encodeURIComponent(itemID) + "&IncludeSelector=Description,Details,ItemSpecifics"
    
    //console.log(url);
    
    http.get(url, (resp) => {
    let data = '';

    // A chunk of data has been recieved.
    resp.on('data', (chunk) => {
        data += chunk;
    });

    // The whole response has been received. Print out the result.
    resp.on('end', () => {
        var raw = JSON.parse(data)
        if(raw.Ack == 'Success') {
            var item = raw.Item;
            //console.log(item);
            var detail = {};
            if(item.hasOwnProperty("PictureURL")){
                detail.picture = item.PictureURL; 
            }
            if(item.hasOwnProperty("Title")){
                detail.title = item.Title;
            }
            if(item.hasOwnProperty("Subtitle")){
                detail.subtitle = item.Subtitle;
            }
            if(item.hasOwnProperty("ConvertedCurrentPrice")){
                detail.price = parseFloat(item.ConvertedCurrentPrice.Value).toFixed(2);
            }
            if(item.hasOwnProperty("Location")){
                detail.location = item.Location;
            }
            if(item.hasOwnProperty("ReturnPolicy")){
                detail.return = item.ReturnPolicy.ReturnsAccepted;
                if(item.ReturnPolicy.hasOwnProperty("ReturnsWithin")){
                    detail.return += " within " + item.ReturnPolicy.ReturnsWithin;
                }
            }
            if(item.hasOwnProperty("ItemSpecifics")){
                detail.specifics  = item.ItemSpecifics.NameValueList;
            }
            
            /*Seller Info*/
            if(item.hasOwnProperty("Seller")){
                if(item.Seller.hasOwnProperty("UserID")){
                    detail.seller = item.Seller.UserID.toUpperCase();
                }
                if(item.Seller.hasOwnProperty("FeedbackScore")){
                    detail.feedbackScore = item.Seller.FeedbackScore.toString();
                }
                if(item.Seller.hasOwnProperty("PositiveFeedbackPercent")){
                    detail.feedbackPercent = item.Seller.PositiveFeedbackPercent.toString();
                }
                if(item.Seller.hasOwnProperty("FeedbackRatingStar")){
                    detail.feedbackStar = item.Seller.FeedbackRatingStar;
                }
                if(item.Seller.hasOwnProperty("“TopRatedSeller")){
                    detail.topRated = item.Seller.TopRatedSeller;
                }
            }
            if(item.hasOwnProperty("Storefront")){
                if(item.Storefront.hasOwnProperty("StoreName")){
                    detail.storeName = item.Storefront.StoreName;
                }
                if(item.Storefront.hasOwnProperty("StoreURL")){
                    detail.storeURL = item.Storefront.StoreURL;
                }
            }
        }
        res.send(detail);
    });
})
    .on("error", (err) => {
        console.log("Error: " + err.message);
    });
});


router.get("/searchPhotos",function(req,res){
    
    const https = require('https');
    var name = req.query.name;
    var google_key = "";
    var google_cx = "";
    
    var url = "https://www.googleapis.com/customsearch/v1?q="+ encodeURIComponent(name) +"&cx=" + google_cx +"&imgSize=huge&imgType=news&num=8&searchType=image&key=" + google_key;
    

    //console.log(url);
    
    https.get(url, (resp) => {
    let data = '';

    // A chunk of data has been recieved.
    resp.on('data', (chunk) => {
        data += chunk;
    });

    // The whole response has been received. Print out the result.
    resp.on('end', () => {
        
        var result = [];
        var raw = JSON.parse(data);
        if(raw.hasOwnProperty("items")){
            var tmp = JSON.stringify(raw.items);
            tmp = tmp.replace(/"link":/g,'"pictureURL":');
            var items = JSON.parse(tmp);
            //console.log(items);
            if(items.length != 0) {
                for(var i = 0 ; i < items.length ; i++){
                    //console.log(items[i].pictureURL);
                    result.push(items[i].pictureURL);
                }
            }
        }
        else if(raw.hasOwnProperty("error")){
            var error = {};
            error.message = raw.message;
            result.push(error);
        }
        res.send(result);
    });
})
    .on("error", (err) => {
        console.log("Error: " + err.message);
    });
});


router.get("/searchSimilar",function(req,res){
    
    const http = require('http');
    var itemID = req.query.id;
    var APP_ID = "";
    
    var url = "http://svcs.ebay.com/MerchandisingService?OPERATION-NAME=getSimilarItems&SERVICE-NAME=MerchandisingService&SERVICE-VERSION=1.1.0&CONSUMER-ID=" + encodeURIComponent(APP_ID) + "&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&itemId=" + encodeURIComponent(itemID) + "&maxResults=20";
    
    //console.log(url);
    
    http.get(url, (resp) => {
    let data = '';

    // A chunk of data has been recieved.
    resp.on('data', (chunk) => {
        data += chunk;
    });

    // The whole response has been received. Print out the result.
    resp.on('end', () => {
        var raw = JSON.parse(data)
        if(raw.getSimilarItemsResponse.ack == 'Success') {
            var item = raw.getSimilarItemsResponse.itemRecommendations.item;
            var file = [];
            var start = 0;
            var end = 0;
            var counter = 0;
            //console.log(item[0]);
            for(var i = 0 ; i < item.length ; i++) {
                var items = {};
                items.index = ++counter;
                items.itemId = item[i].itemId;
                items.title = item[i].title;
                items.url = item[i].viewItemURL;
                items.imageURL = item[i].imageURL;
                
                items.price = parseFloat(item[i].buyItNowPrice.__value__);
                items.shipping = item[i].shippingCost.__value__;
                for(var j = 0 ; j < item[i].timeLeft.length ; j++){
                    if(item[i].timeLeft.charAt(j) == 'P'){
                        start = j + 1;
                    }
                    if(item[i].timeLeft.charAt(j) == 'D'){
                        end = j;
                        break;
                    }
                }
                items.time = parseInt(item[i].timeLeft.substring(start, end));
                file.push(items);
            }
            res.send(file);
        }
    });
})
    .on("error", (err) => {
        console.log("Error: " + err.message);
    });
});





module.exports = router;