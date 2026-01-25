
    $(document).ready(function () {
        backButtonHistory.push("searchcasepage");
        second_header();
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;
        arrCourtEstNames = [];
        arrCourtEstCodes = [];

        //validation
        $("#search_filing_no").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
        }
            if ($(this).val().length > 7) {
                $(".filing_number_val").html("7 Digits Only in filing number").show().fadeOut("slow");
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
                $(".year").html("4 Digits Only in year").show().fadeOut("slow");
                $(this).val("");
                return false;
            }
        });

    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        window.sessionStorage.removeItem('SET_RESULT'); 
        $("#search_filing_no").val('');
        $("#year").val('');
        $("#accordion_search").empty();
        $("#headers").empty(); 
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
       
        var filingNumber = $("#search_filing_no").val();
        var year = $("#year").val();

        if (filingNumber == '' || filingNumber === null) {
            showErrorMessage("Please Enter Filing Number");
            $("#search_filing_no").val("");
             $("#search_filing_no").focus();     
            return false;
        }
        if (filingNumber <= 0) {
            showErrorMessage("Please Enter Non Zero Filing Number");
            $("#search_filing_no").val("");
            $("#search_filing_no").focus(); 
            return false;
        }

        if (year == '' || year === null) {
            showErrorMessage("Please Enter Year");
            $("#year").val("");
            $("#year").focus(); 
            return false;
        }
        if (year <= 0) {
            showErrorMessage("Please Enter Non Zero Year");
            $("#year").val("");
            $("#year").focus(); 
            return false;
        }
         if(year.toString().length < 4)
        {
             showErrorMessage("please enter 4 digit year");
           $("#year").val("");
             $("#year").focus(); 
            return false;

        } 
        var d = new Date();
        var n = d.getFullYear();
        if (year <= 1900 || year > n)
        {
            showErrorMessage("Please Enter Year between 1901 to " + n);
            $("#year").val("");
            $("#year").focus(); 
            return false;
        }
        window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_filing_number_hc.html");
        var filingNumberSearchUrl = hostIP + "searchByFilingNumberWebService.php";
        var request_data = {filingNumber:(filingNumber), year:(year)};
        displayCasesTable(filingNumberSearchUrl, request_data);
    }

    function CheckBrowser() {
        if ('localStorage' in window && window['localStorage'] !== null) {
            return true;
        } else {
            return false;
        }
    }
 
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