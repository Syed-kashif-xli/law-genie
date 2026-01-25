    //to save date selected from datepicker
    dateText = "";
    //contains todays date
    todayDateText = "";
    //highlight searched text 
    highlightText = false;
    //CNR numbers array for datewise sorting
    var datewiseCNRNumbers = [];
    var  isOffline = false;
    var cnrArrModified = false;
    var regenerateWebserviceCallFlag = false;
    //on load
    //$(document).ready(function () {
document.addEventListener("deviceready", onDeviceReady, false);

function onDeviceReady() {
        var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
        var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
        var last_updated_cases_date = localStorage.getItem("LAST_MyCASES_HC_EXPORT");       
        
        if(cnrNumbersArray && cnrNumbersArray.length != 0){
            if(last_updated_cases_date){
                var last_updated_date = new Date(last_updated_cases_date);
                var today_ms = new Date().getTime();
                var last_updated_Date_ms = last_updated_date.getTime();
                var daysdiff = today_ms - last_updated_Date_ms;
                daysdiff = daysdiff/ (1000 * 3600 * 24);
                if (parseInt(daysdiff) > 6)
                {
                    $("#exportCasesWarning").show();
                    $("#my_cases_text").hide();

                    
                }else{
                    $("#exportCasesWarning").hide();
                    $("#my_cases_text").show();

                }
            }else{
                $("#exportCasesWarning").show();
                $("#my_cases_text").hide();
            }
        }else{
            $("#exportCasesWarning").hide();
            $("#my_cases_text").show();
        }

        //find todays date
         var fullDate = new Date()

        var twoDigitDate = ((fullDate.getDate().toString().length) == 2)? (fullDate.getDate()) : '0' + (fullDate.getDate());
        //convert month to 2 digits
        var twoDigitMonth = (((fullDate.getMonth() + 1).toString().length) == 2)? (fullDate.getMonth()+1) : '0' + (fullDate.getMonth()+1);
        todayDateText = twoDigitDate + "-" + twoDigitMonth + "-" + fullDate.getFullYear();


        dateText = todayDateText;


        //initialize datepicker
       $('#searchCasesDatePicker').attr('readonly', true);

        $('#searchCasesDatePicker').datepicker({dateFormat: 'dd-mm-yy'});
//        resetDatePicker();
        clearSearchText();
        
        window.sessionStorage.setItem("SESSION_BACKLINK", "my_cases_hc.html");
        $("#datewise").click(function() {                    
            if(sessionStorage.getItem("DATEWISE") == "false"){
                sessionStorage.setItem("DATEWISE", "true");
                 if (cnrNumbersArray.length != 0){
                    updateAllCasesAcordion(cnrNumbersArray);
                 }
            }
        });

        $("#districtwise").click(function() {  
            if(sessionStorage.getItem("DATEWISE") == "true"){
                sessionStorage.setItem("DATEWISE", "false"); 
                cnrNumbersArray = JSON.parse(localStorage.getItem("CNR Numbers HC"));
                 if (cnrNumbersArray.length != 0){
                    updateAllCasesAcordion(cnrNumbersArray);
                 }
            }
        });
        if (cnrNumbersLocalStorage !== null) {
            if (cnrNumbersArray.length != 0) {
                updateAllCasesAcordion(cnrNumbersArray);
                /*updates todays cinos array in local storage
                  updates TODAYS_SAVED_CASES in local storage for today's cases
                */
                updateTodaysCinosArray(cnrNumbersArray);                
                $("#searchInMyCasesDivId").show();
            } else {
                //If no cases are saved in local storage
                $("#showCaseDiv").hide();
                $("#searchInMyCasesDivId").hide();
            }

        } else {
            $("#showCaseDiv").hide();   
            $("#searchInMyCasesDivId").hide();
        }
        //Initially datepicker is not displayed, it's displayed for todays's cases
        $("#searchCasesDivId1").hide();
        
        //Updates count for today's cases from local storage
        if(localStorage.getItem('TODAYS_SAVED_CASES_HC') != null){
            document.getElementById("todays_cases_span_id").innerHTML = JSON.parse(localStorage.getItem('TODAYS_SAVED_CASES_HC')).length;
        }else{
            document.getElementById("todays_cases_span_id").innerHTML = '0';
        }
        
        setCalendarCountArr(cnrNumbersArray);
//        resetDatePicker();
        $('#loadingMyCases').modal('hide');
    //});
	}

    $("#exportCasesWarning").on("click", function (e) {  
        $("#share_info").show();
        $("#share_info_import").hide();
        $('.exportandimport').trigger('focus');
    });

    //clear My cases search text box
    function clearSearchText(){        
        $("#searchInMyCases").val("");
    }

    //resets date picker to today's date
    function resetDatePicker(){
                
        showDatePicker();
        updatepicker();
        var now = new Date();

        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);

        var today = (day) + "-" + (month) + "-" + now.getFullYear();
        $('#searchCasesDatePicker').val(today);

        var dateVal = today;
        dateText = dateVal;
    }


    $("#searchCasesButton").focusout(function(){
        
        if(!($("#todaysCasesBtn").hasClass("active"))){
            resetDatePicker();
            $("#searchCasesButton").click();    
        }
    });

    //search for cases for date selected in datepicker
    $("#searchCasesButton").on("click", function(e){ 
        //get date
        var dateVal = $('#searchCasesDatePicker').val();
        dateText = dateVal;
        var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
        if(cnrNumbersLocalStorage != null){
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
            updateTodaysCinosArray(cnrNumbersArray);
           if(($("#todaysCasesBtn").hasClass("active"))){       updateTodaysCasesAcordion(JSON.parse(window.localStorage.TODAYS_SAVED_CASES_HC));
            }else{
                updateAllCasesAcordion(cnrNumbersArray);
            }
        }

    });

    /*updates TODAYS_SAVED_CASES in local storage for cases of date selected in datepicker*/
    function updateTodaysCinosArray(cnrNumbersArray){
        localStorage.removeItem('TODAYS_SAVED_CASES_HC');
        
        var todays_cinos_array = [];
        
        for (var i = 0; i < cnrNumbersArray.length; i++) {
                
                var caseInfo = JSON.parse(cnrNumbersArray[i]);
                
                if(caseInfo.date_last_list){
                var newcaseHistoryay1 = caseInfo.date_last_list.split('-');                            
                 date_last_list = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);//caseHistory.date_last_list;
                }else{
                     date_last_list = '';
                }
                if(caseInfo.date_next_list){
                if(caseInfo.date_next_list =='Date Not Given')
                    {   
                     date_next_list= caseInfo.date_next_list;  
                    } 
                    else
                    {
                     var newcaseHistoryay2 = caseInfo.date_next_list.split('-');                            
                        date_next_list = (newcaseHistoryay2[2] + "-" + newcaseHistoryay2[1] + "-" + newcaseHistoryay2[0]);   
                    }
                

                }else{
                    date_next_list = '';
                }        
                if(date_next_list == dateText || date_last_list == dateText){

                    todays_cinos_array.push(cnrNumbersArray[i]);
                }
            }
        localStorage.setItem('TODAYS_SAVED_CASES_HC', JSON.stringify(todays_cinos_array));
    }

/*updates TODAYS_SAVED_CASES in local storage for cases of date selected in datepicker*/
            function updateSelectedDateCinosArray(cnrNumbersArray){
                localStorage.removeItem('TODAYS_SAVED_CASES_HC');

                var todays_cinos_array = [];
                
                for (var i = 0; i < cnrNumbersArray.length; i++) {

                        var caseInfo = JSON.parse(cnrNumbersArray[i]);

                        if(caseInfo.date_last_list){
                        var newcaseHistoryay1 = caseInfo.date_last_list.split('-');                            
                         date_last_list = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);//caseHistory.date_last_list;
                        }else{
                             date_last_list = '';
                        }
                        if(caseInfo.date_next_list){
                        var newcaseHistoryay2 = caseInfo.date_next_list.split('-');                            
                         date_next_list = (newcaseHistoryay2[2] + "-" + newcaseHistoryay2[1] + "-" + newcaseHistoryay2[0]);

                        }else{
                            date_next_list = '';
                        }
                     
                    if(date_next_list == dateText || date_last_list == dateText){
                            todays_cinos_array.push(cnrNumbersArray[i]);
                        }
                    }
                
                localStorage.setItem('TODAYS_SAVED_CASES_HC', JSON.stringify(todays_cinos_array));
            }

    //To show case history of selected case
    $(document).on('click', '.show_case_history_link', function (e) {
        e.preventDefault();
        sessionStorage.setItem("tab", "#Tab4");
        var ciNumber = $(this).attr('cino');
        var connected = $(this).attr('isConnected');
        var caseno = $(this).attr('case_no');
        var data = {cino:(ciNumber)};
        window.sessionStorage.removeItem("case_history");
        var caseHistoryWsUrl = hostIP + "caseHistoryWebService.php";
            callToWebService(caseHistoryWsUrl, data, myCasesHistorySearchResult);
            function myCasesHistorySearchResult(data){
            if(data.history){
                var decodedResponse = (data.history);
                if(decodedResponse){
                    window.sessionStorage.setItem("case_history", JSON.stringify(decodedResponse));
                    window.sessionStorage.setItem("SESSION_SHOW_REMOVE", true);
                    window.sessionStorage.setItem("CINO", (ciNumber));
                    myApp.hidePleaseWait();
                    //window.location = 'case_history_hc.html?flag=' + true+'&cino=' + ciNumber+'&caseno=' + caseno;
                    $.ajax({
                        type: "GET",
                        url: "case_history_hc.html?flag=" + true
                    }).done(function(data) { 
                        $("#caseHistoryModal_hc").show();
                        $("#historyData_hc").html(data);
                        $("#caseHistoryModal_hc").modal();
                    });
                }else{
                    myApp.hidePleaseWait();
                    window.sessionStorage.setItem("SESSION_SHOW_REMOVE", true);
                    window.sessionStorage.setItem("CASE_NOT_EXIST", true);
                    window.sessionStorage.setItem("CASE_NOT_EXIST_CINO", ciNumber);
                    window.sessionStorage.setItem("CASE_NOT_EXIST_CASENO", caseno);
                    //window.location = 'case_history_hc.html?caseNotExist=' + true + '&caseNotExistCino='+ciNumber;
                    $.ajax({
                        type: "GET",
                        url: "case_history_hc.html?flag=" + true
                    }).done(function(data) { 
                        $("#caseHistoryModal_hc").show();
                        $("#historyData_hc").html(data);
                        $("#caseHistoryModal_hc").modal();
                    });
                }
                if(connected == "false"){
                     updateResetFlag(ciNumber);
                }
            }else{
                myApp.hidePleaseWait();
                window.sessionStorage.setItem("SESSION_SHOW_REMOVE", true);
                window.sessionStorage.setItem("CASE_NOT_EXIST", true);
                window.sessionStorage.setItem("CASE_NOT_EXIST_CINO", ciNumber);
                window.sessionStorage.setItem("CASE_NOT_EXIST_CASENO", caseno);
                //window.location = 'case_history_hc.html?flag=' + true+'&cino=' + ciNumber+'&caseno=' + caseno;
                $.ajax({
                    type: "GET",
                    url: "case_history_hc.html?flag=" + true
                }).done(function(data) { 
                    $("#caseHistoryModal_hc").show();
                    $("#historyData_hc").html(data);
                    $("#caseHistoryModal_hc").modal();
                });
            }
        }
    });



    /*This function updates 'updated' flag in local storage 
     *@param {cinumber} cinumber whose 'updated' flag was false, will be updated to true since this case connection was successful.
    */
    function updateResetFlag(cinumber){
        var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
        var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
        var index = cnrNumbersArray.containsSubStringOrHasSubstringOf( cinumber);
        if(index != -1){
            var jsonobj = JSON.parse(cnrNumbersArray[index]);
            jsonobj.updated = true;
            cnrNumbersArray[index] = JSON.stringify(jsonobj);
            localStorage.setItem("CNR Numbers HC", JSON.stringify(cnrNumbersArray));
        }
    }

    /*
      This method will reconnect all saved cinumbers to respective establishments and fetch latest data of following 25 parameters
        type_name
        case_no
        reg_year
        reg_no
        reg_year
        reg_no
        fil_year
        fil_no
        petparty_name
        resparty_name
        fil_year
        fil_no
        fil_year
        fil_no
        establishment_name
        establishment_code
        state_code
        district_code
        state_name
        district_name
        date_next_list
        date_of_decision
        date_last_list
        date_last_list
        updated
        court_no_desg_name
        
        It also updates TODAYS_SAVED_CASES accordingly 
        
    */
    function onRefreshClick() {
        clearSearchText();
        var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
        var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
        /*replica of cnr numbers array from local storage
          This is used to identify which CNR numbers connection was successful.
          Those CNR numbers will be removed from this array
          At the end of this function, this array should contain only the cases that are not updated.
        */
        var cnrNumbersArray_new = JSON.parse(cnrNumbersLocalStorage);

        if (cnrNumbersLocalStorage !== null) {

            var cnrNumbers = "";
            for (var i = 0; i < cnrNumbersArray.length; i++) {
                var caseInfo = JSON.parse(cnrNumbersArray[i]);

                var cino = caseInfo.cino;//cnrNumbersArray[i];
                cnrNumbers += (i !== 0 ? "," : "") + cino;

            }
            var cnrNumbers_array = cnrNumbers.split(',');
            if (cnrNumbers != "") {
                var allCasesUrl = hostIP + "todaysCasesWebService.php";                    
                var data = {cnr_numbers:(cnrNumbers.toString()), action_code:('list'), version_number:(window.sessionStorage.CURRENT_APP_VERSION)};
                //Removed all cases from local storage
                $('#loadingMyCases').modal('show');
                callToWebTodaysCasesServicehc(allCasesUrl,data,hctodaysCasesWebServiceResult);
                function hctodaysCasesWebServiceResult(data){
//                    if (status == "success") {
                        panel_id = 'panel_id';
                        if(data.todaysCiNos){ 
                        var decoded_todaysCiNos = (data.todaysCiNos);
                        
                        if(decoded_todaysCiNos && decoded_todaysCiNos!=null){
                            $.each(decoded_todaysCiNos, function (key, val) {                            
                                var index = cnrNumbersArray.containsSubStringOrHasSubstringOf(val.cino);
                                if(index != -1){
                                    var jsonobj = JSON.parse(cnrNumbersArray[index]);
                                    jsonobj.type_name = val.type_name;
                                    jsonobj.case_no = val.case_no;
                                    jsonobj.reg_year = val.reg_year;
                                    jsonobj.reg_no = val.reg_no;
                                    jsonobj.date_next_list = val.date_next_list;
                                    jsonobj.date_last_list = val.date_last_list;
                                    jsonobj.date_of_decision = val.date_of_decision;
                                    jsonobj.updated = true;
                                    jsonobj.court_no_desg_name = val.desgname;

                                    jsonobj.purpose_name = val.purpose_name;    
                                    jsonobj.disp_name = val.disp_name;                                
                                    cnrNumbersArray[index] = JSON.stringify(jsonobj);
                                } 
                                /*
                                check the same case in replica of CNR array and remove that case from this array so that this array should only contain not updated cases
                                */
                                
                                var index_posted = cnrNumbersArray_new.containsSubStringOrHasSubstringOf(val.cino);
                                if(index_posted != -1){

                                    cnrNumbersArray_new.splice(index_posted, 1);
                                }
                            });
                        } 
                        }
                        
                         //This loops changes updated flag to false for not connected cases
                        
                            $.each(cnrNumbersArray_new, function (key, val) {                                
                                var jsonobj = JSON.parse(val); 
                                var substr = jsonobj.cino;
                                var index = cnrNumbersArray.containsSubStringOrHasSubstringOf( substr.trim());
                                if(index != -1){
                                    jsonobj.updated = false;
                                   cnrNumbersArray[index] = JSON.stringify(jsonobj);

                                }
                            });
                        if(data.deletedCiNos){
                            var deletedCiNos = (data.deletedCiNos);
                            $.each(deletedCiNos, function (key, val) {                            
                                var index = cnrNumbersArray.containsSubStringOrHasSubstringOf(val.cino);
                                if(index != -1){
                                    var jsonobj = JSON.parse(cnrNumbersArray[index]);                                
                                    jsonobj.updated = 'falseDeleted';                                
                                    cnrNumbersArray[index] = JSON.stringify(jsonobj);
                                }                            
                            });                        
                        }
                        
                        if(data.recordNotFoundCiNos){ 
                        var recordNotFoundCiNos = (data.recordNotFoundCiNos);
                        
                        $.each(recordNotFoundCiNos, function (key, val) {                            
                            var index = cnrNumbersArray.containsSubStringOrHasSubstringOf(val.cino);
                            if(index != -1){
                                var jsonobj = JSON.parse(cnrNumbersArray[index]);
                                jsonobj.updated = 'falseRNF';                                
                                cnrNumbersArray[index] = JSON.stringify(jsonobj);
                            }                            
                        });                        
                        }

                        cnrNumbersArray = removeDumplicateValue(cnrNumbersArray);
                        
                        //display updated cases in My cases and Today's cases tab
                        if (cnrNumbersArray.length > 0) {
                            localStorage.setItem("CNR Numbers HC", JSON.stringify(cnrNumbersArray));
                            updateTodaysCinosArray(cnrNumbersArray);
                            if ($("#allCasesBtn").hasClass("active")) {
                                updateAllCasesAcordion(cnrNumbersArray);
                            } else if ($("#todaysCasesBtn").hasClass("active")) {                            updateTodaysCasesAcordion(JSON.parse(window.localStorage.TODAYS_SAVED_CASES_HC));
                            }
                            setCalendarCountArr(cnrNumbersArray);
                        }
//                    }
//                    else if (status == "timeout") {
//                        showErrorMessage("Request timed out");
//                    }
                    $('#loadingMyCases').modal('hide');
                }
            }
        }    
    }

    
    Array.prototype.containsSubStringOrHasSubstringOf = function( text ){
            for ( var i = 0; i < this.length; ++i )
            {
                if (    this[i].toString().indexOf( text.toString() ) != -1
                     || text.toString().indexOf( this[i].toString() ) != -1 )
                    return i;
            }
            return -1;
        }

    

    // Called on My Cases button click
    function showAllCases() {
        //To reset date picker to today's date
        resetDatePicker();
        $("#searchCasesButton").click();
        $("#sortDropdownDiv").show();
        
        $("#nocases").hide();
        $("#allCasesBtn").addClass("active");
        $("#todaysCasesBtn").removeClass("active");
        $("#refresh").show();
        //hide datepicker div
        $("#searchCasesDivId1").hide();      
        $("#searchInMyCasesDivId").show();       
        document.getElementById("mycases_span_id").innerHTML = (JSON.parse(localStorage.getItem("CNR Numbers HC"))).length;
        //show all cases div
        document.getElementById("ditrictsAccordion").style.display = "block";
        //hide Today's cases div
        document.getElementById("accordion").style.display = "none";
        if(cnrArrModified){
            populateDistrictAcordion(JSON.parse(localStorage.getItem("CNR Numbers HC")), sessionStorage.DATEWISE);
            cnrArrModified = false;
        }
    }

    /*For My cases.. Called while loading screen, refresh button click, search cases (date picker) click and after import from main.js.*/
    function updateAllCasesAcordion(cnrNumbersArray) {
        $("#searchCasesDivId1").hide();
        var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
        if(cnrNumbersLocalStorage){
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);            
            if(cnrNumbersArray.length!=0){
                $("#searchInMyCasesDivId").show();
                populateDistrictAcordion(cnrNumbersArray, sessionStorage.DATEWISE);
            }else{
                    $("#showCaseDiv").hide();                     
                    $("#searchInMyCasesDivId").hide();
                    document.getElementById("ditrictsAccordion").style.display = "none";
                    document.getElementById("accordion").style.display = "none";
                    document.getElementById("mycases_span_id").innerHTML = "0";
                    $("#exportCasesWarning").hide();
                  
            }
        }
        
        
    }


    //Populates and sorts My cases(All cases) panels
    function populateDistrictAcordion(cnrNumbersArray, datewise) {
        var cntNotRefreshed = 0;
        var notRefreshedCases = {};
        if(cnrNumbersArray){         
            $("#searchInMyCasesDivId").show();
        }else{            
            $("#searchInMyCasesDivId").hide();
        }
        
        datewise = window.sessionStorage.DATEWISE;
        document.getElementById("ditrictsAccordion").style.display = "block";
        document.getElementById("accordion").style.display = "none";
        $("#ditrictsAccordion").empty();

        $("#showCaseDiv").show();
        $("#searchInMyCasesDivId").show();

        if(datewise == "true"){             
            datewiseCNRNumbers = cnrNumbersArray;
            document.getElementById("mycases_span_id").innerHTML = cnrNumbersArray.length;

            
            
            //sorted array by state_code
            dates = cnrNumbersArray.reduce(function (dates, current) {
                var caseInfo = JSON.parse(current);
                var dtStr = "";
                var dtOfDecision = caseInfo.date_of_decision; 
                    if(dtOfDecision != null){
                            dtStr = "<h4 style = 'color:#e88787;display:inline;margin-right:10px;font-size:1rem;'>Disposed Cases</h4>";
                            var dt = caseInfo.date_of_decision.split('-');
                            var decisiondt = dt[2]+"-"+dt[1]+"-"+dt[0];
                            dates[dtStr] = dates[dtStr] || [];
                            dates[dtStr].push(current);
                            if(dateText === decisiondt){
                                dt = caseInfo.date_of_decision.split('-');
                                dtStr = (dt[2] + "-" + dt[1] + "-" + dt[0]);
                                dates[dtStr] = dates[dtStr] || [];
                                dates[dtStr].push(current);
                            }
                        }    
                    else if(caseInfo.date_next_list == null || caseInfo.date_next_list == "Date Not Given" || caseInfo.date_next_list == "Next Date Not Given"){
                        dtStr = "<h4 style = 'color:#e88787;display:inline;margin-right:10px;font-size:1rem;'>Date Not Given</h4>";  
                        dates[dtStr] = dates[dtStr] || [];
                        dates[dtStr].push(current);
                    }else {
                        dt = caseInfo.date_next_list.split('-');
                                          
                        var next_date_time = new Date(dt[0],dt[1]-1,dt[2]).getTime();
                        var d = new Date();

                        var month = d.getMonth()+1;
                        var day = d.getDate();

                        var output = d.getFullYear() + '/' +
                            (month<10 ? '0' : '') + month + '/' +
                            (day<10 ? '0' : '') + day;                        
                        
                        if((new Date(next_date_time) < new Date(output)) && (dtOfDecision == null)){                            
                            dtStr = "<h4 style = 'color:#e88787;display:inline;margin-right:10px;font-size:1rem;'>Undated Cases</h4>"; 
                            dates[dtStr] = dates[dtStr] || [];
                            dates[dtStr].push(current);
                        }else{
                            var dtlastStr = "";
                            if(caseInfo.date_last_list){
                                dtlast = caseInfo.date_last_list.split('-');
                                dtlastStr = (dtlast[2] + "-" + dtlast[1] + "-" + dtlast[0]);
                            }
                            
                            if(dtlastStr == dateText){
                                dates[dtlastStr] = dates[dtlastStr] || [];
                                dates[dtlastStr].push(current);    
                                var nextdt = dt[2]+"-"+dt[1]+"-"+dt[0];
                                if(dateText != nextdt){
                                    dt = caseInfo.date_next_list.split('-');
                                    dtStr = (dt[2] + "-" + dt[1] + "-" + dt[0]);
                                    dates[dtStr] = dates[dtStr] || [];
                                    dates[dtStr].push(current);
                                }
                            }else{
                                dt = caseInfo.date_next_list.split('-');
                                dtStr = (dt[2] + "-" + dt[1] + "-" + dt[0]);
                                dates[dtStr] = dates[dtStr] || [];
                                dates[dtStr].push(current);
                            }
                        }
                    } 

                return dates;

            }, {});

            var panel_body = [];

            var pid = 1;
            var establishmentsPanelId = 1;

            $.each(dates, function (index, value) {
                var showErrorIcon = false;
                pid = pid + 1;

                var caseInfoJson = value[0];

                var caseInfo = JSON.parse(caseInfoJson);
                state_name = caseInfo.state_name;
                district_name = caseInfo.district_name;
                panel_id = caseInfo.district_code;
                length = dates[index].length;
                                
                panel_body.push('<div class="panel-group-main1">');
                panel_body.push('<div class="" id="panel' + panel_id + '">');
                panel_body.push('<div class="card">');
                panel_body.push('<div class="card-header">');
                panel_body.push('<h4 class="panel-title">');
                
                panel_body.push('<a class="card-link collapsed panel-title-a panel-title-a-main" data-toggle="collapse" data-parent="#panel' + panel_id + '" href="#abc_' + pid + '"><span class="cc_name">' + index + '  (' + length + ')' +  '</span><span id="error' + pid + '" class = "error_panel" show="false"><img src="images/error.png"/></span></a>');
                panel_body.push('</h4></div></div></div>');
                
                $.each(dates[index], function (index2, value) {
                    //sorting by establishment code
                    establishmentsArr = dates[index].reduce(function (establishmentsArr, current) {
                        var caseInfo = JSON.parse(current);
                        establishmentsArr[caseInfo.establishment_code] = establishmentsArr[caseInfo.establishment_code] || [];
                        establishmentsArr[caseInfo.establishment_code].push(current);

                        return establishmentsArr;

                    }, {});
                });

                    panel_body.push('<div id="abc_' + pid + '" class="collapse" data-parent="#panel' + panel_id + '">');
                    panel_body.push('<div class="card-body">');
                    panel_body.push('<div class="panel-group panel-group-main" id="accordion21">');

                    //Establishment panel for each district
                    $.each(establishmentsArr, function (index, value) {

                        var caseInfoJson = establishmentsArr[index][0];

                        var caseInfo = JSON.parse(caseInfoJson);
                        
                        est_name = caseInfo.establishment_name;
                        est_code = caseInfo.establishment_code;


                        est_arr_length = establishmentsArr[index].length;

                        panel_body.push('<div class="card">');
                        panel_body.push('<div class="card-header">');
                        panel_body.push('<h4 class="panel-title">');
                        panel_body.push('<a style="background-color:#7AC5CD;" class="card-link collapsed panel-title-a" data-toggle="collapse" href="#collapseTwoOne' + establishmentsPanelId + '">' + est_name + '(' + est_arr_length + '), '+ caseInfo.district_name + '</a>');

                        panel_body.push('</h4>');
                        panel_body.push('</div>');
                        panel_body.push('<div id="collapseTwoOne' + establishmentsPanelId + '" class="collapse show" data-parent="#accordion21">');
                        panel_body.push('<div class="card-body context"><table class="table tbl-result"><thead><tr><th>Next/ Disposal Date</th><th>Case Number</th><th>Party Name</th></tr></thead><tbody>');

                        var cnt = 0;
                        var weekday=new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sa");
                        const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",""];
                        //Cases tables for each establishement
                        $.each(establishmentsArr[index], function (index3, value) {


                            var caseInfoJson = value;

                            var caseInfo = JSON.parse(caseInfoJson);

                            length = establishmentsArr[index].length;

                            cnt++;

                            var cino = caseInfo.cino;//cnrNumbersArray[i];

                            var org_type = cino.slice(0, 6);
                            var serialNo = cino.slice(6, 12);
                            var ciyear = cino.slice(12, 16);
                            var disp_ci_no = org_type + '-' + serialNo + '-' + ciyear;
                            var caseTypeNumber = '';
                            
                            if (caseInfo.case_no != null) {
                                caseTypeNumber = caseInfo.type_name + "/" + caseInfo.reg_no + "/" + caseInfo.reg_year;
                            } else {
                                caseTypeNumber = caseInfo.type_name + "/" + caseInfo.fil_no + "/" + caseInfo.fil_year;
                            }

                            var dateOfDecision = caseInfo.date_of_decision;
                            var d = new Date();
                            var curryear = d.getFullYear();
                            var diffyear = curryear - caseInfo.reg_year;
                            var petResName = '';

                            petResName = caseInfo.petparty_name + " Vs " + caseInfo.resparty_name;
                            var hrefurl = "";
                            var mycolor = '';
                            var courtNoDesgName="";
                            if(caseInfo.court_no_desg_name){
                                courtNoDesgName = (caseInfo.court_no_desg_name == null ? "" : "<br>" +caseInfo.court_no_desg_name );
                            }
                            
                            if (caseInfo.date_of_decision == null)
                            {

                                hrefurl = "<a style='color:#03A8D8;text-decoration: underline;' href='#' class='show_case_history_link  'cino='" + cino + "'isConnected='" + caseInfo.updated + "'case_no='" +  caseTypeNumber + "'>" + cnt +")"+ caseTypeNumber + '</a>';

                                if (diffyear <= 2)
                                {
                                    mycolor = 'style="background-color:#AED6F1  !important;"';
                                } else if (diffyear > 2 && diffyear < 5)
                                {
                                    mycolor = 'style="background-color:#bbffbb  !important;"';
                                } else if (diffyear >= 5 && diffyear < 10)
                                {
                                    mycolor = 'style="background-color:#ffff88  !important;"';
                                } else if (diffyear >= 10)
                                {
                                    mycolor = 'style="background-color:#ffbcbc  !important;"';
                                }
                            } else {

                                hrefurl = "<a style='color:#ff0000;text-decoration: underline;' href='#' class='show_case_history_link  'cino='" + cino + "'isConnected='" + caseInfo.updated + "'case_no='" + caseTypeNumber + "'>" + cnt +")"+ caseTypeNumber + '</a>';

                            }

                            var updatedStr = "";

                            if(caseInfo.updated == false){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Unable to Check</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }else if(caseInfo.updated=='falseDeleted'){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Case Deleted</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }else if(caseInfo.updated=='falseRNF'){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Case not Found</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }

                            notRefreshedCases["error"+pid] = showErrorIcon;

                            var dateStr = '';

                            if(caseInfo.date_next_list){
                                if(caseInfo.date_next_list =='Date Not Given' || caseInfo.date_next_list == "Next Date Not Given")
                                {   
                                    dateStr='No Date';
                                    var days='<i style="font-size:10px;margin-top:1px;">'+dateStr+'</i>';
                                    var month=12;
                                    var year='';
                                } 
                                else
                                {
                                    var newcaseHistoryay1 = caseInfo.date_next_list.split('-');
                                    dateStr = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);  
                                    var newdt=newcaseHistoryay1[0]+'/'+newcaseHistoryay1[1]+'/'+newcaseHistoryay1[2];
                                    var dt=new Date(newdt);
                                   
                                    var dayName=dt.getDay();
                                    var days=dt.getDate();
                                    var month=dt.getMonth();
                                    var year=dt.getFullYear();
                                }

                            }else if(caseInfo.date_of_decision){
                                var newcaseHistoryay1 = caseInfo.date_of_decision.split('-');
                                dateStr = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]); 
                                var newdt=newcaseHistoryay1[0]+'/'+newcaseHistoryay1[1]+'/'+newcaseHistoryay1[2];
                                var dt=new Date(newdt);
                               
                                var dayName=dt.getDay();
                                var days=dt.getDate();
                                var month=dt.getMonth();
                                var year=dt.getFullYear();
                            }
                            else{
                                dateStr='No Date';
                                var days='<i style="font-size:10px;margin-top:1px;">'+dateStr+'</i>';
                                var month=12;
                                var year='';
                            }
                            noteVar = caseInfo.note ? caseInfo.note : "";
                            disp_name = caseInfo.disp_name ? caseInfo.disp_name : "";
                            stage_of_case = caseInfo.purpose_name ? caseInfo.purpose_name : "";
                            /**To remove the Numbers from 'stage_of_case' eg. 192-NOTICE & ADJOURNED MATTERS... */
                            var str_dash = "-";
                            if(stage_of_case.match(/[0-9]/g) && stage_of_case.indexOf(str_dash) != -1){
                                var stageofcase = stage_of_case.replace(/[0-9]/g, '');
                                stage_of_case=stageofcase.slice(1);                             
                            }
                           
                            if(noteVar != ""){
                                if (caseInfo.date_of_decision != null){
                                    var d='Disposed';
                                    if(caseInfo.case_no == null){
                                        d='Disposed F';
                                    }
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-danger' style='font-size: 60%;'>"+d+"</span></time><br></td><td>" + hrefurl + "<a href='#' class = 'noteIcon' id='Chevron_icon_img1' note=\'" + caseInfo.note + "\' onclick=\'\'><img src='images/chevron.png' style='display:inline-block;margin-left: 5px;' id='Chevron_icon1'/></a>" + courtNoDesgName + "<br><span class='badge badge-danger1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+disp_name+"</span><br>" +updatedStr + "" + "</td><td>" +petResName  + "</td></tr>");
                                }else{
                                    if(!monthNames[month]){
                                        monthNames[month] = "";
                                    }
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-success' style='font-size: 65%;'>Pending</span></time><br></td><td>" + hrefurl + "<a href='#' class = 'noteIcon' id='Chevron_icon_img1' note=\'" + caseInfo.note + "\' onclick=\'\'><img src='images/chevron.png' style='display:inline-block;margin-left: 5px;' id='Chevron_icon1'/></a>" +courtNoDesgName + "<br><span class='badge badge-success1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+stage_of_case+"</span><br>" +updatedStr + "</td><td>" + petResName + "</td></tr>");
                                }
                            }else{
                                trHTML += "<tr class='trSelected'><td>" + cnt + "</td><td>" + hrefurl + "<time  class='date-as-calendar position-pixels'><span class='month'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span></time>" + "<br>" +updatedStr+ "</td><td>" + petResName + "</td></tr>";
                                if (caseInfo.date_of_decision != null){
                                    var d='Disposed';
                                    if(caseInfo.case_no == null){
                                        d='Disposed F';
                                    }
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-danger' style='font-size: 60%;' >"+d+"</span></time></td><td>" + hrefurl +courtNoDesgName + "<br><span class='badge badge-danger1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+disp_name+"</span><br>" +updatedStr + "" + "</td><td>" +petResName  + "</td></tr>");
                                }else{
                                    if(!monthNames[month]){
                                        monthNames[month] = "";
                                    }
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-success' style='font-size: 65%;'>Pending</span></time></td><td>" + hrefurl + courtNoDesgName + "<br><span class='badge badge-success1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+stage_of_case+"</span><br>" +updatedStr + "</td><td>" + petResName + "</td></tr>");
                                }
                            }

                        });
                        establishmentsPanelId++;
                        panel_body.push('</tbody>');
                        panel_body.push('</table>');
                        panel_body.push('</div>');
                        panel_body.push('</div>');
                        panel_body.push('</div>');

                        est_code = index;
                        var trHTML = '';


                    });
                    panel_body.push(' </div></div></div></div></div>');

            });    
             panel_body.push(' </div>');
            
        }else{
            document.getElementById("mycases_span_id").innerHTML = cnrNumbersArray.length;

            datewiseCNRNumbers = cnrNumbersArray;
            
            
            //sorted array by state_code
            states = cnrNumbersArray.reduce(function (states, current) {
                var caseInfo = JSON.parse(current);
                states[caseInfo.state_code] = states[caseInfo.state_code] || [];
                states[caseInfo.state_code].push(current);

                return states;

            }, {});

            var panel_body = [];

            var pid = 1;
            var establishmentsPanelId = 1;
            var districts = [];
        $.each(states, function (index, value) {
            //sorting by district code
            districts = states[index].reduce(function (districts, current) {
                var caseInfo = JSON.parse(current);
                districts[caseInfo.district_code] = districts[caseInfo.district_code] || [];
                districts[caseInfo.district_code].push(current);

                return districts;

            }, {});

            $.each(districts, function (index, value) {
                var showErrorIcon = false;
                pid = pid + 1;

                var caseInfoJson = value[0];

                var caseInfo = JSON.parse(caseInfoJson);
                state_name = caseInfo.state_name;
                district_name = caseInfo.district_name;
                panel_id = caseInfo.district_code;
                length = districts[index].length;

                panel_body.push('<div class="panel-group-main1">');
                panel_body.push('<div class="" id="panel' + panel_id + '">');
                panel_body.push('<div class="card">');
                panel_body.push('<div class="card-header">');
                panel_body.push('<h4 class="panel-title">');

                panel_body.push('<a class="card-link collapsed panel-title-a panel-title-a-main" data-toggle="collapse" href="#abc_' + pid + '"><span class="cc_name">' + district_name + ',' + state_name + '  (' + length + ')' +  '</span><span id="error' + pid + '" class = "error_panel" show="false"><img src="images/error.png"/></span></a>');
                panel_body.push('</h4></div></div></div>');
                $.each(districts[index], function (index2, value) {
                    //sorting by establishment code
                    establishmentsArr = districts[index].reduce(function (establishmentsArr, current) {
                        var caseInfo = JSON.parse(current);
                        establishmentsArr[caseInfo.establishment_code] = establishmentsArr[caseInfo.establishment_code] || [];
                        establishmentsArr[caseInfo.establishment_code].push(current);

                        return establishmentsArr;

                    }, {});
                });

                    panel_body.push('<div id="abc_' + pid + '" class="collapse" data-parent="#panel' + panel_id + '">');
                    panel_body.push('<div class="card-body">');
                    panel_body.push('<div class="panel-group panel-group-main" id="accordion21">');

                    //Establishment panel for each district
                    $.each(establishmentsArr, function (index, value) {

                        var caseInfoJson = establishmentsArr[index][0];

                        var caseInfo = JSON.parse(caseInfoJson);  
                                           
                        est_name = caseInfo.establishment_name;
                        est_code = caseInfo.establishment_code;

                        est_arr_length = establishmentsArr[index].length;

                        panel_body.push('<div class="card">');
                        panel_body.push('<div class="card-header">');
                        panel_body.push('<h4 class="panel-title">');
                        panel_body.push('<a style="background-color:#7AC5CD;" class="card-link collapsed panel-title-a" data-toggle="collapse" href="#collapseTwoOne' + establishmentsPanelId + '">' + est_name + '(' + est_arr_length + ')' + '</a>');

                        panel_body.push('</h4>');
                        panel_body.push('</div>');
                        panel_body.push('<div id="collapseTwoOne' + establishmentsPanelId + '" class="collapse show" data-parent="#accordion21">');
                        panel_body.push('<div class="card-body context"><table class="table tbl-result"><thead><tr><th>Next/ Disposal Date</th><th>Case Number</th><th>Party Name</th></tr></thead><tbody>');

                        var cnt = 0;
                        var weekday=new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sa");
                        const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",""];

                        //Cases tables for each establishement
                        $.each(establishmentsArr[index], function (index3, value) {


                            var caseInfoJson = value;

                            var caseInfo = JSON.parse(caseInfoJson);

                            length = establishmentsArr[index].length;

                            cnt++;

                            var cino = caseInfo.cino;//cnrNumbersArray[i];

                            var org_type = cino.slice(0, 6);
                            var serialNo = cino.slice(6, 12);
                            var ciyear = cino.slice(12, 16);
                            var disp_ci_no = org_type + '-' + serialNo + '-' + ciyear;
                            var caseTypeNumber = '';
                            
                            if (caseInfo.case_no != null) {
                                caseTypeNumber = caseInfo.type_name + "/" + caseInfo.reg_no + "/" + caseInfo.reg_year;
                            } else {
                                caseTypeNumber = caseInfo.type_name + "/" + caseInfo.fil_no + "/" + caseInfo.fil_year;
                            }

                            var dateOfDecision = caseInfo.date_of_decision;
                            var d = new Date();
                            var curryear = d.getFullYear();
                            var diffyear = curryear - caseInfo.reg_year;
                            var petResName = '';

                            petResName = caseInfo.petparty_name + " Vs " + caseInfo.resparty_name;
                            var hrefurl = "";
                            
                            var mycolor = '';
                            var courtNoDesgName="";
                            if(caseInfo.court_no_desg_name){
                                courtNoDesgName = (caseInfo.court_no_desg_name == null ? "" : "<br>" +caseInfo.court_no_desg_name );
                            }

                            if (caseInfo.date_of_decision == null)
                            {

                                hrefurl = "<a style='color:#03A8D8;text-decoration: underline;' href='#' class='show_case_history_link  'cino='" + cino + "'isConnected='" + caseInfo.updated + "'case_no='" +  caseTypeNumber + "'>" + cnt +")"+ caseTypeNumber + '</a>';

                                if (diffyear <= 2)
                                {
                                    mycolor = 'style="background-color:#AED6F1  !important;"';
                                } else if (diffyear > 2 && diffyear < 5)
                                {
                                    mycolor = 'style="background-color:#bbffbb  !important;"';
                                } else if (diffyear >= 5 && diffyear < 10)
                                {
                                    mycolor = 'style="background-color:#ffff88  !important;"';
                                } else if (diffyear >= 10)
                                {
                                    mycolor = 'style="background-color:#ffbcbc  !important;"';
                                }
                            } else {

                                hrefurl = "<a style='color:#ff0000;text-decoration: underline;' href='#' class='show_case_history_link  'cino='" + cino + "'isConnected='" + caseInfo.updated + "'case_no='" + caseTypeNumber + "'>" + cnt +")"+ caseTypeNumber + '</a>';

                            }

                            var updatedStr = "";

                            if(caseInfo.updated == false){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Unable to Check</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }else if(caseInfo.updated=='falseDeleted'){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Case Deleted</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }else if(caseInfo.updated=='falseRNF'){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Case not Found</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }

                            notRefreshedCases["error"+pid] = showErrorIcon;

                            var dateStr = '';


                            if(caseInfo.date_next_list){
                                
                                if(caseInfo.date_next_list =='Date Not Given')
                                {   
                                 dateStr= caseInfo.date_next_list;
                                    dateStr='No Date';
                                    var days='<i style="font-size:10px;margin-top:1px;">'+dateStr+'</i>';
                                    var month=12;
                                    var year='';
                                } 
                                else
                                {
                                 var newcaseHistoryay1 = caseInfo.date_next_list.split('-');
                                dateStr = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
                                    var newdt=newcaseHistoryay1[0]+'/'+newcaseHistoryay1[1]+'/'+newcaseHistoryay1[2];
                                    var dt=new Date(newdt);
                                    var dayName=dt.getDay();
                                    var days=dt.getDate();
                                    var month=dt.getMonth();
                                    var year=dt.getFullYear();
                                }

                            }else if(caseInfo.date_of_decision){
                                var newcaseHistoryay1 = caseInfo.date_of_decision.split('-');
                                dateStr = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]); 
                                var newdt=newcaseHistoryay1[0]+'/'+newcaseHistoryay1[1]+'/'+newcaseHistoryay1[2];
                                var dt=new Date(newdt);
                                
                                var dayName=dt.getDay();
                                var days=dt.getDate();
                                var month=dt.getMonth();
                                var year=dt.getFullYear();
                            }else{
                                dateStr='No Date';
                                var days='<i style="font-size:10px;margin-top:1px;">'+dateStr+'</i>';
                                var month=12;
                                var year='';
                            }

                            noteVar = caseInfo.note ? caseInfo.note : "";
                            disp_name = caseInfo.disp_name ? caseInfo.disp_name : "";
                            stage_of_case = caseInfo.purpose_name ? caseInfo.purpose_name : "";
                            /**To remove the Numbers from 'stage_of_case' eg. 192-NOTICE & ADJOURNED MATTERS... */
                            var str_dash = "-";                            
                            if(stage_of_case.match(/[0-9]/g) && stage_of_case.indexOf(str_dash) != -1){
                                var stageofcase = stage_of_case.replace(/[0-9]/g, '');
                                stage_of_case=stageofcase.slice(1);                                
                           }
                            if(noteVar != ""){
                                if (caseInfo.date_of_decision != null){
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-danger' style='font-size: 60%;'>Disposed</span></time><br></td><td>" + hrefurl + "<a href='#' class = 'noteIcon' id='Chevron_icon_img1' note=\'" + caseInfo.note + "\' onclick=\'\'><img src='images/chevron.png' style='display:inline-block;margin-left: 5px;' id='Chevron_icon1'/></a>" + courtNoDesgName + "<br><span class='badge badge-danger1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+disp_name+"</span><br>" +updatedStr + "" + "</td><td>" +petResName  + "</td></tr>");
                                }else{
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-success' style='font-size: 65%;'>Pending</span></time><br></td><td>" + hrefurl + "<a href='#' class = 'noteIcon' id='Chevron_icon_img1' note=\'" + caseInfo.note + "\' onclick=\'\'><img src='images/chevron.png' style='display:inline-block;margin-left: 5px;' id='Chevron_icon1'/></a>" + courtNoDesgName + "<br><span class='badge badge-success1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+stage_of_case+"</span><br>" +updatedStr + "</td><td>" + petResName + "</td></tr>");
                                }
                            }else{
                                trHTML += "<tr class='trSelected'><td>" + cnt + "</td><td>" + hrefurl + "<time  class='date-as-calendar position-pixels'><span class='month'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span></time>" + "<br>" +updatedStr+ "</td><td>" + petResName + "</td></tr>";
                                if (caseInfo.date_of_decision != null){
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-danger' style='font-size: 60%;'>Disposed</span></time></td><td>" + hrefurl + courtNoDesgName + "<br><span class='badge badge-danger1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+disp_name+"</span><br>" +updatedStr + "" + "</td><td>" +petResName  + "</td></tr>");
                                }else{
                                    panel_body.push("<tr  class='trSelected'" + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month'  style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-success' style='font-size: 65%;'>Pending</span></time></td><td>" + hrefurl + courtNoDesgName + "<br><span class='badge badge-success1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+stage_of_case+"</span><br>" +updatedStr + "</td><td>" + petResName + "</td></tr>");
                                }
                            }

                        });
                        establishmentsPanelId++;
                        panel_body.push('</tbody>');
                        panel_body.push('</table>');
                        panel_body.push('</div>');
                        panel_body.push('</div>');
                        panel_body.push('</div>');

                        est_code = index;
                        var trHTML = '';


                    });
                    panel_body.push(' </div></div></div></div></div>');

            });    
             panel_body.push(' </div>');
            });
        }
        panel_body.push('</div></div></div></div></div></div>');


        $("#ditrictsAccordion").append(panel_body.join(""));
        
        
        var undatedId;
        var dateNotGivenId;
        var disposedId;

         var panelGroups = $("#ditrictsAccordion").find($(".panel-group-main1"));

        var panelgrouplength = panelGroups.length;
        for(var j = 0; j < panelgrouplength; j++){
            elements = $(panelGroups[j]).children().find(".panel-title-a-main");
            var elementsLength = elements.length;

            for(var i = 0; i < elementsLength; i++){
                var txt = $(elements[i]).text();
                if(txt.indexOf("Undated Cases") != -1){ 
                    undatedId = $(panelGroups[j]);
                    $(panelGroups[j]).remove();
                } 
                if(txt.indexOf("Date Not Given") != -1){
                    dateNotGivenId = $(panelGroups[j]);
                    $(panelGroups[j]).remove();
                } 
                if(txt.indexOf("Disposed Cases") != -1){
                    disposedId = $(panelGroups[j]);
                    $(panelGroups[j]).remove();
                }

            } 
        }


        //sorting
        var items = $(".panel-group-main1").sort(function(a, b) {
            
                var vA, vB;
                    
                if(datewise == "true"){       

                    var astrArrA = $(a).children().find(".panel-title-a-main").text().trim().split(' ');
                    var astrArrB = $(b).children().find(".panel-title-a-main").text().trim().split(' ');


                    var dtArrA = astrArrA[0].split('-');
                    var dtArrB = astrArrB[0].split('-');



                    vA = new Date(dtArrA[2],dtArrA[1]-1,dtArrA[0]).getTime();
                    vB = new Date(dtArrB[2],dtArrB[1]-1,dtArrB[0]).getTime();
                }
                else{
                    vA = $(a).children().find(".panel-title-a-main").text();
                    vB = $(b).children().find(".panel-title-a-main").text();
                }

            
            return (vA < vB) ? -1 : (vA > vB) ? 1 : 0;
        });
        $("#ditrictsAccordion").empty();
        $("#ditrictsAccordion").append(items);
        //sorting end
        
        if(datewise == "true"){    
            var panelGroups = $("#ditrictsAccordion").find($(".panel-group-main1"));
                
                var panelgrouplength = panelGroups.length;
                
                var prevMonth = "";
                var prevYear = "";
                
                var displayMonthDivider = false;
                
                for(var j = 0; j < panelgrouplength; j++){
                    elements = $(panelGroups[j]).children().find(".panel-title-a-main");
                    var elementsLength = elements.length;
                
                    for(var i = 0; i < elementsLength; i++){
                        
                        var txt = $(elements[i]).text();
                        var dt = txt.split('-');
                        
                        var currentMonth = dt[1];
                        var currentYear = dt[2].split(" ");                        
                        
                        if((prevYear != currentYear[0]) || (prevMonth != currentMonth)){
                            displayMonthDivider = true;
                            prevYear = currentYear[0];
                            prevMonth = currentMonth;  
                            
                            var displayMonth = getMonth(currentMonth);
                                                        
                            $(panelGroups[j]).before(' <div class="panel-group month_divider">'+displayMonth+ " " +currentYear[0]+'</div>');
                        }
                            
                        if(txt.indexOf("Undated Cases") != -1){ 
                            undatedId = $(elements[i]);
                            $(panelGroups[j]).remove();
                            $("#ditrictsAccordion").prepend($(panelGroups[j]));
                        } 
                        if(txt.indexOf("Date Not Given") != -1){
                            dateNotGivenId = $(elements[i]);
                            $(panelGroups[j]).remove();
                            $("#ditrictsAccordion").prepend($(panelGroups[j]));
                        } 
                        if(txt.indexOf("Disposed Cases") != -1){
                            disposedId = $(elements[i]);
                            $(panelGroups[j]).remove();
                            $("#ditrictsAccordion").prepend($(panelGroups[j]));
                        } 

                    } 
                }
        }
                $("#ditrictsAccordion").prepend(undatedId);
                $("#ditrictsAccordion").prepend(dateNotGivenId);
                $("#ditrictsAccordion").prepend(disposedId);
        
        
        if(cntNotRefreshed > 0){
        
            $("#ditrictsAccordion").append('<p style="font-weight:bold; color:#A93226;margin-right:5px;margin-top:10px;"><img src="images/cross.png" style="display:inline-block;"/>&nbsp;"Unable to Check" for '+cntNotRefreshed+' Case(s).<br/> Server may be busy</p>');
        }


        //Shows error icon on state,district panel if it contains Not connected cases
        $(".error_panel").each(function(i){
            if(notRefreshedCases[$(this).attr("id")]){
                document.getElementById($(this).attr("id")).style.display = 'inline-block';
            }
        });

         $('#loadingMyCases').modal('hide');
    }


    function getMonth(index){
                        
            var month = new Array();
            month[0] = "January";
            month[1] = "February";
            month[2] = "March";
            month[3] = "April";
            month[4] = "May";
            month[5] = "June";
            month[6] = "July";
            month[7] = "August";
            month[8] = "September";
            month[9] = "October";
            month[10] = "November";
            month[11] = "December";
            
            return month[index-1];
        }


    //Populates and sorts Todays cases panels
    function populateTodaysDistrictAcordion(cnrNumbersArray) {
        document.getElementById("ditrictsAccordion").style.display = "none";
        document.getElementById("accordion").style.display = "block";

        // var totalCNRCount = localStorage.getItem("CNR Numbers HC");
        // if(totalCNRCount != null){
        //     var total_cnr_Array = JSON.parse(totalCNRCount);
        //     document.getElementById("mycases_span_id").innerHTML = total_cnr_Array.length;
        // }
        // document.getElementById("mycases_span_id").innerHTML = cnrNumbersArray.length;
        
        $("#accordion").empty();


        states = cnrNumbersArray.reduce(function (states, current) {
            var caseInfo = JSON.parse(current);
            states[caseInfo.state_code] = states[caseInfo.state_code] || [];
            states[caseInfo.state_code].push(current);

            return states;

        }, {});

        var panel_body = [];

        var pid = 1;
        var establishmentsPanelId = 1;
        var districts = [];
    $.each(states, function (index, value) {

        districts = states[index].reduce(function (districts, current) {
            var caseInfo = JSON.parse(current);
            districts[caseInfo.district_code] = districts[caseInfo.district_code] || [];
            districts[caseInfo.district_code].push(current);

            return districts;

        }, {});

        $.each(districts, function (index, value) {
            pid = pid + 1;

            var caseInfoJson = value[0];

            var caseInfo = JSON.parse(caseInfoJson);
            state_name = caseInfo.state_name;
            district_name = caseInfo.district_name;
            panel_id = caseInfo.district_code;
            length = districts[index].length;

            panel_body.push('<div class="todays_panel-group-main1">');
            panel_body.push('<div class="" id="panel' + panel_id + '">');
            panel_body.push('<div class="card">');
            panel_body.push('<div class="card-header">');
            panel_body.push('<h4 class="panel-title">');

            panel_body.push('<a class="card-link collapsed panel-title-a panel-title-a-main" data-toggle="collapse" href="#todays_abc_' + pid + '">' + district_name + ',' + state_name + '  (' + length + ')' + '</a>');
            panel_body.push('</h4></div></div></div>');
            $.each(districts[index], function (index2, value) {

                var establishmentsArr = districts[index].reduce(function (establishmentsArr, current) {
                    var caseInfo = JSON.parse(current);
                    establishmentsArr[caseInfo.establishment_code] = establishmentsArr[caseInfo.establishment_code] || [];
                    establishmentsArr[caseInfo.establishment_code].push(current);

                    return establishmentsArr;

                }, {});

                panel_body.push('<div id="todays_abc_' + pid + '" class="collapse" data-parent="#panel' + panel_id + '">');
                panel_body.push('<div class="card-body">');
                panel_body.push('<div class="panel-group panel-group-main" id="todays_accordion21">');

                //Establishment panel for each district
                $.each(establishmentsArr, function (index, value) {

                    var caseInfoJson = establishmentsArr[index][0];

                    var caseInfo = JSON.parse(caseInfoJson);
                    
                    est_name = caseInfo.establishment_name;
                    est_code = caseInfo.establishment_code;


                    est_arr_length = establishmentsArr[index].length;

                    panel_body.push('<div class="card">');
                    panel_body.push('<div class="card-header">');
                    panel_body.push('<h4 class="panel-title">');
                    panel_body.push('<a style="background-color:#7AC5CD;" class="card-link collapsed panel-title-a" data-toggle="collapse" data-parent="#todays_accordion21" href="#collapseTwoOne' + establishmentsPanelId + '">' + est_name + '(' + est_arr_length + ')' + '</a>');

                    panel_body.push('</h4>');
                    panel_body.push('</div>');
                    panel_body.push('<div id="collapseTwoOne' + establishmentsPanelId + '" class="collapse show" data-parent="#todays_accordion21">');
                    panel_body.push('<div class="card-body"><table class="table tbl-result"><thead><tr><th>Next/ Disposal Date</th><th>Case Number</th><th>Party Name</th></tr></thead><tbody>');

                    var cnt = 0;
                    var weekday=new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sa");
                    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",""];

                    //Cases tables for each establishement
                    $.each(establishmentsArr[index], function (index3, value) {
                        var caseInfoJson = value;

                        var caseInfo = JSON.parse(caseInfoJson);

                        length = establishmentsArr[index].length;

                        cnt++;

                        var cino = caseInfo.cino;//cnrNumbersArray[i];

                        var org_type = cino.slice(0, 6);
                        var serialNo = cino.slice(6, 12);
                        var ciyear = cino.slice(12, 16);
                        var disp_ci_no = org_type + '-' + serialNo + '-' + ciyear;
                        var caseTypeNumber = '';
                        if (caseInfo.case_no != null) {
                            caseTypeNumber = caseInfo.type_name + "/" + caseInfo.reg_no + "/" + caseInfo.reg_year;
                        } else {
                            caseTypeNumber = caseInfo.type_name + "/" + caseInfo.fil_no + "/" + caseInfo.fil_year;
                        }

                        var dateOfDecision = caseInfo.date_of_decision;
                        var d = new Date();
                        var curryear = d.getFullYear();
                        var diffyear = curryear - caseInfo.reg_year;
                        var petResName = '';

                        petResName = caseInfo.petparty_name + " Vs " + caseInfo.resparty_name;
                        var hrefurl = "";

                        

                        var mycolor = '';
                        var courtNoDesgName="";
                        if(caseInfo.court_no_desg_name){
                            courtNoDesgName = (caseInfo.court_no_desg_name == null ? "" : "<br>" +caseInfo.court_no_desg_name );
                        }                        
                        
                        if (caseInfo.date_of_decision == null)
                        {

                            hrefurl = "<a style='color:#03A8D8;text-decoration: underline;' href='#' class='show_case_history_link  'cino='" + cino + "'isConnected='" + caseInfo.updated + "'case_no='" + caseTypeNumber + "'>" + cnt +")"+ caseTypeNumber + '</a>';
                            
                            if (diffyear <= 2)
                            {
                                mycolor = 'style="background-color:#AED6F1  !important;"';
                            } else if (diffyear > 2 && diffyear < 5)
                            {
                                mycolor = 'style="background-color:#bbffbb  !important;"';
                            } else if (diffyear >= 5 && diffyear < 10)
                            {
                                mycolor = 'style="background-color:#ffff88  !important;"';
                            } else if (diffyear >= 10)
                            {
                                mycolor = 'style="background-color:#ffbcbc  !important;"';
                            }
                        } else {
                            hrefurl = "<a style='color:#ff0000;text-decoration: underline;' href='#' class='show_case_history_link  'cino='" + cino + "'isConnected='" + caseInfo.updated + "'case_no='" + caseTypeNumber + "'>" + cnt +")"+ caseTypeNumber + '</a>';
                        }

                        var updatedStr = "";
                        if(caseInfo.updated){
                           updatedStr = ""; 
                        }else if(caseInfo.updated==false){
                            updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Unable to Check</h6>"; 
                        }else if(caseInfo.updated=='falseDeleted'){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Case Deleted</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }else if(caseInfo.updated=='falseRNF'){
                                updatedStr = "<h6 style = 'color:#d10606'><img src='images/cross.png' style = 'float:left'/>&nbsp;&nbsp;Case not Found</h6>"; 
                                cntNotRefreshed++;
                                showErrorIcon = true;
                            }

                        var dateStr = '';


                        if(caseInfo.date_next_list){
                            if(caseInfo.date_next_list =='Date Not Given')
                            {   
                                dateStr= caseInfo.date_next_list;  
                                dateStr='No Date';
                                var days='<i style="font-size:10px;margin-top:1px;">'+dateStr+'</i>';
                                var month=12;
                                var year='';
                            } 
                            else
                            {
                                var newcaseHistoryay1 = caseInfo.date_next_list.split('-');
                                dateStr = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]); 
                                var newdt=newcaseHistoryay1[0]+'/'+newcaseHistoryay1[1]+'/'+newcaseHistoryay1[2];
                                var dt=new Date(newdt);
                               
                                var dayName=dt.getDay();
                                var days=dt.getDate();
                                var month=dt.getMonth();
                                var year=dt.getFullYear();
                            }
                        }else if(caseInfo.date_of_decision){
                            var newcaseHistoryay1 = caseInfo.date_of_decision.split('-');
                            dateStr = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]); 
                            var newdt=newcaseHistoryay1[0]+'/'+newcaseHistoryay1[1]+'/'+newcaseHistoryay1[2];
                            var dt=new Date(newdt);
                            
                            var dayName=dt.getDay();
                            var days=dt.getDate();
                            var month=dt.getMonth();
                            var year=dt.getFullYear();
                        }else{
                            dateStr='No Date';
                            var days='<i style="font-size:10px;margin-top:1px;">'+dateStr+'</i>';
                            var month=12;
                            var year='';
                        }

                        noteVar = caseInfo.note ? caseInfo.note : "";
                        disp_name = caseInfo.disp_name ? caseInfo.disp_name : "";
                        stage_of_case = caseInfo.purpose_name ? caseInfo.purpose_name : "";
                        /**To remove the Numbers from 'stage_of_case' eg. 192-NOTICE & ADJOURNED MATTERS... */
                        var str_dash = "-";
                        if(stage_of_case.match(/[0-9]/g) && stage_of_case.indexOf(str_dash) != -1){
                            var stageofcase = stage_of_case.replace(/[0-9]/g, '');
                            stage_of_case=stageofcase.slice(1);                             
                        }
                        
                        //if ($("#allCasesBtn").hasClass("active")) {
                        trHTML += "<tr><td>" + cnt + "</td><td>" + hrefurl + "<time  class='date-as-calendar position-pixels'><span class='month'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span></time>" + "<br>" +updatedStr+ "</td><td>" + petResName + "</td></tr>";
                        if(noteVar != ""){
                            if (caseInfo.date_of_decision != null){
                            panel_body.push("<tr " + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-danger' style='font-size: 60%;'>Disposed</span></time></td><td>" + hrefurl + "<a href='#' class = 'noteIcon' id='Chevron_icon_img1' note=\'" + caseInfo.note + "\' onclick=\'\'><img src='images/chevron.png' style='display:inline-block;margin-left: 5px;' id='Chevron_icon1'/></a>" + courtNoDesgName + "<br><span class='badge badge-danger1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+disp_name+"</span>"+ "<br>" +updatedStr + "" + "</td><td>" + petResName + "</td></tr>");
                            }else{
                            panel_body.push("<tr " + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-success' style='font-size: 65%;'>Pending</span></time></td><td>" + hrefurl + "<a href='#' class = 'noteIcon' id='Chevron_icon_img1' note=\'" + caseInfo.note + "\' onclick=\'\'><img src='images/chevron.png' style='display:inline-block;margin-left: 5px;' id='Chevron_icon1'/></a>" + courtNoDesgName + "<br><span class='badge badge-success1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+stage_of_case+"</span>" + "<br>" +updatedStr + "</td><td>" + petResName + "</td></tr>");
                            }
                        }else{
                            if (caseInfo.date_of_decision != null){
                                panel_body.push("<tr " + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-danger' style='font-size: 60%;'>Disposed</span></time></td><td>" + hrefurl + courtNoDesgName + "<br><span class='badge badge-danger1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+disp_name+"</span>"+ "<br>" +updatedStr + "" + "</td><td>" + petResName + "</td></tr>");
                                }else{
                                panel_body.push("<tr " + mycolor + "><td style='text-align:center!important;'>" + "<time  class='date-as-calendar position-pixels'><span class='month' style='background:#f73333'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span><span class='badge badge-success' style='font-size: 65%;'>Pending</span></time></td><td>" + hrefurl + courtNoDesgName + "<br><span class='badge badge-success1' style='font-size: 80%;max-width: 8rem;overflow: hidden;text-overflow: ellipsis;font-weight: normal;'>"+stage_of_case+"</span>" + "<br>" +updatedStr + "</td><td>" + petResName + "</td></tr>");
                                }
                        }


                       /* } else if ($("#todaysCasesBtn").hasClass("active")) {

                            panel_body.push("<tr " + mycolor + "><td>" + cnt + "</td><td>" + hrefurl +"<br>"+ "<time  class='date-as-calendar position-pixels'><span class='month'>"+monthNames[month]+"</span><span class='day'>"+days+"</span><span class='year'>"+year+"</span></time>"  + "<br>" +updatedStr+"</td><td>" + petResName + "</td></tr>");
                        }*/

                    });
                    establishmentsPanelId++;
                    panel_body.push('</tbody>');
                    panel_body.push('</table>');
                    panel_body.push('</div>');
                    panel_body.push('</div>');
                    panel_body.push('</div>');

                    est_code = index;
                    var trHTML = '';


                });
                panel_body.push(' </div></div></div></div></div>');
            });

        });    
         panel_body.push(' </div>');
        });
        panel_body.push('</div></div></div></div></div></div>');



        $("#accordion").append(panel_body.join(""));


        var items = $(".todays_panel-group-main1").sort(function(a, b) {

            var vA = $(a).children().find(".panel-title-a-main").text();
            var vB = $(b).children().find(".panel-title-a-main").text();

            return (vA < vB) ? -1 : (vA > vB) ? 1 : 0;
        });
        $("#accordion").empty();
        $("#accordion").append(items);
         $('#loadingMyCases').modal('hide');
    }

    //Called on Refresh click or Today's button click
    function updateTodaysCasesAcordion(cnrNumbersArray) {

            if(cnrNumbersArray != null && cnrNumbersArray.length > 0){
                $("#nocases").hide();
                document.getElementById("todays_cases_span_id").innerHTML = cnrNumbersArray.length;
                populateTodaysDistrictAcordion(cnrNumbersArray);
            }else{
                document.getElementById("ditrictsAccordion").style.display = "none";
                $("#accordion").empty();
                $("#nocases").show();
                $('#loadingMyCases').modal('hide');
                document.getElementById("todays_cases_span_id").innerHTML = '0';
                // document.getElementById("mycases_span_id").innerHTML = "0";
                // var totalCNRHC = localStorage.getItem("CNR Numbers HC");
                // if(totalCNRHC != null){
                //     var total_cnr_Array1 = JSON.parse(totalCNRHC);
                //     document.getElementById("mycases_span_id").innerHTML = total_cnr_Array1.length;
                // }
            }
    }


    $('#searchInMyCasesBtnId').on('click', function (event) {
            event.preventDefault(); // To prevent following the link (optional)
            if($("#searchInMyCases").val().trim() != ""){
            var searchedCasesArray = [];
//            var arr = JSON.parse(localStorage.getItem('CNR Numbers HC'));
            var arr = datewiseCNRNumbers == null ? JSON.parse(localStorage.getItem('CNR Numbers HC')) : datewiseCNRNumbers;
            var searchText = $("#searchInMyCases").val().toUpperCase();
//            $('.context').highlight(searchText);
            
            $.each(arr, function(key,val){
                
                var jsonObj  = JSON.parse(val);
                var objFound = false;
                $.each(jsonObj, function(index, element) {

                    
                    switch(index){
                        case "type_name":
                            var valToUpper = (jsonObj["type_name"]).toUpperCase();
                            if(valToUpper.indexOf(searchText) != -1){
                                searchedCasesArray.push(JSON.stringify(jsonObj));
                                objFound = true;
                                
                            }
                            break;
                            
                        case "reg_no":
                            if(jsonObj["reg_no"]){
                                var valToUpper = (jsonObj["reg_no"]).toString().toUpperCase();
                                if(valToUpper.indexOf(searchText) != -1){
                                    searchedCasesArray.push(JSON.stringify(jsonObj));
                                    objFound = true;
                                }
                            }
                            break;
                            
                        case "petparty_name":
                            var valToUpper = (jsonObj["petparty_name"]).toUpperCase();
                            if(valToUpper.indexOf(searchText) != -1){
                                searchedCasesArray.push(JSON.stringify(jsonObj));
                                objFound = true;
                            }
                            break;
                            
                        case "resparty_name":
                            var valToUpper = (jsonObj["resparty_name"]).toUpperCase();
                            if(valToUpper.indexOf(searchText) != -1){
                                searchedCasesArray.push(JSON.stringify(jsonObj));
                                objFound = true;
                            }
                            break;
                            
                        case "reg_year":
                            if(jsonObj["reg_year"]){
                                var valToUpper = (jsonObj["reg_year"]).toString().toUpperCase();
                                if(valToUpper.indexOf(searchText) != -1){
                                    searchedCasesArray.push(JSON.stringify(jsonObj));
                                    objFound = true;
                                }                                
                            }
                            break;
                            
                       
                        case "fil_year":
                            if(jsonObj["fil_year"]  != null){
                                var valToUpper = (jsonObj["fil_year"]).toString().toUpperCase();
                                if(valToUpper.indexOf(searchText) != -1){
                                    searchedCasesArray.push(JSON.stringify(jsonObj));
                                    objFound = true;
                                }
                            }
                            break;
                    
                    
                        case "fil_no":
                            if(jsonObj["fil_no"] != null){
                                var valToUpper = (jsonObj["fil_no"]).toString().toUpperCase();
                                if(valToUpper.indexOf(searchText) != -1){
                                    searchedCasesArray.push(JSON.stringify(jsonObj));
                                    objFound = true;
                                }
                            }
                            break;
                            
                        case "date_next_list":
                            if(jsonObj["date_next_list"]){
                                var valToUpper = (jsonObj["date_next_list"]).toString().toUpperCase();
                                if(valToUpper.indexOf(searchText) != -1){
                                    searchedCasesArray.push(JSON.stringify(jsonObj));
                                    objFound = true;
                                }
                                break;
                            }
                            
                        case "date_of_decision":
                            if(jsonObj["date_of_decision"]){
                                var valToUpper = (jsonObj["date_of_decision"]).toString().toUpperCase();
                                if(valToUpper.indexOf(searchText) != -1){
                                    searchedCasesArray.push(JSON.stringify(jsonObj));
                                    objFound = true;
                                }
                                break;
                            }
                            
                        case "court_no_desg_name":
                            if(jsonObj["court_no_desg_name"]){
                                var valToUpper = (jsonObj["court_no_desg_name"]).toString().toUpperCase();
                                if(valToUpper.indexOf(searchText) != -1){
                                    searchedCasesArray.push(JSON.stringify(jsonObj));
                                    objFound = true;
                                }
                                break;
                            }
                            
                            
                    }
                    if(objFound){
                        return false;
                    }
                    
                });                
                
            });
            showInfoMessage(searchedCasesArray.length+" case(s) found");
            populateDistrictAcordion(searchedCasesArray, sessionStorage.DATEWISE);
            $('.context').highlight(searchText);
            }else{
                alert("Please enter text to search");
            }
            //highlight selected text in table
        
        
//            $('div.table').highlight("a");
            
    });


    $('#clearSearchResult').on('click', function (event) {
            event.preventDefault(); // To prevent following the link (optional)
            clearSearchText();
            var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
                     
            updateAllCasesAcordion(cnrNumbersArray);            
    });

    function showTodaysCases() {  
        $("#sortDropdownDiv").hide();
        $("#todaysCasesBtn").addClass("active");
        $("#allCasesBtn").removeClass("active");
        $("#searchCasesDivId1").show();
        $("#searchInMyCasesDivId").hide();
        resetDatePicker();
        var lastCheckedDate = localStorage.getItem('LAST_CHECKED_DATE');
        var currentDate = new Date();
        var d = new Date();

        var month = d.getMonth();
        var day = d.getDate();

        var todaysDate = d.getFullYear() + '/' + month + '/' + day;

            var allcnrNumbersLocalStorage =JSON.parse(localStorage.getItem('CNR Numbers HC'));

            updateTodaysCinosArray(allcnrNumbersLocalStorage);
            window.localStorage.setItem('LAST_CHECKED_DATE', todaysDate);
        var cnrNumbersLocalStorage = localStorage.getItem("TODAYS_SAVED_CASES_HC");
        if(cnrNumbersLocalStorage != null){
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
            updateTodaysCasesAcordion(cnrNumbersArray);
        }
    }

    function destroyClickedElement(event) {
        document.body.removeChild(event.target);
    }



    /*function checkOnlineStatus() {
        var condition = navigator.onLine ? "online" : "offline";
        if (condition == "offline") {
            if(!isOffline){
                isOffline=true;                    
                showErrorMessage("Please check your internet connection and Try again");
            } 
        }else{
            isOffline=false;
        }
    }*/

    function errorHandler(e) {
        var msg = '';

        switch (e.code) {
            case FileError.QUOTA_EXCEEDED_ERR:
                msg = 'QUOTA_EXCEEDED_ERR';
                break;
            case FileError.NOT_FOUND_ERR:
                msg = 'NOT_FOUND_ERR';
                break;
            case FileError.SECURITY_ERR:
                msg = 'SECURITY_ERR';
                break;
            case FileError.INVALID_MODIFICATION_ERR:
                msg = 'INVALID_MODIFICATION_ERR';
                break;
            case FileError.INVALID_STATE_ERR:
                msg = 'INVALID_STATE_ERR';
                break;
            default:
                msg = 'Unknown Error';
                break;
        }
        ;

        console.log('Error: ' + msg);
    }

jQuery.fn.highlight = function(pat) {
    
 function innerHighlight(node, pat) {
    
  var skip = 0;
  if (node.nodeType == 3) {
   var pos = node.data.toUpperCase().indexOf(pat);      
   if (pos >= 0) {
    var spannode = document.createElement('span');
    spannode.className = 'highlight';
    var middlebit = node.splitText(pos);
    var endbit = middlebit.splitText(pat.length);
    var middleclone = middlebit.cloneNode(true);
    spannode.appendChild(middleclone);
       
    node.parentNode.replaceChild(spannode, middlebit);
    skip = 1;
   }
  }
  else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
   for (var i = 0; i < node.childNodes.length; ++i) {
    i += innerHighlight(node.childNodes[i], pat);   
   }
  }
  return skip;
 }
 return this.each(function() {
     
  innerHighlight(this, pat.toUpperCase());
 });
};

jQuery.fn.removeHighlight = function() {
 function newNormalize(node) {
    for (var i = 0, children = node.childNodes, nodeCount = children.length; i < nodeCount; i++) {
        var child = children[i];
        if (child.nodeType == 1) {
            newNormalize(child);
            continue;
        }
        if (child.nodeType != 3) { continue; }
        var next = child.nextSibling;
        if (next == null || next.nodeType != 3) { continue; }
        var combined_text = child.nodeValue + next.nodeValue;
        new_node = node.ownerDocument.createTextNode(combined_text);
        node.insertBefore(new_node, child);
        node.removeChild(child);
        node.removeChild(next);
        i--;
        nodeCount--;
    }
 }

 return this.find("span.highlight").each(function() {
    var thisParent = this.parentNode;
    thisParent.replaceChild(this.firstChild, this);
    newNormalize(thisParent);
 }).end();
};


    $(document).on("calenderCaseClicked", function(event,date){
            $( ".panel-title-a-main" ).each(function( index ) {

                if($( this ).text().indexOf(date) >= 0){
                   
                    var $link = $('li.active a[data-toggle="tab"]');
                    $link.parent().removeClass('active');
                    var tabLink = $link.attr('href');
                    var panelLink = $(this).attr('href');
                    $('#tablist a[href="' + tabLink + '"]').tab('show');            
                    $(panelLink).collapse("show");

                }
            });
        });

        $("#My_Cases_pannel").bind("caseAdded", function () {            
            cnrArrModified = true;
            cnrNumbersArray = JSON.parse(localStorage.getItem("CNR Numbers HC"));
            setCalendarCountArr(cnrNumbersArray);
            refreshCaseCount();
            //populateDistrictAcordion(JSON.parse(localStorage.getItem("CNR Numbers HC")));
            if(($("#todaysCasesBtn").hasClass("active"))){ 
                updateSelectedDateCinosArray(cnrNumbersArray);     
                updateTodaysCasesAcordion(JSON.parse(window.localStorage.TODAYS_SAVED_CASES_HC));        
             }else{
                 updateAllCasesAcordion();
             }
             myApp.hidePleaseWait();
         });


        function removeDumplicateValue(myArray){ 
        var newArray = [];
        
        $.each(myArray, function(key, value) {
            var exists = false;
            $.each(newArray, function(k, val2) {
            if(JSON.parse(value).cino == JSON.parse(val2).cino){ exists = true }; 
            });
            if(exists == false && JSON.parse(value).cino != "") { newArray.push(value); }
        });
    
        return newArray;
        }
    
        $("#My_Cases_pannel").bind("caseRemoved", function () {  
            cnrArrModified = true;
            cnrNumbersArray = JSON.parse(localStorage.getItem("CNR Numbers HC"));

            $("#casedetailslink").focus();
            backButtonHistory.pop();
            $("#caseHistoryModal_hc").hide();
            window.sessionStorage.removeItem("case_history");
            window.sessionStorage.removeItem("CASE_NOT_EXIST");
            window.sessionStorage.removeItem("CASE_NOT_EXIST_CASENO");
            window.sessionStorage.removeItem("CASE_NOT_EXIST_CINO");
            window.sessionStorage.removeItem("CINO");           
            
            setCalendarCountArr(cnrNumbersArray);
            refreshCaseCount();
            // populateDistrictAcordion(JSON.parse(localStorage.getItem("CNR Numbers HC")));
            if(($("#todaysCasesBtn").hasClass("active"))){  
                updateSelectedDateCinosArray(cnrNumbersArray);    
                updateTodaysCasesAcordion(JSON.parse(window.localStorage.TODAYS_SAVED_CASES_HC));        
             }else{
                 updateAllCasesAcordion();
             }
             myApp.hidePleaseWait();
        });
        $(function () {
            $("#ditrictsAccordion").swipe({
                swipeStatus: function (event, phase, direction, distance, fingerCount) {
                    return false;
                }
            });
        });
    //window.addEventListener('online', checkOnlineStatus()/*updateOnlineStatus*/);
   // window.addEventListener('offline', checkOnlineStatus()/*updateOnlineStatus*/);

$(document).on('click', '.noteIcon', function (e) {
    e.preventDefault();                    
    var txt = $(this).attr('note');                  
    document.getElementById("notePopUp").innerHTML = txt;                
    $("#imp_case_note").modal('show');        
  //  $("#imp_case_note").dialog();
});

function callToWebTodaysCasesServicehc(url, data, callback){
    myApp.showPleaseWait();  
    var data1 = encryptData(data); 
    header =  {'Authorization' : 'Bearer ' + encryptData(jwttoken)};
    cordova.plugin.http.post(url, {params:data1}, header,function(response) {
        myApp.hidePleaseWait();        
        var responseDecoded = JSON.parse(decodeResponse(response.data));   
        if(responseDecoded.token){
            jwttoken = responseDecoded.token;
        }
        if(responseDecoded.status && responseDecoded.status=='N'){
            if(responseDecoded.status_code == '401'){
                if(!regenerateWebserviceCallFlag){
                    regenerateWebserviceCallFlag = true;
                    cordova.getAppVersion.getPackageName(function(pkgname){ 
                        var uidObj = {"uid":device.uuid ? device.uuid.toString() + ":" + pkgname : "324456" + ":" + pkgname}; 
                        data = {...data, ...uidObj};
                        callToWebTodaysCasesServicehc(url, data, callback);
                    });
                }else{
                    showErrorMessage("Session expired !");
                }
            }            
        }else{  
            callback(responseDecoded);
            regenerateWebserviceCallFlag = false;
        }
    }, function(response) {
        //showErrorMessage(labelsarr[705]);
        regenerateWebserviceCallFlag = false;
        myApp.hidePleaseWait();        
    });    
}
