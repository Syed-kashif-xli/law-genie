    /*
    variables saved in local/ session storage to retain page session after page reload

    SESSION_COURT_CODE : court complexes selected value- saved in local storage
    SESSION_SELECT_2 : act type selected value- session storage
    SESSION_BACKLINK : current page- session storage
    SESSION_INPUT_1 : search Act text box input value- session storage
    SESSION_INPUT_2 : under Act text box input value- session storage 
    SET_RESULT : Result after Go button click- session storage 
    */
    $(document).ready(function () {
        second_header();
        backButtonHistory.push("searchcasepage");
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;

        arrCourtEstNames = [];
        arrCourtEstCodes = [];
        $('#act_type').empty();
        $('#act_type').append('<option id="" value="">Select Act Type</option>');
        if (window.localStorage.SESSION_COURT_CODE != null) {
           // $("#searchButton").click();
           populateActTypes();
        }
      /*   if (window.sessionStorage.SESSION_INPUT_1 != null) {
            $("#search_act").val(window.sessionStorage.SESSION_INPUT_1);
        }
        if (window.sessionStorage.SESSION_PENDING_DISPOSED != null) {
            var selected_radio = window.sessionStorage.SESSION_PENDING_DISPOSED;        
            var $radios = $('input[name=radOpt1]');
            $radios.filter('[value='+selected_radio+']').prop('checked', true);
        } */
        

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();     
        });

        $('#act_type').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();     
    
           /*  if ($('#act_type').val() == '') {
                window.sessionStorage.removeItem("SESSION_SELECT_2");
            } else {
                window.sessionStorage.setItem("SESSION_SELECT_2", $('#act_type').val());
            }
            window.sessionStorage.removeItem("SET_RESULT"); */

        }); 
      /*  window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_act_hc.html");
        if (window.localStorage.SESSION_COURT_CODE != null && window.sessionStorage.SESSION_SELECT_2 != null) {
            $("#goButton").click();
        } */

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
            if (pat.test($(this).val()) == false) {
                $(".search_act").html(" only letters, numbers ").show().fadeOut("slow");
                $("#search_act").val("");
                 $("#search_act").focus(); 
                return false;
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
                $(".under_section").html(" only letters, numbers ").show().fadeOut("slow");
                $("#under_section").val("");
                 $("#under_section").focus(); 
                return false;
            }
        });

    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        window.sessionStorage.removeItem('SET_RESULT');
//        window.localStorage.removeItem('SESSION_COURT_CODE');
//        window.sessionStorage.removeItem('SESSION_INPUT_1');
  //      window.sessionStorage.removeItem('SESSION_INPUT_2');
        //window.sessionStorage.removeItem('SESSION_SELECT_2');
         $("#act_type").val('');
         $("#search_act").val('');
         $("#under_section").val('');
         var $radios = $('input[name=radOpt1]');
         $radios.filter('[value=Pending]').prop('checked', true);  
 //       $("#totalEstablishments").empty();
        $("#accordion_search").empty();
        $("#headers").empty();  
        //location.reload();
    });

    //fill session variables and fetch data.
    $("#goButton").click(function (e) {
        e.preventDefault();
       // window.sessionStorage.setItem("SESSION_INPUT_1", $("#search_act").val());
       // window.sessionStorage.setItem("SESSION_INPUT_2", $("#under_section").val());
      //  window.sessionStorage.setItem("SESSION_PENDING_DISPOSED",$("input[name='radOpt1']:checked").val());
        if(window.sessionStorage.SET_RESULT == null){
        return populateCasesTable();
        }
    });

    //called when clicked on search act text box search button
    /* $("#searchButton").click(function (e) {
        e.preventDefault(); */
        function populateActTypes(){
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
            if (pat.test(searchText) == false) {
                showErrorMessage("only letters, numbers ");
                $("#search_act").val("");
                 $("#search_act").focus(); 
                return false;
            }

        }

        var data = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data), searchText:(searchText)};


        $('#act_type').append('<option id="" value="">' + "Select Act Type" + '</option>');
        //web service call to fetch act types
            callToWebService(actWebServiceUrl, data, actsearchResult);
            function actsearchResult(data){
             myApp.hidePleaseWait();
            var decodedResult = (data);
            $.each(decodedResult.actsList, function (key, val) {
                var actsArr = val.acts.split("#");
                $.each(actsArr, function (key, val) {
                    var act = val.split("~");
                    $('#act_type').append('<option id="" value="' + act[0] + '">' + act[1] + '</option>');
                });
            });           
        }
    }

    //fetch data after Go button clicked either from session storage or from web service
    function populateCasesTable() {

        $("#accordion_search").empty();
       
        var selectacttype = $("#act_type option:selected").val();
        if (selectacttype == null || selectacttype=='') {
            showErrorMessage("Please select Act Type");
            return false;
        }
        // if (window.sessionStorage.getItem("SET_RESULT") == null) {
            var underSectionText = $("#under_section").val();
            var pendingDisposed = $("input[name='radOpt1']:checked").val();
            var selectActTypeText =  $('#act_type').val();
            var actNumberSearchUrl = hostIP + "searchByActWebService.php";

            var request_data = {selectActTypeText:(selectActTypeText), underSectionText:(underSectionText), pendingDisposed:(pendingDisposed)};

            displayCasesTable(actNumberSearchUrl, request_data);
        // } else {
        //     displayCasesTable1();
        // }
    }
  /*   function closeNav() {

            document.getElementById("mySidenav").style.display = "none";
        }
    $("#menubarClose").click(function ()
        {
            if ($("#mySidenav").is(':visible'))
            {
                closeNav();
            } 
        }); */


 /*    document.addEventListener("backbutton", onBackKeyDown, false);

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