var selectFilingNoLabel = "Filing Number";
var selectYearLabel = "Year";

$(document).ready(function () {
    second_header();
    backButtonHistory.push("searchcasepage");
    sessionStorage.setItem("tab", "#profile");
    populateCourtComplexes();        

    var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
    if(labelsarr){       
            $("#casestatus_heading1_label").html(labelsarr[11]);
            $("#search_by_filing_no_label").html(labelsarr[306]);
            $("#court_complex_label").html(labelsarr[269]);
            $("#filing_number_label").html(labelsarr[120]);
            $("#year_label").html(labelsarr[81]);
            $("#goButton").html(labelsarr[26]);
            $("#resetButton").html(labelsarr[57]);
            selectFilingNoLabel = labelsarr[120];
            $('#search_filing_no').attr('placeholder',selectFilingNoLabel);
            selectYearLabel = labelsarr[81];
            $('#year').attr('placeholder',selectYearLabel);        
    }

    $('#court_code').change(function () {
        // window.sessionStorage.removeItem("SESSION_COURTNAMES");
        window.sessionStorage.removeItem("SET_RESULT");
        
        $("#accordion_search").empty();
        $("#headers").empty();    
        if ($('#court_code').val() != "") {
            window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
            window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));

        } else {
            window.localStorage.removeItem("SESSION_COURT_CODE");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
        }
        $("#Causelist_pannel").trigger("courtCodeChanged");
    });


    
  


    $("#search_filing_no").on('keydown', function () {
        if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");           
            $("#accordion_search").empty();
            $("#headers").empty();    
        }
        if ($(this).val().length > 7) {
            $(".filing_number_val").html(labelsarr[809]).show().fadeOut("slow");
            $(this).val("");
            return false;
        }
    });
    $("#year").on('keydown', function () {
        if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();    
            $("#headers").empty();            
        }
        if ($(this).val().length > 4) {
            $(".year").html(labelsarr[808]).show().fadeOut("slow");
            $(this).val("");
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
    $("#search_filing_no").val("");
    $("#year").val("");
    $("#accordion_search").empty();
    $("#headers").empty();    
    $("#Causelist_pannel").trigger("courtCodeChanged"); 
    // location.reload();
});

//fetch search data from web service or session storage
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
        //showErrorMessage("Please Select Court Complex");
        return false;
    }

    var filingNumber = $("#search_filing_no").val();
    var year = $("#year").val();

    if (filingNumber == '' || filingNumber === null) {
        showErrorMessage(labelsarr[254]);
        $("#search_filing_no").val("");
        $("#search_filing_no").focus();     
        return false;
    }
    if (filingNumber <= 0) {
        showErrorMessage(labelsarr[709]);
        $("#search_filing_no").val("");
        $("#search_filing_no").focus(); 
        return false;
    }

    if (year == '' || year === null) {
        showErrorMessage(labelsarr[115]);
        $("#year").val("");
        $("#year").focus(); 
        return false;
    }
    if (year <= 0) {
        showErrorMessage(labelsarr[708]);
        $("#year").val("");
        $("#year").focus(); 
        return false;
    }
    if(year.toString().length < 4)
    {
        showErrorMessage(labelsarr[42]);
    $("#year").val("");
        $("#year").focus(); 
        return false;

    } 
    var d = new Date();
    var n = d.getFullYear();
    if (year <= 1900 || year > n)
    {
        showErrorMessage(labelsarr[43] + n);
        $("#year").val("");
        $("#year").focus(); 
        return false;
    }

    window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_filing_number.html");
    if (window.sessionStorage.getItem("SET_RESULT") == null) {
        var filingNumberSearchUrl = hostIP + "searchByFilingNumberWebService.php";
        var request_data = {filingNumber:(filingNumber), year:(year)};
        displayCasesTable(filingNumberSearchUrl, request_data);
    } else {
        displayCasesTable1();
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