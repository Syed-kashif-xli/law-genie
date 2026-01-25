var ltype_name;
var lpetparty_name;
var lresparty_name;
var lestablishment_name;
var lstate_name;
var ldistrict_name;
var hide_pet_name;
var hide_res_name;
var tmp_notevar='';
var caseAddedLabel = "Case Added Successfully";
var caseRemovedLabel = "Case Removed Successfully";
var stateCodePresentInSelectedLanguage;

    $(document).ready(function () {
        backButtonHistory.push("casehistory");
        function localizeLabels(){
            var labelsarr = window.sessionStorage.GLOBAL_LABELS ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
            if(labelsarr){
                $("#filing_case_history_label").html(labelsarr[605]);
                $("#case_details_label").html(labelsarr[136]);
                $("#case_code_label").html(labelsarr[8]);
                $("#filing_number_label").html(labelsarr[120]);
                $("#filing_date_label").html(labelsarr[124]);            
                $("#CNR_no_label").html(labelsarr[144]);
                $("#QR_code_label").html(labelsarr[784]);
                $("#pet_and_advoc1").html(labelsarr[122]);
                $("#pet_and_advoc2").html(labelsarr[175]);
                $("#pet_and_advoc3").html(labelsarr[3]);
                $("#resp_and_advoc1").html(labelsarr[470]);
                $("#resp_and_advoc2").html(labelsarr[175]);
                $("#resp_and_advoc3").html(labelsarr[3]); 
                $("#objection_label").html(labelsarr[769]);
                $("#acts_label").html(labelsarr[177]);
                $("#FIR_details_label").html(labelsarr[158]);
                $("#police_station_label").html(labelsarr[56]);
                $("#FIR_no_label").html(labelsarr[22]);
                $("#year_label").html(labelsarr[81]);
                $("#subord_court_info_label").html(labelsarr[156]);
                $("#case_decision_date_label").html(labelsarr[771]);     
                $("#court_no_and_name_label1").html(labelsarr[18]);
                $("#court_no_and_name_label2").html(labelsarr[175]);
                $("#court_no_and_name_label3").html(labelsarr[176]);
                $("#case_no_and_year_label1").html(labelsarr[10]);
                $("#case_no_and_year_label2").html(labelsarr[175]);
                $("#case_no_and_year_label3").html(labelsarr[81]);
                $("#rejection_label").html(labelsarr[770]);
                caseAddedLabel = labelsarr[631];
                caseRemovedLabel = labelsarr[632];
                $("#note_label_fil").html(labelsarr[818]+": ");
                $(".addnotefil").html(labelsarr[829]);
                $("#addNoteModal_label").html(labelsarr[829]);
                $("#addNoteModalForAddedCase_label").html(labelsarr[829]);                
                $('#note').attr('placeholder',labelsarr[817]);  
                $('#noteForAddedCase').attr('placeholder',labelsarr[817]); 
                
           }
            
        }

        $("#header_srchpage1").load("case_history_header.html", function (response, status, xhr) {
            var labelsarr = JSON.parse(window.sessionStorage.GLOBAL_LABELS);  

            $('#go_back_link_3').on('click', function (event) {
                $("#case_details_label").focus();
               backButtonHistory.pop();
                window.sessionStorage.removeItem("filing_case_history");
                $("#caseHistoryModal").modal('hide');  
            });

            $("#open_close3").on('click', function (event) 
            {
                if ($("#mySidenav3").is(':visible'))
                {
                    closeNav3();
                } else
                {
                    openNav3();
                }
            });
            $("#addcaselabel").html(labelsarr[768]);
            $("#savedcaselabel").html(labelsarr[773]);
            $("#removecaselabel").html(labelsarr[630]);

            /*flag is set true if button remove case is to be shown for already added case(). This is done only if case history is displayed from My cases tab. 
            If flag is false(In case if case history link is not called from My cases tab), then button Saved case is displayed instead of remove case
            */
            flag = getParameterByName('flag');

            flag = window.sessionStorage.getItem("SESSION_SHOW_REMOVE");
            window.sessionStorage.removeItem("SESSION_SHOW_REMOVE");
            if (flag == "true") {
                document.getElementById("remove_case").style.display = "block";
                document.getElementById("add_case").style.display = "none";
                document.getElementById("saved_case").style.display = "none";
                document.getElementById("Chevron_icon").style.display = "none";
            } else {
                document.getElementById("remove_case").style.display = "none";
                document.getElementById("add_case").style.display = "block";
                document.getElementById("saved_case").style.display = "none";
                document.getElementById("Chevron_icon").style.display = "block";
            }
            //If case is removed from saved cases, then redirect to My cases tab(since tab is for My cases tab is set in session storage, redirecting to My cases will display My cases tab)
            $('#remove_case').on('click', function (event) {
                event.preventDefault();
                window.location.replace("index.html");
            });
            var caseInfoArray = window.localStorage.getItem("CNR Numbers");
            caseInfoArray = (caseInfoArray === null) ? [] : JSON.parse(caseInfoArray);
            var substr = '';

            /* start
            This logic is for My cases.
            If case history is called from my cases tab and if connection to that establishment is unsuccessful, then we need to display blank case history page with message that this case could not be open.
            In this case also Remove case button should be displayed. So cino is passed from my cases, In order to check if this case is in local storage. If yes then show Remove case.
            */
            var caseNotExistFlag = window.sessionStorage.getItem("CASE_NOT_EXIST") ? (window.sessionStorage.getItem("CASE_NOT_EXIST")) : null;
            // var cinumber = getParameterByName('cino');            

            var cinumber = window.sessionStorage.getItem("CINO") ? (window.sessionStorage.getItem("CINO")) : null;
//            var cinumber = getParameterByName('cino');
            if(cinumber){
                substr = cinumber;
            }else{
                // var caseNotExistFlag = getParameterByName('caseNotExist');
                if(!caseNotExistFlag){
                    var caseInfoStr = createJSONArray();
                    substr = caseInfoStr.substring(9,25);
                }
            }
            
            if(substr){
                var index = caseInfoArray.containsSubStringOrHasSubstringOf( substr.trim());
                if (index != -1) {
                    document.getElementById("add_case").style.display = "none";
                    if (flag == "true") {
                        document.getElementById("saved_case").style.display = "none";                
                    }else{
                        document.getElementById("saved_case").style.display = "block";
                    }
                }
            }else{
                if(caseNotExistFlag || flag){
                    document.getElementById("add_case").style.display = "none";
                    document.getElementById("saved_case").style.display = "none";
                    document.getElementById("remove_case").style.display = "block";
                }
            }


            var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers");
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
            if(cnrNumbersArray != null){
                
                var index = cnrNumbersArray.containsSubStringOrHasSubstringOf(caseHistory.cino);
                
                if(index != -1){
                    
                    var jsonobj = JSON.parse(cnrNumbersArray[index]);
                    var noteVar = jsonobj.note ? jsonobj.note : "";                    
                    if(noteVar != ""){
                        document.getElementById("noteTextDisplayDiv").style.display = "block";
                        document.getElementById("noteTextDisplay").innerHTML = noteVar;
                        document.getElementById("noteForAddedCase").innerHTML = noteVar; 
                        document.getElementById("Chevron_icon").style.display = "none";                       
                    }else{
                        document.getElementById("noteTextDisplayDiv").style.display = "none";
                        document.getElementById("Chevron_icon").style.display = "block";
                    }
                }
            }

        });
        /******end******/

        noteVar = "";

        //get filing case history data from local storage
        var retrievedObject = window.sessionStorage.getItem('filing_case_history');
        var caseHistory = JSON.parse(retrievedObject);
        if (caseHistory != null) {            
            complex_code = caseHistory.complex_code;            
            court_code = caseHistory.court_code;            
            establishment_name = caseHistory.court_name;
            lestablishment_name = caseHistory.lcourt_name;
            establishment_code = caseHistory.est_code;            
            // if(localStorage.LANGUAGE_FLAG=="english"){
            if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
                document.getElementById('court_name_title').innerHTML = establishment_name;
            }else{
                document.getElementById('court_name_title').innerHTML = lestablishment_name;
            }
            state_code = caseHistory.state_code;
            district_code = caseHistory.district_code;
            state_name = caseHistory.state_name;
            lstate_name = caseHistory.lstate_name;
            district_name = caseHistory.district_name;
            ldistrict_name = caseHistory.ldistrict_name;
            date_of_decision = caseHistory.date_of_decision;            
            hide_pet_name = caseHistory.hide_pet_name;
            hide_partyname_est = caseHistory.hide_partyname_est;
            hide_res_name = caseHistory.hide_res_name;
            petparty_name = caseHistory.petparty_name;
            if(hide_pet_name == 'Y' || hide_partyname_est == 'Y' || hide_partyname_est == 'y'){
               lpetparty_name = caseHistory.petparty_name;                
            }else{
                lpetparty_name = caseHistory.lpet_name;
            }                      
            resparty_name = caseHistory.resparty_name;
            if(hide_pet_name == 'Y' || hide_partyname_est == 'Y' || hide_partyname_est == 'y'){
                lresparty_name = caseHistory.resparty_name;               
            }else{
                 lresparty_name = caseHistory.lres_name;
            }    
            if(caseHistory.date_last_list == null){
                date_last_list = '';
            }else{
                date_last_list = caseHistory.date_last_list;
            }
            date_next_list = caseHistory.date_next_list;
            ciNumber = caseHistory.cino;

            stateCodePresentInSelectedLanguage = localizedStateCodesArr.indexOf(parseInt(state_code)) == -1 ? false : true;
           
            $('#qrcode').qrcode({width: 64,height: 64,text: ciNumber});            
            
            
            //code to update pet name to local storage if changed
            /*var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers");
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
            if(cnrNumbersArray != null){
                var index = cnrNumbersArray.containsSubStringOrHasSubstringOf(ciNumber);
                if(index != -1){
                    var jsonobj = JSON.parse(cnrNumbersArray[index]);
                    if(jsonobj.petparty_name != petparty_name){
                        jsonobj.petparty_name = petparty_name;
                        cnrNumbersArray[index] = JSON.stringify(jsonobj);
                        localStorage.setItem("CNR Numbers", JSON.stringify(cnrNumbersArray));
                    }
                    if(jsonobj.resparty_name != resparty_name){
                        jsonobj.resparty_name = resparty_name;
                        cnrNumbersArray[index] = JSON.stringify(jsonobj);
                        localStorage.setItem("CNR Numbers", JSON.stringify(cnrNumbersArray));
                    }
                }
            }*/

            /**************Case Details******************/

            type_name = caseHistory.type_name;
            ltype_name = caseHistory.ltype_name;            
            case_no = caseHistory.case_no;
            fil_no = caseHistory.fil_no;
            fil_year = caseHistory.fil_year;

    //case type
            document.getElementById('caseCodeId').innerHTML = caseHistory.filing_no;

    //filing number
            //  if(localStorage.LANGUAGE_FLAG=="english"){
            if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
                 var filing_number = caseHistory.type_name + "/" + caseHistory.fil_no + "/" + caseHistory.fil_year;
                 document.getElementById('filingNumberId').innerHTML = filing_number;
             }else{
                 var filing_number = caseHistory.ltype_name + "/" + caseHistory.fil_no + "/" + caseHistory.fil_year;
                 document.getElementById('filingNumberId').innerHTML = filing_number;
             }

    //Filing date
            var newDateDtfiling = "";
            if(caseHistory.date_of_filing){
                var newcaseHistoryay1 = caseHistory.date_of_filing.split('-');
                newDateDtfiling = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
            }
            document.getElementById('filingDateId').innerHTML = newDateDtfiling;

    //CNR number
            var org_type = caseHistory.cino.slice(0, 6);
            var serialNo = caseHistory.cino.slice(6, 12);
            var ciyear = caseHistory.cino.slice(12, 16);
            disp_ci_no = org_type + '-' + serialNo + '-' + ciyear;
            document.getElementById('cnrnoId').innerHTML = caseHistory.cino;

            /**************Case Status******************/
            var petAndAdvStr = "";
            var petAndAdvStr1 = "";
            if (caseHistory.petNameAdd != null) {
                petAndAdvStr = caseHistory.petNameAdd;
            }
            if (caseHistory.str_error != null) {
                petAndAdvStr1 = caseHistory.str_error;
            }
            document.getElementById('petitionerAndAdvId').innerHTML = petAndAdvStr + '<br>' + petAndAdvStr1;

    //respondent and advocate
            var resAndAdvStr = "";
            var resAndAdvStr1 = "";
            if (caseHistory.resNameAdd != null) {
                resAndAdvStr = caseHistory.resNameAdd;
            }
            if (caseHistory.str_error1 != null) {
                resAndAdvStr1 = caseHistory.str_error1;
            }
            document.getElementById('respAndAdvId').innerHTML = resAndAdvStr + '<br>' + resAndAdvStr1;


           /**************Objection******************/
            var objectionTable = caseHistory.objection;
            if (objectionTable != null) {
                $("#objectionCollapseId").append(objectionTable);
            } else {
                document.getElementById('brObjection').style.display = 'none';
                document.getElementById('objectionTableId').style.display = 'none';
            }

            /**************Rejection******************/
            var rejectionTable = caseHistory.rejection;
            if (rejectionTable != null) {
                $("#rejectionCollapseId").append(rejectionTable);
            } else {
                document.getElementById('brRejection').style.display = 'none';
                document.getElementById('rejectionTableId').style.display = 'none';
            }

            /**************Acts******************/
            var actTable = caseHistory.act;
            if (actTable != null) {
                $("#actsCollapseId").append(actTable);
            } else {
                document.getElementById('brActs').style.display = 'none';
                document.getElementById('actsTableId').style.display = 'none';
            }
    
            /**************FIR******************/
            var firDetailsStr = caseHistory.fir_details;
            if (firDetailsStr != null) {
                firDetails = [];
                firDetails = firDetailsStr.split("^");
                document.getElementById('policeStationId').innerHTML = firDetails[1];
                document.getElementById('firNoId').innerHTML = firDetails[0];
                document.getElementById('firDetailsyearId').innerHTML = firDetails[2];
            } else {
                document.getElementById('brFIR').style.display = 'none';
                document.getElementById('firTableId').style.display = 'none';
            }

            /**************Subordinate******************/
            var subordinateStr = caseHistory.subordinateCourtInfoStr;
            if (subordinateStr != null) {
                subordianteDetailsArr = [];
                subordianteDetailsArr = subordinateStr.split("^");
                document.getElementById('courtNoAndNameId').innerHTML = subordianteDetailsArr[2];
                document.getElementById('caseNoAndYearId').innerHTML = subordianteDetailsArr[1];
                var caseDecisionDt = "";
                if(subordianteDetailsArr[0]){
                    var newcaseHistoryay1 = subordianteDetailsArr[0].split('-');
                    caseDecisionDt = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
                }
                document.getElementById('caseDecisionAndDateId').innerHTML = caseDecisionDt;
            } else {
                document.getElementById('brSubordinate').style.display = 'none';
                document.getElementById('subordinateCourtInfoId').style.display = 'none';
            }

        }else{
            $("#filingHistoryContainer").hide();
            var caseno = getParameterByName('caseno');
            $("#errorOpnening").show();
            document.getElementById("errMsg").innerHTML = "Error Opening Case History for case number "+caseno;
        }
        $("#footer").load("footer.html");
        localizeLabels();
    });

    //create JSON array from data fetched from web service to save it to local storage
    function createJSONArray() {
        var caseInfoArray = window.localStorage.getItem("CNR Numbers");
        caseInfoArray = (caseInfoArray === null) ? [] : JSON.parse(caseInfoArray);
        var jsonData = {};
        jsonData["cino"] = ciNumber;
        jsonData["type_name"] = type_name;
        jsonData["case_no"] = case_no;
        jsonData["reg_year"] = '0';
        jsonData["reg_no"] = '0';
        jsonData["petparty_name"] = petparty_name;
        jsonData["resparty_name"] = resparty_name;
        jsonData["fil_year"] = fil_year;
        jsonData["fil_no"] = fil_no;
        jsonData["establishment_name"] = establishment_name;
        jsonData["establishment_code"] = establishment_code;
        jsonData["state_code"] = state_code;
        jsonData["district_code"] = district_code;
        jsonData["state_name"] = state_name;
        jsonData["district_name"] = district_name;
        jsonData["date_next_list"] = date_next_list;
        jsonData["date_of_decision"] = date_of_decision;
        jsonData["date_last_list"] = date_last_list;
        jsonData["updated"] = true;
        jsonData["court_no_desg_name"] = "";        
        jsonData["ltype_name"] = ltype_name;
        jsonData["lpetparty_name"] = lpetparty_name;
        jsonData["lresparty_name"] = lresparty_name;
        jsonData["lestablishment_name"] = lestablishment_name;
        jsonData["lstate_name"] = lstate_name;
        jsonData["ldistrict_name"] = ldistrict_name;
        jsonData["lcourt_no_desg_name"] = "";
        jsonData["note"] = noteVar;        
        var caseInfoStr = JSON.stringify(jsonData);
        return caseInfoStr;
    }

    /*
    To save this case to local storage or Remove it from local storage depending on clicked button id.
    If case already exist, then it will display either saved case(If called from my cases) or Remove case(otherwise)
    *@clicked_id : Add case button id or Remove case button id
    */
    function addCase(clicked_id) {
        var caseInfoArray = window.localStorage.getItem("CNR Numbers");
        caseInfoArray = (caseInfoArray === null) ? [] : JSON.parse(caseInfoArray);
        //If called from My cases, cino is passed as parameter
        //var cinumber = getParameterByName('cino');
        var cinumber = window.sessionStorage.getItem("CINO") ? (window.sessionStorage.getItem("CINO")) : null;
        var caseNotExistFlag = window.sessionStorage.getItem("CASE_NOT_EXIST") ? (window.sessionStorage.getItem("CASE_NOT_EXIST")) : null;
        var substr = '';
        if(cinumber){
            substr = cinumber;
        }else{
            if(caseNotExistFlag){
                substr =(window.sessionStorage.getItem("CASE_NOT_EXIST_CINO"));
            }else{
                var caseInfoStr = createJSONArray();
                substr = ciNumber;  
            }
        }
        var index = caseInfoArray.containsSubStringOrHasSubstringOf( substr.trim());
        if (index != -1) {
            if (clicked_id == "addCaseButton") {
                showErrorMessage(labelsarr[830]);
                return false;
            } else if (clicked_id == "removeCaseButton") {
                if(!alert(caseRemovedLabel)){
                    caseInfoArray.splice(index, 1);
                    localStorage.setItem("CNR Numbers", JSON.stringify(caseInfoArray));
                    setTimeout(function (){ 
                        $("#My_Cases_pannel").trigger("caseRemoved");
                    },400);
                    // alert(caseRemovedLabel);
                }
            }
        } else {
            if(!alert(caseAddedLabel)){
                myApp.showPleaseWait();
                var caseInfoStr = createJSONArray();
                caseInfoArray.push(caseInfoStr);
                localStorage.setItem("CNR Numbers", JSON.stringify(caseInfoArray));
                setTimeout(function (){
                    $("#My_Cases_pannel").trigger("caseAdded");
                },400);
                //alert(caseAddedLabel);
                if(noteVar != ""){
                    document.getElementById("Chevron_icon").style.display = "none";
                }
                document.getElementById("saved_case").style.display = "block";
                document.getElementById("add_case").style.display = "none";
            }
        }
    }


    /*
    called from web service after link click on history
    @court_code : court code
    @dist_code : district code
    @n_dt : next date
    @case_number : case_number
    @state_code : state code
    @businessStatus : businessStatus
    @todays_date1 : todays date
    @court_no : court number
    */
    function viewBusiness(court_code, dist_code, n_dt, case_number, state_code, businessStatus, todays_date1, court_no) {
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
        // var  encrypted_data5=0;
        // if(localStorage.LANGUAGE_FLAG=="english"){
        //      encrypted_data5 = ("0");
        // }else{
        //      encrypted_data5 = ("1");
        // }  
        var encrypted_data5 = (bilingual_flag.toString());  
        if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
             encrypted_data5 = ("0");
        }else{
             encrypted_data5 = ("1");
        }      
        var viewBusinessData = "court_code=" + court_code;
        viewBusinessData += "&dist_code=" + dist_code;
        viewBusinessData += "&nextdate1=" + n_dt;
        viewBusinessData += "&case_number1=" + case_number;
        viewBusinessData += "&state_code=" + state_code;
        viewBusinessData += "&disposal_flag=" + businessStatus;
        viewBusinessData += "&businessDate=" + todays_date1;
        viewBusinessData += "&court_no=" + court_no;
        viewBusinessData += "&appFlag=";
        viewBusinessData += "&language_flag="+encrypted_data4;
        viewBusinessData += "&bilingual_flag="+encrypted_data5;      
        var showBusinessWebServiceUrl = hostIP + "s_show_business.php";
        callToWebService(showBusinessWebServiceUrl, viewBusinessData, showBusinessWebServiceResult);
        function showBusinessWebServiceResult(data){
            myApp.hidePleaseWait();
            window.localStorage.setItem('viewBusinessLocalStorageVar', data.viewBusiness);
            window.location = 'view_business.html';
        }
       
    }

    Array.prototype.containsSubStringOrHasSubstringOf = function( text ){
            text = text.toUpperCase();
            for ( var i = 0; i < this.length; ++i )
            {
                if (    this[i].toString().indexOf( text.toString() ) != -1
                     || text.toString().indexOf( this[i].toString() ) != -1 )
                    return i;
            }
            return -1;
        }

        function go_back_link_history_fun(){                    
            $("#case_details_label").focus();
            backButtonHistory.pop();
            window.sessionStorage.removeItem("filing_case_history");
            $("#caseHistoryModal").modal('hide');
        }

    $("#menubarClose").click(function ()
    {
        if ($("#mySidenav3").is(':visible'))
        {            
            document.getElementById("mySidenav3").style.display = "none";
        } 
    });


    function addNoteToDb(){
        noteVar = $("#note").val();
        if(addNoteToCase()){
            $("#addNoteModal").hide();
            $("#addNoteModal").modal('hide');
        //    $('#Chevron_icon').html('Edit Note');
            $('#Chevron_icon').hide();
        }
    }
    
    function closeNoteModal(){
        $("#addNoteModal").hide();
        $("#addNoteModal").modal('hide');
    }
    
    
    function closeAddedNoteModal(){
        $("#addNoteModalForAddedCase").modal('hide');
    }
    
    //This function is called when clicked on add icon for case which is already added to history.
    function updateNoteToAddedCase(){
        tmp_notevar='';        
        noteVar = $("#noteForAddedCase").val();
        tmp_notevar=noteVar;
        if(isValidNote()){
            addNote();    
            document.getElementById("noteTextDisplay").innerHTML = tmp_notevar;
            $("#addNoteModalForAddedCase").modal('hide');
        }else{
            showErrorMessage(labelsarr[831]);
            return false;
        }
    }
    
    
    //This function is called when clicked on add icon for case which is not yet added to history.
    function addNoteToCase(){
        tmp_notevar='';
        noteVar = $("#note").val();
        tmp_notevar = noteVar;
        if(isValidNote()){
            addNote();
    
            document.getElementById("noteTextDisplay").innerHTML = tmp_notevar;
            document.getElementById("noteTextDisplayDiv").style.display = "block"; 
            document.getElementById("noteForAddedCase").innerHTML = tmp_notevar;
            return true;
        }else{
            showErrorMessage(labelsarr[831]);
            return false;
        }
    }
    
    function addNote(){
        var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers");
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
            
            var index = cnrNumbersArray ? cnrNumbersArray.containsSubStringOrHasSubstringOf( ciNumber) : -1;
            if(index != -1){
                //if case is not added already
                var jsonobj = JSON.parse(cnrNumbersArray[index]);
                jsonobj.note = noteVar;
                cnrNumbersArray[index] = JSON.stringify(jsonobj);
                localStorage.setItem("CNR Numbers", JSON.stringify(cnrNumbersArray));
                $("#My_Cases_pannel").trigger("caseAdded");

            }else{
                //if case is added already
                addCase("addCaseButton");
            }
        
    }
    
    //This function is called when clicked on add icon for case which is not yet added to history.
   /* function addNoteToCase(){
        noteVar = $("#note").val();
        
        if(isValidNote()){
            addNote();
    
            document.getElementById("noteTextDisplay").innerHTML = noteVar;
            document.getElementById("noteTextDisplayDiv").style.display = "block"; 
            document.getElementById("noteForAddedCase").innerHTML = noteVar;
            return true;
        }else{
            showErrorMessage("Please Enter valid note");
            return false;
        }
    }*/
    
    function isValidNote(){
        var patt = /^[a-zA-z.\0-9-+()$*@&!?,]*$/;   
    //    var patt = new RegExp(/^[a-zA-z.\' ] ?([a-zA-z.\' ]|[a-zA-z.\' ] )*[a-zA-z.\' ]$/);    
        return (patt.test(noteVar));
    }