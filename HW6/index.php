<!DOCTYPE html>
<html>
<head>
    <title>Product Search</title>
    <meta name="author" content="Joe Chang">
    
    <style>
        html, body{
            margin: 0;
        }
        .title{
            font-weight: lighter;
            border-bottom: 1px solid lightgrey;
            text-align: center;
            font-size: 28px;
            margin: 0px 10px 0px 10px;
            padding: 5px 0px 10px 0px;
        }
        .main{
            width:600px;
            height:200px;
            border: 4px solid lightgrey;
            text-align: center;
            margin: 40px auto;
            margin-bottom: 20px;
            background-color: whitesmoke;
            padding-bottom: 80px;
        }
        form{
            text-align: left;
            line-height: 30px;
            margin: 5px 17px 0px 17px;
        }
        .condition input[type=checkbox]{
            margin-left: 21px;
        }
        .shipping input[type=checkbox]{
            margin-left: 60px;
        }
        input[type=radio] {
            vertical-align
        }
        .button{
            margin-left: 208px;
        }
        td a{
            cursor: pointer;
        }
        td a:hover{
            color: gray;
        }
        #sellerArrow, #similarArrow{
            text-align: center;
            line-height: 30px;
            cursor: pointer;
            width: 200px;
            margin: auto;
        }
        h1{
            text-align: center;
            margin-bottom: 0;
        }
        table{
            border-collapse: collapse;
        }
        table, td, th{  
            border: 3px solid lightgrey;
        }
        .nearby table, .nearby td, .nearby th{
            vertical-align: top;
            display: inline-block;
            border: none;            
        }
        
        #seller table, #seller th{  
            border: none;
        }
        #seller{
            margin: auto;
            border: none;
            width: 1200px;
        }
        #detailTable{
            margin: auto;
        }
        #detailTable th, #detailTable td{
            padding-left: 10px;
            padding-right: 10px;
        }
        iframe{
            display: block;
            margin: auto;
            border: none;
            width: 1000px; 
            overflow: hidden;
        }
        #similar{
            margin: auto;
            border: 3px solid lightgrey;
            width: 800px; 
            height: 320px;
            overflow-x: auto;
            overflow-y: hidden;
            white-space: nowrap;
            display: none;
        }
        #similar a{
            cursor: pointer;
        }
        #similar a:hover{
            color: gray;
        }
    </style>
    
    <script type="text/javascript">
        function enableLocation(){
            var checkBox = document.getElementById("enable");
            if(checkBox.checked == true){
                document.getElementById("here").disabled = false;
                document.getElementById("distance").disabled = false;
                document.getElementById("zip").disabled = false;
                document.getElementById("miles").style.color = "#000000";
                document.getElementById("heretext").style.color = "#000000";
                document.getElementById("hereZIP").disabled = false;
            }
            else{
                disableLocation();
            }
        }
        
        function init(){
            // When page loads, obtain user location
            var xmlhttp;
            document.getElementById("search").disabled = true;
            var url = "http://ip-api.com/json";
            if (window.XMLHttpRequest){
                // code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp = new XMLHttpRequest();
            } 
            else{
                // code for IE6, IE5
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); 
            }
            xmlhttp.open("GET", url, false);
            xmlhttp.send();
            if(xmlhttp.readyState == 4 && xmlhttp.status == 200){
                var jsonFile = JSON.parse(xmlhttp.responseText);
                document.getElementById("hereZIP").value = jsonFile.zip;
            }
            enableLocation();
            ZIP();
            document.getElementById("search").disabled = false;
        }
        
        function disableLocation(){
            document.getElementById("distance").disabled = true;
            document.getElementById("here").disabled = true;
            document.getElementById("zip").disabled = true;
            document.getElementById("ziptext").disabled = true;
            document.getElementById("miles").style.color = "#969696";
            document.getElementById("heretext").style.color = "#969696";
            document.getElementById("hereZIP").disabled = true;
            document.getElementById("distance").value = "";
            document.getElementById("ziptext").value = "";
        }
        
        function ZIP(){
            var hereButton = document.getElementById("here");
            if(hereButton.checked){
                document.getElementById("ziptext").disabled = true;
                document.getElementById("ziptext").value = "";
            }
            else{
                document.getElementById("ziptext").disabled = false;
            }
        }
        
        function clearAll(){
            disableLocation();
            document.getElementById("tableResult").innerHTML = "";
            document.getElementById("detail").innerHTML = "";
            document.getElementById("sellerArrow").innerHTML = "";
            document.getElementById("seller").innerHTML = "";
            document.getElementById("similarArrow").innerHTML = "";
            document.getElementById("similar").innerHTML = "";
        }
    </script>
</head>
    
<body onload="init()">
<div class="main">
    <div class="title"> 
        <i>Product Search</i>
    </div>
    
    <form method="POST" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>" id="mainForm">
        <b style="margin-right: 5px;">Keyword</b>
        <input type="text" name="keyword" id="keyword" required>
        <br>
        <b style="margin-right: 5px;">Category</b>
        <select name="category" id="category">
            <option value="all" selected>All categories</option>
            <option value="550">Art</option>
            <option value="2984">Baby</option>
            <option value="267">Books</option>
            <option value="11450">Clothing, Shoes &amp; Accessories</option>
            <option value="58058">Computers/Tablets &amp; Networking</option>
            <option value="26395">Health &amp; Beauty</option>
            <option value="11233">Music</option>
            <option value="1249">Video Games &amp; Consoles</option>
        </select>
        <br>
        
        <div class="condition">
            <b style="margin-right: 0px;">Condition</b>
            <input type="checkbox" name="condition[]" value="New" id="New"><label>New</label>
            <input type="checkbox" name="condition[]" value="Used" id="Used"><label>Used</label>
            <input type="checkbox" name="condition[]" value="Unspecified" id="Unspecified"><label>Unspecified</label>
        </div>
                
        <div class="shipping">
            <b style="margin-right: -20px;">Shipping Options</b>
            <input type="checkbox" name="shipping[]" value="LocalPickupOnly" id="LocalPickupOnly"><label>Local Pickup</label>
            <input type="checkbox" name="shipping[]" value="FreeShippingOnly" id="FreeShippingOnly"><label>Free Shipping</label>
        </div>
        
        <div class="nearby">
            <input type="checkbox" name="enable" value="enable" id="enable" style="margin-left: 0;" onclick="enableLocation()">
            <label style="margin-right: 30px;"><b>Enable Nearby Search</b></label>
            <input type="text" name="distance" placeholder="10" id="distance" size="4" >
            <label style="margin-left: 8px;" id="miles"><b>miles from</b></label>
            <table>
                <tr><td>
                    <input type="radio" name="nearby" value="here" id="here" onclick="ZIP()" checked>
                    <label id="heretext">Here</label>
                </td></tr>
                <tr><td>
                    <input type="radio" name="nearby" value="zip" id="zip" onclick="ZIP()">
                    <input type="text" name="zipcode" placeholder="zip code" id="ziptext" maxlength="5" size="15" required>
                </td></tr>
            </table>
        </div>
        
        <div class="button">
            <input type="submit" name="search" value="Search" id="search">
            <input type="reset" value="Clear" id="reset" onclick="clearAll()">
        </div>
        
        <input type="hidden" name="hereZIP" id="hereZIP" disabled>
        <input type="hidden" name="detailID" id="detailID">
    </form>
</div>
<div class="result">
    <p id="tableResult" >
    <p id="detail"></p>
    <p id="sellerArrow"></p>
    <p id="seller"></p>
    <p id="similarArrow"></p>
    <p id="similar"></p>
    <p id="test"></p>
</div>
 
<?php
    $itemcount = "";
    $Keyword = $Category = $Condition = $Shipping = "";
    $Enable = $Distance = $Nearby = $ZIP = $extractedJSON = "";
    // When requested
    if($_SERVER['REQUEST_METHOD'] == "POST"){
        $invalidZIP = false;
        $Keyword = $_POST["keyword"];
        $Category = $_POST["category"];
        $Condition = isset($_POST["condition"]) ? $_POST["condition"] : "";
        $Shipping = isset($_POST["shipping"]) ? $_POST["shipping"] : "";
        $Enable = isset($_POST["enable"]) ? $_POST["enable"] : "";
        $Distance = isset($_POST["distance"]) ? ($_POST["distance"] != "" ? $_POST["distance"] : 10) : 10;
        $Nearby = isset($_POST["nearby"]) ? $_POST["nearby"] : "";
        $ZIP = isset($_POST["zipcode"])? $_POST["zipcode"] : (isset($_POST["hereZIP"]) ? $_POST["hereZIP"] : "");
        $APP_ID = "";
        if($_POST["detailID"] == ""){
            $url = "http://svcs.ebay.com/services/search/FindingService/v1?". 
                    "OPERATION-NAME=findItemsAdvanced&".
                    "SERVICE-VERSION=1.0.0&". 
                    "SECURITY-APPNAME=".urlencode($APP_ID)."&".
                    "RESPONSE-DATA-FORMAT=JSON&".
                    "REST-PAYLOAD&paginationInput.entriesPerPage=20&".
                    "keywords=".urlencode($Keyword)."&";

            $cat = ($Category != "all") ? "categoryId=".$Category."&" : "";

            $alt = ($Enable != "") ? 
                    "buyerPostalCode=".urlencode($ZIP)."&".
                    "itemFilter(0).name=MaxDistance&itemFilter(0).value=".urlencode($Distance)."&".
                    "itemFilter(1).name=HideDuplicateItems&itemFilter(1).value=true"
                    : 
                    "itemFilter(0).name=HideDuplicateItems&itemFilter(0).value=true";

            $index = ($Enable != "") ? 2 : 1;
            $filter = "&";
            $itemFilters = new stdClass();
            if($Shipping != ""){
                $itemFilters->FreeShippingOnly = in_array("FreeShippingOnly", $Shipping) ? "true" : "false";
                $itemFilters->LocalPickupOnly = in_array("LocalPickupOnly", $Shipping) ? "true" : "false";
                $filter = $filter."itemFilter(".$index.").name=FreeShippingOnly&itemFilter(".$index.").value=".$itemFilters->FreeShippingOnly."&";
                $filter = $filter."itemFilter(".($index + 1).").name=LocalPickupOnly&itemFilter(".($index + 1).").value=".$itemFilters->LocalPickupOnly."&";
            }
            $index = $Shipping == "" ? 0 : $index += 2;
            if($Condition != ""){
                $itemFilters->Condition = $Condition;
                for($i = 0 ; $i < count($Condition) ; $i++){
                    if($i == 0){
                        $filter = $filter."itemFilter(".$index.").name=Condition&";
                    }
                    $filter = $filter."itemFilter(".$index.").value(".$i.")=".$Condition[$i];
                    if($i != count($Condition) - 1){
                         $filter = $filter."&";
                    }
                }
            }

            if($ZIP != "" && !preg_match("/\d{5}/", $ZIP)){ 
                $errorMessage = "Zipcode is invalid";
            }
            else if($Distance > 3000){
                $errorMessage = "Distance is invalid. Please enter a distance <= 3000";
            }
            else{
                $rawJSON = file_get_contents($url.$cat.$alt.$filter);
                $eBayJSON = json_decode($rawJSON, true);
                if($eBayJSON["findItemsAdvancedResponse"][0]["ack"][0] == "Failure"){
                    $errorMessage = $eBayJSON["findItemsAdvancedResponse"][0]["errorMessage"][0]["error"][0]["message"][0];
                }
                else{
                    $itemcount = $eBayJSON["findItemsAdvancedResponse"][0]["searchResult"][0]["@count"];
                    if($itemcount != "0"){
                        $items = $eBayJSON["findItemsAdvancedResponse"][0]["searchResult"][0]["item"];
                        $newJSON = new stdClass();
                        $newJSON->numbers = count($items);
                        for($i = 1; $i <= $itemcount; $i++){
                            foreach($items[$i - 1] as $key => $value){
                                if($key == "title"){
                                    $newJSON->names[$i] = $value[0];
                                }
                                elseif($key == "itemId"){
                                    $newJSON->itemIds[$i] = $value[0];
                                }
                                elseif($key == "galleryURL"){
                                    $newJSON->photos[$i] = $value[0];
                                }
                                elseif($key == "postalCode"){
                                    $newJSON->zipcodes[$i] = $value[0];
                                }
                                elseif($key == "sellingStatus"){
                                    $newJSON->prices[$i] = $value[0]["currentPrice"][0]["__value__"];
                                }
                                elseif($key == "shippingInfo"){
                                    if(array_key_exists("shippingServiceCost", $value[0])){
                                        $newJSON->shipoptions[$i] = 
                                        $value[0]["shippingServiceCost"][0]["__value__"] == "0.0" ?
                                        "Free Shipping":
                                        "$".$value[0]["shippingServiceCost"][0]["__value__"];
                                    }
                                }
                                elseif($key == "condition"){
                                    $newJSON->conditions[$i] = $value[0]["conditionDisplayName"][0];
                                }
                            }
                        }
                    }
                }
            }
            $extractedJSON = json_encode(isset($newJSON) ? $newJSON : "");
        }
        else{
            $ITEM_ID = $_POST["detailID"];
            $url = "http://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON".
                    "&appid=".urlencode($APP_ID)."&siteid=0&version=967&ItemID=".urlencode($ITEM_ID).
                    "&IncludeSelector=Description,Details,ItemSpecifics";
            $rawJSON = file_get_contents($url);
            file_put_contents("detailJSON.json", $rawJSON);
            
            $url = "http://svcs.ebay.com/MerchandisingService?OPERATION-NAME=getSimilarItems&SERVICE-NAME=MerchandisingService&SERVICE-VERSION=1.1.0&CONSUMER-ID=".urlencode($APP_ID)."&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&itemId=".urlencode($ITEM_ID)."&maxResults=8";
            $rawJSON = file_get_contents($url);
            file_put_contents("similarJSON.json", $rawJSON);
        }
    }
?>   
    
        
<script>

    function loadJSON(file){
        var xmlhttp;
        if(window.XMLHttpRequest){
            // code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
        } 
        else{
            // code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); 
        }
        xmlhttp.open("GET", file, false);
        xmlhttp.send();
        try{
            var jsonFile = JSON.parse(xmlhttp.responseText);
            return jsonFile;
        }
        catch{
            alert("File Not Found");
        }    
    }
        
    function generateTable(){
        <?php
            if($_POST["detailID"] == ""){
                if($itemcount != "0" && $itemcount != ""){
        ?>
                    html_text = "<table id='resultTable' align='center' style='max-width: 1000px;'>";
                    html_text += "<thead>" + "<tr>"; 
                    html_text += "<th>Index</th>";
                    html_text += "<th>Photo</th>";
                    html_text += "<th>Name</th>";
                    html_text += "<th>Price</th>";
                    html_text += "<th>Zip code</th>";
                    html_text += "<th>Condition</th>";
                    html_text += "<th>Shipping Option</th>";
                    html_text += "</tr>" + "</thead>";
                    html_text += "<tbody>";
                    generateBody();
                    html_text += "</tbody>";
                    html_text += "</table>";
        <?php
                }
                elseif(isset($errorMessage)){
        ?>
                    html_text = "<table width=800 style='margin: 30px auto; background-color: whitesmoke; border: 2px solid lightgrey;'>";
                    html_text += "<thead>" + "<tr>";
                    html_text += "<th><?php echo $errorMessage;?></th>";
                    html_text += "</tr>" + "</thead>";
                    html_text += "</table>";
        <?php
                }
                elseif($itemcount == "0"){
        ?>
                    html_text = "<table width=800 style='margin: 30px auto; background-color: whitesmoke; border: 2px solid lightgrey;'>";
                    html_text += "<thead>" + "<tr>";
                    html_text += "<th>No Records has been found</th>";
                    html_text += "</tr>" + "</thead>";
                    html_text += "</table>";
        <?php 
                }
        ?>  
                document.getElementById("tableResult").innerHTML = html_text;
        <?php      
            }
            else{
        ?>
                generateDetail();
        <?php         
            }
        ?>  
    }    
    
    function generateBody(){
        var rawFile = JSON.stringify(<?php echo ($extractedJSON != "") ? $extractedJSON : "\"\""; ?>);
        var jsonFile = JSON.parse(rawFile);
        var numbers = jsonFile.numbers;
        var ids = jsonFile.itemIds;
        var names = jsonFile.names;
        var prices = jsonFile.prices;
        var shipoptions = jsonFile.shipoptions;
        var photos = jsonFile.photos;
        var zipcodes = jsonFile.zipcodes;
        var conditions = jsonFile.conditions;
        for(var i = 1 ; i <= numbers ; i++){
            html_text += "<tr>"; 
            html_text += "<td>" + i + "</td>";
            
            if(typeof names === 'undefined'){ html_text += "<td>N/A</td>";}
            else{ html_text += "<td><img src='" + (photos.hasOwnProperty(i) ? photos[i] : "N/A" ) + "' max-height=80px max-width=80px></td>"; }
            
            if(typeof names === 'undefined'){ html_text += "<td>N/A</td>";}
            else{ html_text += "<td><a onclick=obtainDetail('" + ids[i] + "')>" + (names.hasOwnProperty(i) ? names[i] : "N/A" ) + "</a></td>"; }
            
            if(typeof prices === 'undefined'){ html_text += "<td>N/A</td>";}
            else{ html_text += "<td>$" + (prices.hasOwnProperty(i) ? prices[i] : "N/A" ) + "</td>"; }
            
            if(typeof zipcodes === 'undefined'){ html_text += "<td>N/A</td>"; }
            else{ html_text += "<td>" + (zipcodes.hasOwnProperty(i) ? zipcodes[i] : "N/A" ) + "</td>"; }
            
            if(typeof conditions === 'undefined'){ html_text += "<td>N/A</td>"; }
            else{ html_text += "<td>" + (conditions.hasOwnProperty(i) ? (conditions[i] == "New" ? "Brand " + conditions[i] : conditions[i]): "N/A" ) + "</td>"; }
            
            if(typeof shipoptions === 'undefined'){ html_text += "<td>N/A</td>"; }
            else{ html_text += "<td>" + (shipoptions.hasOwnProperty(i) ? shipoptions[i] : "N/A" ) + "</td>"; }
            
            html_text += "</tr>"; 
        }
    }
    
    <?php
        if($_SERVER['REQUEST_METHOD'] == "POST"){
    ?>  
            document.getElementById("search").disabled = true;
            generateTable();
            resetInput();
            //document.getElementById("search").disabled = false;
    <?php
        }
    ?>
    
    function obtainDetail(index){
        document.getElementById("tableResult").innerHTML = "";
        document.getElementById("detailID").value = index;
        document.getElementById("mainForm").submit();
    }
    
    function generateDetail(){
        detailJSON = loadJSON("detailJSON.json");
        detailFile = detailJSON.Item;
        
        var detail_text = "<h1>Item Details</h1>"
        if(detailJSON.Ack == "Success"){
            detail_text += "<table id='detailTable' align='center' style='margin: auto; text-align: left; max-width: 1000px;'>";

            if(detailFile.hasOwnProperty("PictureURL")){
                detail_text += "<tr>"; 
                detail_text += "<th>Photo</th><td>"; 
                detail_text += "<img src='" + detailFile.PictureURL[0] + "'width='200px'>"; 
                detail_text += "</td></tr>";
            }
            if(detailFile.hasOwnProperty("Title")){
                detail_text += "<tr>"; 
                detail_text += "<th>Title</th>"; 
                detail_text += "<td>" + detailFile.Title + "</td>"; 
                detail_text += "</tr>";
            }
            if(detailFile.hasOwnProperty("Subtitle")){
                detail_text += "<tr>"; 
                detail_text += "<th>Subtitle</th>"; 
                detail_text += "<td>" + detailFile.Subtitle + "</td>"; 
                detail_text += "</tr>";
            }
            if(detailFile.hasOwnProperty("ConvertedCurrentPrice")){
                detail_text += "<tr>"; 
                detail_text += "<th>Price</th>"; 
                detail_text += "<td>" + detailFile.ConvertedCurrentPrice.Value + " " + detailFile.ConvertedCurrentPrice.CurrencyID + "</td>"; 
                detail_text += "</tr>";
            }
            if(detailFile.hasOwnProperty("Location")){
                detail_text += "<tr>"; 
                detail_text += "<th>Location</th>"; 
                detail_text += "<td>" + detailFile.Location;
                if(detailFile.hasOwnProperty("PostalCode")){detail_text += " ," + detailFile.PostalCode;}
                detail_text += "</td></tr>";
            }
            if(detailFile.hasOwnProperty("Seller")){
                detail_text += "<tr>"; 
                detail_text += "<th>Seller</th>"; 
                detail_text += "<td>" + detailFile.Seller.UserID + "</td>"; 
                detail_text += "</tr>";
            }
            if(detailFile.hasOwnProperty("ReturnPolicy")){
                detail_text += "<tr>"; 
                detail_text += "<th>ReturnPolicy(US)</th>"; 
                detail_text += "<td>" + detailFile.ReturnPolicy.ReturnsAccepted;
                if(detailFile.ReturnPolicy.hasOwnProperty("ReturnsWithin")){detail_text += " within " + detailFile.ReturnPolicy.ReturnsWithin;}
                detail_text += "</td></tr>";
            }
            if(detailFile.hasOwnProperty("ItemSpecifics")){
                var NameValueList = detailFile.ItemSpecifics.NameValueList;
                for(var i in NameValueList){
                    detail_text += "<tr><th>"; 
                    detail_text += NameValueList[i].Name; 
                    detail_text += "</th><td>"; 
                    if(NameValueList[i].Name == "Features"){
                        detail_text += NameValueList[i].Value[0]; 
                    }
                    else{
                        detail_text += NameValueList[i].Value; 
                    }
                    detail_text += "</tr>";
                }
            }
        }
        else{
            detail_text += "<table width=800 style='margin: 30px auto; background-color: lightgrey;'>";
            detail_text += "<thead>" + "<tr>";
            detail_text += "<th>No Detail Info From Seller or " + detailJSON.Errors[0].LongMessage + "</th>";
            detail_text += "</tr>" + "</thead>";
            detail_text += "</table>";
        }
        
        hide(1);
        generateMessage();
        hide(2);
        document.getElementById("detail").innerHTML = detail_text;
    }
    
    function generateMessage(){
        if(detailJSON.Ack == "Success"){
            if(detailFile.hasOwnProperty("Description")){
                var frame = "<iframe scrolling='no'  id='messageFrame'><p>Your browser does not support iframes.</p></iframe>";
                document.getElementById("seller").innerHTML = frame;
                document.getElementById("messageFrame").srcdoc = detailFile.Description;
                document.getElementById("seller").style.display = "none";
                noMessage = false;
            }
        }
        else{
            var message = "<table width=800 style='margin: 30px auto; background-color: lightgrey;'>";
            message += "<thead>" + "<tr>";
            message += "<th>No Seller Message Found.</th>";
            message += "</tr>" + "</thead>";
            message += "</table>";
            document.getElementById("seller").innerHTML = message;
            document.getElementById("seller").style.display = "none";
            noMessage = true;
        }
    }
    
    function generateSimilar(){
        var similarJSON = loadJSON("similarJSON.json");
        var similarFile = similarJSON.getSimilarItemsResponse.itemRecommendations.item;
        var similar_text = "";
        var content = document.getElementById("similar");
        if(similarFile.length != 0){
            for(var i in similarFile){
                similar_text += "<div style='white-space: normal; display: inline-block; width: 200px; text-align: center; margin: 10px 10px 10px 10px;'>";
                if(similarFile[i].hasOwnProperty("imageURL")){
                    similar_text += "<img src='" + similarFile[i].imageURL + "'max-height=200px max-width=200px><br><br>"; 
                }
                if(similarFile[i].hasOwnProperty("title")){
                    similar_text += "<a onclick=obtainDetail('" + similarFile[i].itemId + "')>" + similarFile[i].title + "</a><br><br>"; 
                } 
                if(similarFile[i].hasOwnProperty("buyItNowPrice") && similarFile[i].buyItNowPrice.hasOwnProperty("__value__")){
                    similar_text += "<b>$" + similarFile[i].buyItNowPrice.__value__ + "</b>"; 
                } 
                similar_text += "</div>";      
            }
        }
        else{
            content.style.border = "none";
            content.style.width = "800px";
            content.style.height = "auto";
            similar_text += "<div style='border: 1px solid lightgrey; text-align: center;'>";
            similar_text += "<div style='border: 1px solid lightgrey; width: 780px; margin: 10px 10px 10px 10px; padding-right: 7px;'><b>No Similar Item Found.</b></div>";
            similar_text += "</div>";
        }
        
        content.innerHTML = similar_text;
        content.style.display = "block";
    }
    
    function show(index){
        var arrow = "click to hide " + ((index == 1) ? "seller message" : "similar items") + "<br>";
        arrow += "<img src='http://csci571.com/hw/hw6/images/arrow_up.png' height='20px'>";
        var target = document.getElementById(((index == 1) ? "sellerArrow" : "similarArrow"));
        target.innerHTML = arrow;
        target.onclick = function() {hide(index)};
        if(index == 1 && !noMessage){
            var content = document.getElementById("seller");
            content.style.display = "block";
            autoResize();
        }
        else if(index == 1 && noMessage){
            var content = document.getElementById("seller");
            content.style.display = "block";
        }
        else if(index == 2){
            generateSimilar(index);
        }
        hide((index == 1) ? 2 : 1);
    }
    
    function hide(index){
        var arrow = "click to show " + ((index == 1) ? "seller message" : "similar items") + "<br>";
        arrow += "<img src='http://csci571.com/hw/hw6/images/arrow_down.png' height='20px'>";
        var target = document.getElementById(((index == 1) ? "sellerArrow" : "similarArrow"));
        target.innerHTML = arrow;
        target.onclick = function() {show(index)};
        var content = document.getElementById(((index == 1) ? "seller" : "similar"));
        content.style.display = "none";
    }
    
    function autoResize(){
        //var x = document.getElementById("seller").children[0];
        var x = document.getElementById("messageFrame");
        var y = (x.contentWindow || x.contentDocument);
        if (y.document)y = y.document;
        var body = y.body, html = y.documentElement;
        var height = Math.max( body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight );
        var iframeHeight = height + 10;
        x.height = iframeHeight;
    } 
    
    function resetInput(){
        document.getElementById("keyword").value = "<?php echo $Keyword?>";
        document.getElementById("category").value = "<?php echo $Category?>";
        <?php
            if($Condition != ""){
                foreach($Condition as $c){
        ?>
                    document.getElementById("<?php echo $c?>").checked = true;
        <?php
                }
            }
        ?>
        <?php
            if($Shipping != ""){
                foreach($Shipping as $s){
        ?>
                    document.getElementById("<?php echo $s?>").checked = true;
        <?php
                }
            }
        ?>
        if("<?php echo $Enable?>" == "enable"){
            document.getElementById("enable").checked = true;
            document.getElementById("distance").value = "<?php echo $Distance?>";
            document.getElementById("<?php echo $Nearby?>").checked = true;
            if("<?php echo $Nearby?>" == "zip"){
                document.getElementById("ziptext").value = "<?php echo $ZIP?>";
            }
        }
        else{
            document.getElementById("distance").value = "";
        }
    }
</script>
</body>
</html>