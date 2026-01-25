    $(document).ready(function () {             
        sessionStorage.setItem("tab", "#Tab3");
      //Removes cause list search result saved in session storage
      function clearResult(){
          $("#cases").empty();
          
          window.sessionStorage.removeItem("RESULT_CAUSE_LIST");
          window.sessionStorage.removeItem("SESSION_BENCHES");
          window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
          populateCauseListBenches();
        }
        // $('#pickyDate').attr('readonly', true);
        /* $('#pickyDate').datepicker({dateFormat: 'dd-mm-yy',

                                        maxDate: +30 ,
                                        minDate: -30,
                                        onSelect: clearResult
                                       });*/       
        var now = new Date();
        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);
        var today = now.getFullYear() + "-" + (month) + "-" + (day);

        $('#pickyDate').val(today);
        document.getElementById("pickyDate").value = today;
        
        var maxdate = new Date();
        maxdate.setDate(maxdate.getDate() + 30); // add 30 days         
        var day1 = ("0" + maxdate.getDate()).slice(-2);
        var month1 = ("0" + (maxdate.getMonth() + 1)).slice(-2);
        var maxdate30 =  maxdate.getFullYear() + "-" + (month1) + "-" + (day1) ;
        document.getElementById("pickyDate").max = maxdate30;

        var mindate = new Date();
        mindate.setDate(mindate.getDate() - 7); // add 30 days         
        var day1 = ("0" + mindate.getDate()).slice(-2);
        var month1 = ("0" + (mindate.getMonth() + 1)).slice(-2);
        var mindate7 =  mindate.getFullYear() + "-" + (month1) + "-" + (day1) ;        
        document.getElementById("pickyDate").min = mindate7;

        // $("#pickyDate").on("change",function(){
        //     clearResult();
        //     var selectedDATE = $('#pickyDate').val();
        //     alert('selected date'+selectedDATE);
            
        // });   
        $('#pickyDate').change(function() {
            clearResult();
            RESULT_CAUSE_LIST = "";  
        });  

        arrCourtEstNames = [];
        arrCourtEstCodes = [];
        //used for page reload. To retain date selected in date picker
        if (window.sessionStorage.SESSION_INPUT_1_CAUSE_LIST != null) {
            $('#pickyDate').val(window.sessionStorage.SESSION_INPUT_1_CAUSE_LIST);
        }
        $('#cause_list_bench').change(function () {
            $("#cases").empty();
            window.sessionStorage.removeItem("SESSION_BENCHES");
            window.sessionStorage.setItem("SESSION_SELECT_2_CAUSE_LIST", $('#cause_list_bench').val());
            window.sessionStorage.removeItem("RESULT_CAUSE_LIST");
        });
         if (window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST == null || window.sessionStorage.SESSION_BENCHES == null) {
            populateCauseListBenches();
        }
        //If court name is selected and court complex is selected, then trigger button click (SESSION_INPUT_2_CAUSE_LIST is saved button clicked either civil or criminal)
        if (window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST != null) {
            onButtonClick(window.sessionStorage.SESSION_INPUT_2_CAUSE_LIST);
        }
    });

    //fetch court names either from session storage or from web service
    function populateCauseListBenches() {
        //$('#cause_list_bench').empty();
        var items = [];
        items.push("<option value='0'>Select Bench</option>");
        $("#cause_list_bench").html(items.join(""));
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var causelist_date = $('#pickyDate').val();        
        var date = new Date(causelist_date);
        var seldate = ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '-' + ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) +'-'+ date.getFullYear();
        var benchWebServiceUrl = hostIP + "causeListBenchWebService.php";
        if(window.localStorage.SESSION_COURT_CODE != ''){
            if(window.sessionStorage.SESSION_BENCHES == null || typeof(window.sessionStorage.SESSION_BENCHES === undefined )){
                var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");                
                court_code_data = courtCodesArr[0];
                var reqForBenchData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(window.localStorage.SESSION_COURT_CODE), date:(seldate)};
                //web service call to court names web service to fetch court names
                callToWebService(benchWebServiceUrl, reqForBenchData, causeListBenchsearchResult);
                function causeListBenchsearchResult(result){
                    var decodedResult = (result.benches);
                    if(decodedResult.benchesStr != null){
                        window.sessionStorage.setItem("SESSION_BENCHES", decodedResult.benchesStr);
                        processBenches(decodedResult.benchesStr);
                    }
                    myApp.hidePleaseWait();                          
                }                
            }else{
               //If benches are saved in session storage.
                var items = [];
                items.push("<option value=''>Select Bench</option>");
                $("#cause_list_bench").html(items.join(""));
                processBenches(window.sessionStorage.SESSION_BENCHES); 
            }
        }
    }

    //populates court names select box
    function processBenches(benches){  
        document.getElementById('cause_list_bench').value = "0";
        // $('#cause_list_bench').value="0";  
        
            var benchesArr = benches.split("^");
            $.each(benchesArr, function (key, val) {
                var casetype = val.split("~");
                $('#cause_list_bench').append('<option id="" value="' + casetype[0] + '">' + casetype[1] + '</option>');           
            });
        
        if (window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST != null) {
            document.getElementById('cause_list_bench').value = window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST;
        } else {
            document.getElementById('cause_list_bench').value = "0";
        }
    }

    /*called after button click Civil / Criminal
    *@id : "civilButton" or "criminalButton"
    */
    function onButtonClick(id) {       
        $("#cases").empty();
        if (window.sessionStorage.SESSION_INPUT_1_CAUSE_LIST != $('#pickyDate').val()) {
            window.sessionStorage.setItem("SESSION_INPUT_1_CAUSE_LIST", $('#pickyDate').val());
        }
        if (window.sessionStorage.SESSION_INPUT_2_CAUSE_LIST != id) {
            window.sessionStorage.setItem("SESSION_INPUT_2_CAUSE_LIST", id);
        }
        var date = $('#pickyDate').val();
        if (date == '') {
            showErrorMessage("Please Select Cause List Date");
            return false;
        }
        if (window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST == null) {
            showErrorMessage("Please select Bench");
            return false;
        }
        var retVal = checkDateInpuWithTodays();
        if (retVal == false)
        {
            showErrorMessage("Only last 7 days date selection allowed");
            return false;
        } else
        {
            
            var val;

            /*if (id == "civilButton") {
                val = 'civ_t';
            }
            if (id == "criminalButton") {
                val = 'cri_t';
            }*/
            //saved selected button in session storage, to retain selected button state during page reload.
            var savedButtonId = sessionStorage.getItem("CAUSE_LIST_BUTTON");
           
           /* if (id != savedButtonId) {
                window.sessionStorage.removeItem("RESULT_CAUSE_LIST");
                sessionStorage.setItem("CAUSE_LIST_BUTTON", id);
               
         }*/
             
            submitFormCivil();

        }
    }

    //validate date 
    function checkDateInpuWithTodays()
    {
        //get today's date in string
        var todayDate = new Date();
        var todayMonth = todayDate.getMonth() + 1;
        var todayDay = todayDate.getDate();
        var todayYear = todayDate.getFullYear();
        var todayDateText = todayMonth + "/" + todayDay + "/" + todayYear;
        var prevWeek = new Date();
        //7 days before
        prevWeek.setTime(prevWeek.valueOf() - 30 * 24 * 60 * 60 * 1000);
        var prevDay = prevWeek.getDate();
        var prevMonth = prevWeek.getMonth() + 1;
        var prevYear = prevWeek.getFullYear();
        var prevWeekText = prevMonth + "/" + prevDay + "/" + prevYear;
    //get date input from SharePoint DateTime Control
        var inputDateText = $('#pickyDate').val();
        var dateString = inputDateText.replace(/\-/g, '/');
        var dateString_arr = dateString.split('/');
        dateString = dateString_arr[1] + '/' + dateString_arr[0] + '/' + dateString_arr[2];
    //Convert both input to date type
        var inputToDate = Date.parse(dateString);
        var todayToDate = Date.parse(todayDateText);
        var prevWeekToDate = Date.parse(prevWeekText);
        if (inputToDate < prevWeekToDate)
        {
            return false;
        } else
        {
            return true;
        }
    }

    /*
    *fetch cases for selected button
    *@val : 'civ_t' or 'cri_t'
    */
    function submitFormCivil(val)
    {
        $("#cases").empty();
        //If cases result is saved in session storage, then display cases from there, else fetch cases from webservice 
        if (window.sessionStorage.getItem("RESULT_CAUSE_LIST") == null) {
            var causelist_date = $('#pickyDate').val();
            var today = new Date();
            var toddd = today.getDate();
            var todmm = today.getMonth() + 1; //January is 0!
            var todyyyy = today.getFullYear();
            if (toddd < 10)
            {
                toddd = '0' + toddd
            }
            if (todmm < 10) {
                todmm = '0' + todmm
            }
            var curYMD = todyyyy + '-' + todmm + '-' + toddd;
            var curDMY = toddd + '-' + todmm + '-' + todyyyy;
            var causelist_date_split = causelist_date.split('-');

            var causelist_date_y = causelist_date_split[2];

            var causelist_date_m = parseInt(causelist_date_split[1]) - 1;
            if (causelist_date_m < 10)
            {
                causelist_date_m = '0' + causelist_date_m;
            }
            var causelist_date_d = causelist_date_split[0];
            if (causelist_date_d < 10)
            {
                causelist_date_d = '0' + causelist_date_d;
            }
            var seldate = new Date(causelist_date_y, causelist_date_m, causelist_date_d);
            var one_day = 1000 * 60 * 60 * 24;
            // Convert both dates to milliseconds
            var today_ms = today.getTime();
            var seldate_ms = seldate.getTime();
            var daysdiff = today_ms - seldate_ms;
            var selprevdays;
            if (daysdiff == 0)
            {
                selprevdays = 1;
            } else
            {
                selprevdays = 0;
            }
            var ci_cri = val;
            var state_code_data = window.localStorage.state_code;
            var district_code_data = window.localStorage.district_code;            
            var bench_id = $('#cause_list_bench').val();            
            var casesWebServiceUrl = hostIP + "cases_new.php";
            var court_code=window.localStorage.SESSION_COURT_CODE;         
            var date = new Date(causelist_date);
            var seldate = ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '-' + ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) +'-'+ date.getFullYear();
            var casesdata = {state_code:(state_code_data), dist_code:(district_code_data), selprevdays:(selprevdays.toString()),  court_code:(court_code), causelist_date:(seldate), bench_id:(bench_id)};
            //web service call to fetch cases for Civil or Criminal depending on selected button
            callToWebService(casesWebServiceUrl, casesdata, causeListsearchResult);
            function causeListsearchResult(result){
                myApp.hidePleaseWait();
                var obj_cases = (result.cases);
                if(obj_cases){
                    window.sessionStorage.setItem("RESULT_CAUSE_LIST", JSON.stringify(obj_cases));
                    setCauseListResult(JSON.stringify(obj_cases));
                    $("#cases").append(obj_cases);
                }else{
                    $("#casesnotfound").empty("");
                    $("#casesnotfound").css({"text-align":"center","width":"100%","color":"#FA814C ","font-size":"16px"});
                }                
            }          
        } else {          
            $("#cases").append(JSON.parse(window.sessionStorage.getItem("RESULT_CAUSE_LIST")));
        }
    }

    //blocked tab swipe for cause list result table since this table has horizontal scroll
    $(function () {
        $("#cases").swipe({
            swipeStatus: function (event, phase, direction, distance, fingerCount) {
                return false;
            }
        });
    });

