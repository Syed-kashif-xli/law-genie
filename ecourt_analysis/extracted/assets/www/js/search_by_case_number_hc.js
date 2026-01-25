
   var selectCaseTypeLabel = "Select Case Type";
    $(document).ready(function () {
        backButtonHistory.push("searchcasepage");
        second_header();
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;
        arrCourtEstNames = [];
        arrCourtEstCodes = [];
        $('#case_number').bind("cut copy paste", function (e) {
            e.preventDefault();
        });
        $('#rgyear').bind("cut copy paste", function (e) {
            e.preventDefault();
        });
        $('#case_type').empty();
        $('#case_type').append('<option id="" value="">selectCaseTypeLabel</option>');
        if (window.localStorage.SESSION_COURT_CODE != null) {
            populateCaseTypes();
        }
        $('#case_type').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search_search").empty();
            $("#headers").empty();   
        });
        $("#case_number").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();  
            }
            if ($(this).val().length > 7) {
                $(".case_number_val").html("7 Digits Only in case number").show().fadeOut("slow");
                $(this).val("");
                return false;
            }
        });
        $("#rgyear").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();  
            }
            if ($(this).val().length > 4) {
                $(".year").html("4 Digits Only in year").show().fadeOut("slow");
                $(this).val("");
                return false;
            }
        });
    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();       
        $('#case_type').append('<option id="" value="">'+selectCaseTypeLabel+'</option>');
        $("#case_number").val('');
        $("#rgyear").val('');
        $("#totalEstablishments").empty();
        $("#accordion_search").empty();
        $('#case_type').val('');
        $("#headers").empty(); 
    });

    //fetch search result after Go button click from web service or from session storage
    $("#goButton").click(function (e) {
        e.preventDefault();
        if(window.sessionStorage.SET_RESULT == null){     
        return populateCasesTable();
        }
    });

    function populateCasesTable() {
        $("#accordion_search").empty();
       
        var caseTypeselectboxText = $("#case_type option:selected").val();
        if (caseTypeselectboxText == null||caseTypeselectboxText=='') {
            showErrorMessage("Please select Case Type");
            return false;
        }

        var caseNumber = $("#case_number").val();
        if (caseNumber === '' || caseNumber === null) {
            showErrorMessage("Please enter Case number");
            $("#case_number").val("");
            $("#case_number").focus(); 
            return false;
        }
        if (caseNumber <= 0) {
            showErrorMessage("Please Enter Non Zero Case Number");
            $("#case_number").val("");
            $("#case_number").focus();
            return false;
        }

        var year = $("#rgyear").val();
        if (year === '' || year === null) {
            showErrorMessage("Please enter year");
            $("#rgyear").val("");
            $("#rgyear").focus();
            return false;
        }
        if (year <= 0) {
            showErrorMessage("Please Enter Non Zero Year");
            $("#rgyear").val("");
            $("#rgyear").focus();
            return false;
        }
        if(year.toString().length < 4)
        {
             showErrorMessage("please enter 4 digit year");
            $("#rgyear").val("");
             $("#rgyear").focus(); 
            return false;

        }
        var d = new Date();
        var n = d.getFullYear();
        if (year <= 1900 || year > n)
        {
            showErrorMessage("Please Enter Year between 1901 to " + n);
            $("#rgyear").val("");
            $("#rgyear").focus();
            return false;
        }
        var caseTypeVal = $("#case_type option:selected").val();
        var caseNumberSearchUrl = hostIP + "caseNumberSearch.php";
        var request_data = {case_number:(caseNumber), case_type:(caseTypeVal), year:(year)};
        displayCasesTable(caseNumberSearchUrl, request_data);
    }

    //fetch case types from web service or session storage
    function populateCaseTypes() {
        $('#case_type').empty();
        $('#case_type').append('<option id="" value="">Select Case Type</option>');
       // var selectboxText = $("#court_code option:selected").text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var caseTypeWebServiceUrl = hostIP + "caseNumberWebService.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
        court_code_data = courtCodesArr[0];
        var caseTypedata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data)};
        //web service call to fetch case types for selected case complex
        callToWebService(caseTypeWebServiceUrl, caseTypedata, caseTypesearchResult);
            function caseTypesearchResult(result){
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
});

function go_back_link_searchPage_fun_hc(){    
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