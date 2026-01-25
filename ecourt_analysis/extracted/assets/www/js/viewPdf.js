IN_PROCESS = "false";

$(document).ready(function () {
//TODO:: year match funtionality is remaining
//TODO:: case type in case number field
//     second_header();
//    var viewBusinessData = getParameterByName('data');
    
    $("#header").load("header.html", function (response, status, xhr) {
        
       $("#second_header").css('display','block');
        $('#go_back_link').on('click', function (event) {
            event.preventDefault();
//            window.history.back();
            history.go(-1);
            navigator.app.backHistory();
        });
    });
        var url = getParameterByName('url');
        $.getJSON(url, "").done(function (data) {
//            console.log(data.viewBusiness);
            console.log(data);
             document.getElementById("viewPdfContainerId").innerHTML = data;

        });
       // var viewBusinessVar = dataObj.viewBusiness;
        
       
        
        
        
 });