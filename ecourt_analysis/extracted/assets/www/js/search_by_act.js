
var selectActLabel = "Search Act";
var selectActTypeLabel = "Select Act Type";
var selectUndersectionLabel = "Under Section";

$(document).ready(function () {
    second_header();
    backButtonHistory.push("searchcasepage");
    sessionStorage.setItem("tab", "#profile");
    populateCourtComplexes();        
    var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
    if(labelsarr){       
            $("#casestatus_heading1_label").html(labelsarr[11]);
            $("#search_by_act_label").html(labelsarr[461]);
            $("#court_complex_label").html(labelsarr[269]);
            $("#search_act_label").html(labelsarr[462]);
            $("#searchButton").html(labelsarr[59]);
            $("#act_type_label").html(labelsarr[464]);
            $("#under_section_label").html(labelsarr[80]);
            $("#goButton").html(labelsarr[26]);
            $("#resetButton").html(labelsarr[57]);
            document.getElementById("rad1").innerHTML=(labelsarr[31]);
            document.getElementById("rad2").innerHTML=(labelsarr[21]);
            selectActLabel = labelsarr[462];
            $('#search_act').attr('placeholder',selectActLabel);
            $("#act_type option[value = '']").text(labelsarr[465]);
            selectActTypeLabel = labelsarr[465];
            selectUndersectionLabel = labelsarr[80];
            $('#under_section').attr('placeholder',selectUndersectionLabel);
    }
    $('#act_type').empty();
    $('#act_type').append('<option id="" value="">'+selectActTypeLabel+'</option>');
    if (window.localStorage.SESSION_COURT_CODE != null) {
        // $("#searchButton").click();
        populateActTypes();
    }
    $('#court_code').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();     
        // window.sessionStorage.removeItem("SESSION_SELECT_2");
        if ($('#court_code').val() != "") {
            window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
            window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));
        }else {
            window.localStorage.removeItem("SESSION_COURT_CODE");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
        }
        populateActTypes();  
        $("#Causelist_pannel").trigger("courtCodeChanged");      
    });

    $('input[type=radio][name=radOpt1]').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();     
    });

    $('#act_type').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();     

    });
    // window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_act.html");
    
    $("#under_section").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
    });


    //validations
    $("#search_act").on('keydown', function () {
        if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();       
        }
        var pat = /^[0-9a-zA-Z- ]*$/;
        if(localStorage.LANGUAGE_FLAG=="english"){
        // if(bilingual_flag == "1"){ 
            if (pat.test($(this).val()) == false) {
                $(".search_act").html(labelsarr[762]).show().fadeOut("slow");
                $("#search_act").val("");
                $("#search_act").focus(); 
                return false;
            }
        }else{
            var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
            if(format.test($(this).val())){            
                $(".search_act").html(labelsarr[762]).show().fadeOut("slow"); 
                $("#search_act").val("");
                $("#search_act").focus();   
                return false;
            }            
        } 
    });    

    $("#under_section").on('keydown', function () {
        if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();       
        } 
        var pat = /^[0-9a-zA-Z- ]*$/;
        if (pat.test($(this).val()) == false) {
            $(".under_section").html(labelsarr[762]).show().fadeOut("slow");
            $("#under_section").val("");
            $("#under_section").focus(); 
            return false;
        }
    });

});

//clear form
$("#resetButton").click(function (e) {
    e.preventDefault();
    window.localStorage.removeItem('SESSION_COURT_CODE');
    window.sessionStorage.removeItem('SET_RESULT');
    $('#court_code').val("");
    $('#act_type').empty();
    $('#act_type').append('<option id="" value="">'+selectActTypeLabel+'</option>');
    $("#search_act").val("");
    $("#under_section").val("");
    var $radios = $('input[name=radOpt1]');
    $radios.filter('[value=Pending]').prop('checked', true);  
    $("#accordion_search").empty();
    $("#headers").empty();     
    $("#Causelist_pannel").trigger("courtCodeChanged");      
});

//fill session variables and fetch data.
$("#goButton").click(function (e) {
    e.preventDefault();        
    if(window.sessionStorage.SET_RESULT == null){
        return populateCasesTable();
    }
});


function populateActTypes(){ 
    
    if(window.localStorage.SESSION_COURT_CODE){
        if(window.localStorage.SESSION_COURT_CODE==null){
            showErrorMessage(labelsarr[277]);       
            return false;
        }
    }else{
        showErrorMessage(labelsarr[277]);       
        return false;
    }
    $('#act_type').empty();
    var actWebServiceUrl = hostIP + "actWebService.php";

    var state_code_data = window.localStorage.state_code;
    var district_code_data = window.localStorage.district_code;
    var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

    var court_code_data = courtCodesArr[0];
    var searchText = $("#search_act").val();
    //validation
    if(searchText){
    var pat = /^[0-9a-zA-Z- ]*$/;
        if(localStorage.LANGUAGE_FLAG=="english"){ 
        // if(bilingual_flag == "1"){ 
            if (pat.test(searchText) == false) {
                showErrorMessage(labelsarr[762]);
                $("#search_act").val("");
                $("#search_act").focus(); 
                return false;
            }
        }else{
            var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
            if(format.test(searchText)){            
                showErrorMessage(labelsarr[762]);
                $("#search_act").val("");
                $("#search_act").focus();
                return false;
            }            
        } 
    }
    
    var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
    // var encrypted_data5=null;
    // if(localStorage.LANGUAGE_FLAG=="english"){
    //     encrypted_data5 = ("0");
    // }else{
    //     encrypted_data5 = ("1");
    // }
    var encrypted_data5 = (bilingual_flag.toString());
    var data = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data), searchText:(searchText), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};


    $('#act_type').append('<option id="" value="">' + selectActTypeLabel + '</option>'); 
    
    //web service call to fetch act types
    callToWebService(actWebServiceUrl, data, actSearchResult);
    function actSearchResult(data){
        myApp.hidePleaseWait(); 
       if(data.msg){
            if((data.status)=='fail'){
                myApp.hidePleaseWait();
                showErrorMessage((data.msg));
            }
       }else{
        var decodedResult = (data);
        $.each(decodedResult.actsList, function (key, val) {
            if(val.acts){
                var actsArr = val.acts.split("#");
                $.each(actsArr, function (key, val) {
                    var act = val.split("~");
                    $('#act_type').append('<option id="" value="' + act[0] + '">' + act[1] + '</option>');
                });
            }
        });  
    }      
  }
}

//fetch data after Go button clicked either from session storage or from web service
function populateCasesTable() {

    $("#accordion_search").empty();
    var selectboxText = $("#court_code option:selected").text();
    if (window.localStorage.SESSION_COURT_CODE == null) {
        showErrorMessage(labelsarr[277]);
        //showErrorMessage("Please select court complex");
        return false;
    }

    var selectacttype = $("#act_type option:selected").val();

    if (selectacttype == null || selectacttype=='') {
        showErrorMessage(labelsarr[132]);
        return false;
    }
    
    var underSectionText = $("#under_section").val();
    var pendingDisposed = $("input[name='radOpt1']:checked").val();
    var selectActTypeText = $('#act_type').val();
    var actNumberSearchUrl = hostIP + "searchByActWebService.php";
    
    var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
    // var encrypted_data5=null;
    // if(localStorage.LANGUAGE_FLAG=="english"){
    //     encrypted_data5 = ("0");
    // }else{
    //     encrypted_data5 = ("1");
    // }
    var encrypted_data5 = (bilingual_flag.toString());
    var request_data = {selectActTypeText:(selectActTypeText), underSectionText:(underSectionText), pendingDisposed:(pendingDisposed), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};

    displayCasesTable(actNumberSearchUrl, request_data);
    
}
function go_back_link_searchPage_fun(){    
    backButtonHistory.pop();
    window.sessionStorage.removeItem("SET_RESULT");        
    $("#searchPageModal").modal('hide');
}

$("#menubarClose").click(function (e)
{
    //e.preventDefault();
    if ($("#mySidenav1").is(':visible'))
    {
        closeNav1();
    }
});