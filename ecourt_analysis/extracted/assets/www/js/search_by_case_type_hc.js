    /*
    variables saved in local/ session storage to retain page session after page reload

    SESSION_COURT_CODE : court complexes selected value- saved in local storage
    SESSION_SELECT_2 : case type selected value- session storage
    SESSION_BACKLINK : current page- session storage            
    SESSION_INPUT_1 : year input value- session storage 
    SET_RESULT : Result after Go button click- session storage 
    */
  // var selectCaseTypeLabel = "Select Case Type";
    $(document).ready(function () {
        backButtonHistory.push("searchcasepage");
        second_header();
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;
        arrCourtEstNames = [];
        arrCourtEstCodes = [];
        $('#case_type').empty();
        $('#case_type').append('<option id="" value="">Select Case Type</option>');

        if (window.localStorage.SESSION_COURT_CODE != null) {
            populateCaseTypes();
        }
      /*   if (window.sessionStorage.SESSION_PENDING_DISPOSED != null) {
            var selected_radio = window.sessionStorage.SESSION_PENDING_DISPOSED;        
            var $radios = $('input[name=radOpt1]');
            $radios.filter('[value='+selected_radio+']').prop('checked', true);
        }
         */

       /*  if (window.sessionStorage.SESSION_SELECT_2 != null) {
            populateCaseTypes();
        } */

        $('#case_type').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
           /*  if ($('#case_type').val() == '') {
                window.sessionStorage.removeItem("SESSION_SELECT_2");
            } else {
                window.sessionStorage.setItem("SESSION_SELECT_2", $('#case_type').val());
            } */
        });
      /*   if (window.sessionStorage.SESSION_INPUT_1 != null) {
            $("#rgyear").val(window.sessionStorage.SESSION_INPUT_1);
        } */

        //validations
        $("#rgyear").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();       
        }
            var pat = /^[0-9]*$/;
            if ($(this).val().length > 4) {
                $(".year_error").html("4 Digits Only in year").show().fadeOut("slow");
                $("#rgyear").val("");
             return false;
            }
            if (pat.test($(this).val()) == false) {
                $(".year_error").html(" only letters, numbers ").show().fadeOut("slow");
                $("#rgyear").val("");
                return false;
            }
        });

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#totalEstablishments").empty();
            $("#accordion_search").empty();
            $("#headers").empty();
        });

        /* if (window.sessionStorage.SESSION_SELECT_2 != null && window.localStorage.SESSION_COURT_CODE != null) {
            $("#goButton").click();
        } */
    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        window.sessionStorage.removeItem('SET_RESULT');
        //window.localStorage.removeItem('SESSION_COURT_CODE');
  //      window.sessionStorage.removeItem('#rgyear');
 //       window.sessionStorage.removeItem('#case_type');
        $("#case_type").val('');
        $("#rgyear").val('');
        var $radios = $('input[name=radOpt1]');
        $radios.filter('[value=Pending]').prop('checked', true); 
        $("#totalEstablishments").empty();
        $("#accordion_search").empty();
      $("#headers").empty(); 
        //location.reload();
    });

    //fetch data from web service or from session storage
    $("#goButton").click(function (e) {

        e.preventDefault();
      //  window.sessionStorage.setItem("SESSION_INPUT_1", $("#rgyear").val());
      //  window.sessionStorage.setItem("SESSION_PENDING_DISPOSED",$("input[name='radOpt1']:checked").val());
        if(window.sessionStorage.SET_RESULT == null){
        return populateCasesTable();
        }
    });

    function populateCasesTable() {
        $("#accordion_search").empty();
    //    var selectboxText = $("#court_code option:selected").text();
        /*if (window.localStorage.SESSION_COURT_CODE == null) {
            showErrorMessage("Please select court complex");
            return false;
        }
*/
        var caseTypeselectboxText = $("#case_type option:selected").val();
        if (caseTypeselectboxText == null || caseTypeselectboxText=='') {
            showErrorMessage("Please select Case Type");
            return false;
        }    

        var year = $("#rgyear").val();
        if (year == '') {
            showErrorMessage("Please enter year");
            return false;
        }

        window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_case_type_hc.html");
    //   if (window.sessionStorage.getItem("SET_RESULT") == null) {
            var pendingDisposed = $("input[name='radOpt1']:checked").val();
            var year = $("#rgyear").val();


                if(!year.length==0)
                {

                        if (year <= 0) {
                    showErrorMessage("Please Enter Non Zero Year");
                    $("#rgyear").val("");
                     $("#rgyear").focus(); 
                    return false;
                    }
                     if(year.toString().length < 4)
                        {
                             showErrorMessage("Please enter 4 digit year");
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
                }




            var caseTypeVal = $("#case_type option:selected").val();
            var caseTypeSearchUrl = hostIP + "searchByCaseType.php";

            var request_data = {case_type:(caseTypeVal), year:(year), pendingDisposed:(pendingDisposed)};
            displayCasesTable(caseTypeSearchUrl, request_data);
        // } else {
        //     displayCasesTable1();
        // }
    }

    //fetch case types from web service or from session storage
    function populateCaseTypes() {
        $('#case_type').empty();
        $('#case_type').append('<option id="" value="">Select Case Type</option>');
       // var selectboxText = $("#court_code option:selected").text();
        

        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;

        var caseTypeWebServiceUrl = hostIP + "caseNumberWebService.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];

        var caseTypedata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data)};

        //web service call to fetch case types        
            callToWebService(caseTypeWebServiceUrl, caseTypedata, caseTypeSearchResult);
            function caseTypeSearchResult(result){
                var decodedResult = (result);
                $.each(decodedResult.case_types, function (key, val) {
                    var caseTypesArr = val.case_type.split("#");
                    $.each(caseTypesArr, function (key, val) {
                        var casetype = val.split("~");
                        $('#case_type').append('<option id="" value="' + casetype[0] + '">' + casetype[1] + '</option>');
                    });
                    if (window.sessionStorage.SESSION_SELECT_2 != null) {
                        document.getElementById('case_type').value = window.sessionStorage.SESSION_SELECT_2;
                    } else {
                        document.getElementById('case_type').value = '';
                    }
                });                 
                myApp.hidePleaseWait();
            }
    }
   /*  function closeNav() {

            document.getElementById("mySidenav").style.display = "none";
        }
    $("#menubarClose").click(function ()
        {
            if ($("#mySidenav").is(':visible'))
            {
                closeNav();
            } 
        }); */

   /*  document.addEventListener("backbutton", onBackKeyDown, false);

    function onBackKeyDown(e) 
    {
        e.preventDefault();  
        window.location.replace("index_hc.html");

    } */

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