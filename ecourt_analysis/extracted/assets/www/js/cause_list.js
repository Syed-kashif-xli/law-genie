var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
var selectCourtNameLabel = "Select Court Name";
var RESULT_CAUSE_LIST = "";
$(document).ready(function () {
        localizeLabels();
        sessionStorage.setItem("tab", "#Tab3");       
        // populateCourtComplexes();
      //Removes cause list search result saved in session storage
      function clearResult(){
            RESULT_CAUSE_LIST = "";
            $("#cases").empty();
            $("#searchInCauseListDivId").hide(); 
        }
        //$('#pickyDate').attr('readonly', true);
        /*$('#pickyDate').datepicker({dateFormat: 'dd-mm-yy',

                                    maxDate: +30 ,
                                    minDate: -7,
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
     
        arrCourtEstNames = [];
        arrCourtEstCodes = [];
        //If selected court complex is changed, then clear session data of this form
        $('#court_codec').change(function () {
            clearResult(); 
            $('#pickyDate').val(today);
            if ($('#court_codec').val() != "") {
                RESULT_CAUSE_LIST = "";     
                window.localStorage.setItem("SESSION_COURT_CODE", $('#court_codec').val());
                window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_codec option:selected').attr('complex_code'));
                window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
            }else{
                RESULT_CAUSE_LIST = "";            
                window.localStorage.removeItem("SESSION_COURT_CODE");
                window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
                window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
            }
            populateCourtNames();
        });

        //fetch court names either from web service or from session storage if court complex is selected or court name is selected
        if (window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST != null || window.localStorage.SESSION_COURT_CODE != null) {
            populateCourtNames();
        }

        $('#pickyDate').change(function() {
            clearResult();
            RESULT_CAUSE_LIST = "";  
        });
        
        //called if court complex is changed
        $('#court_name1').change(function () {
            clearResult();
            $('#pickyDate').val(today);
            RESULT_CAUSE_LIST = "";     
            window.sessionStorage.setItem("SESSION_SELECT_2_CAUSE_LIST", $('#court_name1').val());
        });
        if ( $('#cases').html().length == 0 ) {
            $("#searchInCauseListDivId").hide();
        }else{
            $("#searchInCauseListDivId").show(); 
        } 
    });

    $("#searchInCauseListBtnId").on("click", function(e){
        e.preventDefault();
        if(RESULT_CAUSE_LIST != "" ){
            var value = $("#searchInCauseList").val().toLowerCase();
            if(value){
                $("#cases tr").removeHighlight();
                $("#cases tr").filter(function() {
                $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);                  
                });
                $("#cases tr").highlight(value);
            }else{
                showErrorMessage(labelsarr[701]);
            }
        }        
    });

    $("#clearCauseListSearchResult").on("click", function(e){        
        e.preventDefault();
        $("#searchInCauseList").val("");    
        $("#cases").empty();
        $("#cases").append(JSON.parse(RESULT_CAUSE_LIST));
    });

    $("#Causelist_pannel").unbind("courtCodeChanged").bind("courtCodeChanged", function (e) {
        $('#court_codec').val(window.localStorage.SESSION_COURT_CODE);
        
        RESULT_CAUSE_LIST = "";
        $("#cases").empty();
        $("#searchInCauseListDivId").hide();
        if ($('#court_codec').val() != "") {
            RESULT_CAUSE_LIST = "";     
            window.localStorage.setItem("SESSION_COURT_CODE", $('#court_codec').val());
            window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_codec option:selected').attr('complex_code'));
            window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
        }else{
            RESULT_CAUSE_LIST = "";            
            window.localStorage.removeItem("SESSION_COURT_CODE");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
            window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
        }
         populateCourtNames();        
    });

    //fetch court names either from session storage or from web service
    function populateCourtNames() {
        // $('#court_name1').empty();
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var courtNameWebServiceUrl = hostIP + "courtNameWebService.php";
        //code to fetch court names either from web service call or from session storage
        if(window.localStorage.SESSION_COURT_CODE && window.localStorage.SESSION_COURT_CODE != ''){
                var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
                court_code_data = courtCodesArr[0];                
                var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
                // var  encrypted_data5=0;
                // if(localStorage.LANGUAGE_FLAG=="english"){
                //      encrypted_data5 = ("0");
                // }else{
                //      encrypted_data5 = ("1");
                // }                
                
                encrypted_data5 = (bilingual_flag.toString());
                var caseTypedata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(window.localStorage.SESSION_COURT_CODE),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
                
                var responseSuccess = false;
                //web service call to court names web service to fetch court names
                callToWebService(courtNameWebServiceUrl, caseTypedata, courtNameWebServiceResult);
                function courtNameWebServiceResult(result){
                    
                    responseSuccess = true;     
                    myApp.hidePleaseWait();
                    processCourtNames(result.courtNames);  
                }
                /*setTimeout(function(){ 
                    if(!responseSuccess){
                        showErrorMessage("Unable to connect to establishment");
                    }
                    myApp.hidePleaseWait();
                    p.abort(); }, 15000);*/
        }else{
            var items = [];
            items.push("<option value=''>"+selectCourtNameLabel+"</option>");
            $("#court_name1").html(items.join(""));
        }
    }

    //populates court names select box
    function processCourtNames(courNames){
        $('#court_name1').empty();
        if(courNames){
            var courtNamesArr = (courNames).split("#");
            $.each(courtNamesArr, function (key, val) {
                var courtName = val.split("~");
                if(courtName[0] == 'D'){                
                    if(courtName[0] == 'D'){
                        $('#court_name1').append('<option id="" value="' + courtName[0] + '" disabled>' + courtName[1] + '</option>');
                    }
                }else{
                    $('#court_name1').append('<option id="" value="' + courtName[0] + '">' + courtName[1] + '</option>');
                }
            });
        }else{
            $('#court_name1').append('<option id="" value="0" disabled>' + selectCourtNameLabel + '</option>');
        }
            if (window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST != null) {
                document.getElementById('court_name1').value = window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST;
            } else {
                document.getElementById('court_name1').value = "0";
            }
        
        if(localStorage.LANGUAGE_FLAG!="english"){
            if(labelsarr){
                $("#court_name1 option[value = '0']").text(labelsarr[208]);
            }
        }
    }

    /*called after button click Civil / Criminal
    *@id : "civilButton" or "criminalButton"
    */
    function onButtonClick(id) {
        var savedButtonId = sessionStorage.getItem("CAUSE_LIST_BUTTON");
        if (id != savedButtonId || RESULT_CAUSE_LIST == "") {
            RESULT_CAUSE_LIST = "";     
            sessionStorage.setItem("CAUSE_LIST_BUTTON", id);        
            $("#cases").empty();            
            var selectboxText = $("#court_codec option:selected").text();
            if (selectboxText == null) {
                showErrorMessage(labelsarr[277]);
                //showErrorMessage("Please select court complex");
                return false;
            }
            if (window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST == null || window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST == "0") {
                showErrorMessage(labelsarr[46]);
                //showErrorMessage("Please select Court name");
                return false;
            }
            var date = $('#pickyDate').val();
            if (date == '') {
                showErrorMessage(labelsarr[758]);
                return false;
            }
            var retVal = checkDateInpuWithTodays();
            if (retVal == false)
            {
                showErrorMessage(labelsarr[287]);
                return false;
            } else
            {
                var val;

                if (id == "civilButton") {
                    val = 'civ_t';
                }
                if (id == "criminalButton") {
                    val = 'cri_t';
                }
                //saved selected button in session storage, to retain selected button state during page reload.                
                submitFormCivil(val);
            }
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
        prevWeek.setTime(prevWeek.valueOf() - 7 * 24 * 60 * 60 * 1000);
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
            var courtname = window.sessionStorage.SESSION_SELECT_2_CAUSE_LIST;
            var courtname_arr = courtname.split('^');
            var court_code = courtname_arr[0];
            var court_no = courtname_arr[1];
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
            daysdiff = daysdiff/ (1000 * 3600 * 24);
            
            if (parseInt(daysdiff) <= 0)
            {
                selprevdays = 1;
            } else
            {
                selprevdays = 0;
            }
            var ci_cri = val;
            var state_code_data = window.localStorage.state_code;
            var district_code_data = window.localStorage.district_code;
            var  encrypted_data5=0;
            // if(localStorage.LANGUAGE_FLAG=="english"){
            //      encrypted_data5 = ("0");
            // }else{
            //      encrypted_data5 = ("1");
            // }
            encrypted_data5 = (bilingual_flag.toString());
            var casesWebServiceUrl = hostIP + "cases_new.php";
            var encrypted_data1 = (localStorage.getItem("LANGUAGE_FLAG"));
            
            var date = new Date(causelist_date);
            var causelist_date1 = ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '-' + ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) +'-'+ date.getFullYear();
           
            var casesdata = {state_code:(state_code_data), dist_code:(district_code_data), flag:(ci_cri), selprevdays:(selprevdays.toString()), court_no:(court_no), court_code:(court_code), causelist_date:(causelist_date1), language_flag:encrypted_data1.toString(), bilingual_flag:encrypted_data5.toString()};
            
            //web service call to fetch cases for Civil or Criminal depending on selected button
            callToWebService(casesWebServiceUrl, casesdata, causelistWebServiceResult);
            function causelistWebServiceResult(result){
                myApp.hidePleaseWait();
                      
                var obj_cases = (result.cases);
                if(obj_cases){
                    RESULT_CAUSE_LIST = JSON.stringify(obj_cases);
                    setCauseListResult(JSON.stringify(obj_cases));
                    $("#cases").append(obj_cases);
                    $("#searchInCauseListDivId").show(); 
                }else{
                    $("#casesnotfound").empty();
                    $("#casesnotfound").append("No cases found");
                        $("#casesnotfound").css({"text-align":"center","width":"100%","color":"#FA814C ","font-size":"16px"});
                }
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


$("#Causelist_pannel").unbind("languageChanged").bind("languageChanged", function () {      
            localizeLabels();
       });


function localizeLabels(){
    labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
    if(labelsarr){
        $("#court_complex_label").html(labelsarr[269]);
        $("#court_name_label").html(labelsarr[17]);
        $("#causelist_date_label").html(labelsarr[276]);
        $("#causelist_heading1_label").html(labelsarr[190]);
        $("#causelist_heading2_label").html(labelsarr[191]);
        $("#civilButton").html(labelsarr[194]);
        $("#criminalButton").html(labelsarr[195]);
        $("#court_name1 option[value = '0']").text(labelsarr[208]);
        $("#court_name1 option[value = '']").text(labelsarr[208]);
        $("#court_codec option[value = '']").text(labelsarr[268]);
        $("#searchInCauseList").attr("placeholder",labelsarr[693]);

        selectCourtNameLabel = labelsarr[208];
    }
}