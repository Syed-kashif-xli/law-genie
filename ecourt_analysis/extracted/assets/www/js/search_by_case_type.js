var selectCaseTypeLabel = "Select Case Type";
var selectYearLabel = "Enter year";

$(document).ready(function () {
    second_header();
    backButtonHistory.push("searchcasepage");
    sessionStorage.setItem("tab", "#profile");
    populateCourtComplexes();        
    $('#case_type').empty();
    $('#case_type').append('<option id="" value="">'+selectCaseTypeLabel+'</option>');

    var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
    if(labelsarr){       
            $("#casestatus_heading1_label").html(labelsarr[11]);
            $("#search_by_case_type_label").html(labelsarr[65]);
            $("#court_complex_label").html(labelsarr[269]);
            $("#case_type_label").html(labelsarr[12]);
            $("#year_label").html(labelsarr[81]);
            $("#goButton").html(labelsarr[26]);
            $("#resetButton").html(labelsarr[57]);
            $('label[id=radOpt-0]').html(labelsarr[31]);
            document.getElementById("rad1").innerHTML=(labelsarr[31]);
            document.getElementById("rad2").innerHTML=(labelsarr[21]);
            $("#case_type option[value = '']").text(labelsarr[70]);
            selectCaseTypeLabel = labelsarr[70];
            selectYearLabel = labelsarr[81];
            $('#rgyear').attr('placeholder',selectYearLabel);
    }
    if (window.localStorage.SESSION_COURT_CODE != null) {
        populateCaseTypes();
    }    
    $('#court_code').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        // window.sessionStorage.removeItem("SESSION_SELECT_2");
        if ($('#court_code').val() != "") {
            window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
            window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));

        } else {
            window.localStorage.removeItem("SESSION_COURT_CODE");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");

        }
        populateCaseTypes();
        $("#Causelist_pannel").trigger("courtCodeChanged");
    });
    $('#case_type').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();              
    });
    
    //validations
    $("#rgyear").on('keydown', function () {
        if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();       
        }
        var pat = /^[0-9]*$/;
        if ($(this).val().length > 4) {
            $(".year_error").html(labelsarr[808]).show().fadeOut("slow");
            $("#rgyear").val("");
        return false;
        }
        if (pat.test($(this).val()) == false) {
            $(".year_error").html(labelsarr[808]).show().fadeOut("slow");
            $("#rgyear").val("");
            return false;
        }
    });

    $('input[type=radio][name=radOpt1]').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();  
    });
});

//clear form
$("#resetButton").click(function (e) {
    e.preventDefault();
    window.localStorage.removeItem('SESSION_COURT_CODE');
    window.sessionStorage.removeItem('SET_RESULT');
    $('#court_code').val("");
    $("#rgyear").val("");
    $("#case_type").empty(); 
    $('#case_type').append('<option id="" value="">'+selectCaseTypeLabel+'</option>');
    var $radios = $('input[name=radOpt1]');
    $radios.filter('[value=Pending]').prop('checked', true);  
    $("#accordion_search").empty();
    $("#headers").empty();  
    $("#Causelist_pannel").trigger("courtCodeChanged");          
});

//fetch data from web service or from session storage
$("#goButton").click(function (e) {

    e.preventDefault();
    if(window.sessionStorage.SET_RESULT == null){
        return populateCasesTable();
    }
});

function populateCasesTable() {
    $("#accordion_search").empty();
    var selectboxText = $("#court_code option:selected").text();
    if (window.localStorage.SESSION_COURT_CODE == null) {
        showErrorMessage(labelsarr[277]);
        //showErrorMessage("Please select court complex");
        return false;
    }

    var caseTypeselectboxText = $("#case_type option:selected").val();    
    if (caseTypeselectboxText == null || caseTypeselectboxText =='') {
        showErrorMessage(labelsarr[44]);
        return false;
    }    

    var year = $("#rgyear").val();
    if (year == '') {
        showErrorMessage(labelsarr[115]);
        return false;
    }

    if (window.sessionStorage.getItem("SET_RESULT") == null) {
        var pendingDisposed = $("input[name='radOpt1']:checked").val();
        var year = $("#rgyear").val();


            if(!year.length==0)
            {

                    if (year <= 0) {
                showErrorMessage(labelsarr[708]);
                $("#rgyear").val("");
                $("#rgyear").focus(); 
                return false;
                }
                if(year.toString().length < 4)
                    {
                        showErrorMessage(labelsarr[42]);
                        $("#rgyear").val("");
                        $("#rgyear").focus(); 
                        return false;

                    }

                var d = new Date();
                var n = d.getFullYear();
                if (year <= 1900 || year > n)
                {
                    showErrorMessage(labelsarr[43] + n);
                    $("#rgyear").val("");
                    $("#rgyear").focus(); 
                    return false;
                }
            }
        var caseTypeVal = $("#case_type option:selected").val();
        var caseTypeSearchUrl = hostIP + "searchByCaseType.php";        
        var request_data = {case_type:(caseTypeVal), year:(year), pendingDisposed:(pendingDisposed)};
        displayCasesTable(caseTypeSearchUrl, request_data);
    } else {
        displayCasesTable1();
    }
}

//fetch case types from web service or from session storage
function populateCaseTypes() {
    $('#case_type').empty();
    $('#case_type').append('<option id="" value="">'+selectCaseTypeLabel+'</option>');
    var selectboxText = $("#court_code option:selected").text();
    if (window.localStorage.SESSION_COURT_CODE == null) {
        return false;
    }

    var state_code_data = window.localStorage.state_code;
    var district_code_data = window.localStorage.district_code;

    var caseTypeWebServiceUrl = hostIP + "caseNumberWebService.php";
    var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

    court_code_data = courtCodesArr[0];
    var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
    var  encrypted_data5=0;
    // if(localStorage.LANGUAGE_FLAG=="english"){
    //     encrypted_data5 = ("0");
    // }else{
    //     encrypted_data5 = ("1");
    // }
    encrypted_data5 = (bilingual_flag.toString());

    var caseTypedata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
    //web service call to fetch case types
    callToWebService(caseTypeWebServiceUrl, caseTypedata, caseTypeSearchResult);
    function caseTypeSearchResult(result)
        {              
            var decodedResult = (result);
            $.each(decodedResult.case_types, function (key, val) {
            var caseTypesArr = val.case_type.split("#");
            $.each(caseTypesArr, function (key, val) {
                var casetype = val.split("~");
                $('#case_type').append('<option id="" value="' + casetype[0] + '">' + casetype[1] + '</option>');
            });
            });                 
            myApp.hidePleaseWait();
        }            
    
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