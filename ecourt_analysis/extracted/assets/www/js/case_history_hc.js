var tmp_note_var='';
//var tmp_notevar='';
var disp_name='';
var purpose_name='';
    $(document).ready(function () {
        backButtonHistory.push("casehistory");
        $("#header_srchpage1_hc").load("case_history_header.html", function (response, status, xhr) {            
            $('#go_back_link_3').on('click', function (event) {
                $("#casedetailslink").focus();
                backButtonHistory.pop();
                document.getElementById("saved_case").style.display = "none";
                document.getElementById("add_case").style.display = "block";  
                $("#caseHistoryModal_hc").hide();
                window.sessionStorage.removeItem("case_history");
                window.sessionStorage.removeItem("CASE_NOT_EXIST");
                window.sessionStorage.removeItem("CASE_NOT_EXIST_CASENO");
                window.sessionStorage.removeItem("CASE_NOT_EXIST_CINO");
                window.sessionStorage.removeItem("CINO");
                $("#caseHistoryModal_hc").modal('hide');              
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

            /*flag is set true if button remove case is to be shown for already added case(). This is done only if case history is displayed from My cases tab. 
            If flag is false(In case if case history link is not called from My cases tab), then button Saved case is displayed instead of remove case
            */
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
            // $('#remove_case').on('click', function (event) {
            //     event.preventDefault();
            //     window.location.replace("index_hc.html");
            // });
            var caseInfoArray = window.localStorage.getItem("CNR Numbers HC");
            caseInfoArray = (caseInfoArray === null) ? [] : JSON.parse(caseInfoArray);
            var substr = '';

            /* start
            This logic is for My cases.
            If case history is called from my cases tab and if connection to that establishment is unsuccessful, then we need to display blank case history page with message that this case could not be open.
            In this case also Remove case button should be displayed. So cino is passed from my cases, In order to check if this case is in local storage. If yes then show Remove case.
            */
        //    var caseNotExistFlag = window.sessionStorage.getItem("CASE_NOT_EXIST");

        //     var cinumber = getParameterByName('cino');

            var caseNotExistFlag = window.sessionStorage.getItem("CASE_NOT_EXIST") ? (window.sessionStorage.getItem("CASE_NOT_EXIST")) : null;
            // var cinumber = getParameterByName('cino');            

            var cinumber = window.sessionStorage.getItem("CINO") ? (window.sessionStorage.getItem("CINO")) : null;

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
                        document.getElementById("Chevron_icon").style.display = "none";
                    }
                }
            }else{
                if(caseNotExistFlag || flag){
                    document.getElementById("add_case").style.display = "none";
                    document.getElementById("saved_case").style.display = "none";
                    document.getElementById("remove_case").style.display = "block";
                }
            }
            var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
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
                            document.getElementById("removeNoteButton").style.visibility = "visible";
                        }else{
                            document.getElementById("noteTextDisplayDiv").style.display = "none";
                            document.getElementById("Chevron_icon").style.display = "block";
                        }
                    }
                }
        });
        /******end******/
    
        noteVar = "";
       
        var retrievedObject = window.sessionStorage.getItem('case_history');
        var caseHistory = retrievedObject ? JSON.parse(retrievedObject) : null;       
        if (caseHistory != null) {
            establishment_name = caseHistory.court_name;
            establishment_code = caseHistory.est_code;
            state_code = caseHistory.state_code;
            district_code = caseHistory.district_code;
            state_name = caseHistory.state_name;
            district_name = caseHistory.district_name;
            if(caseHistory.date_last_list == null){
                date_last_list = '';
            }else{
                date_last_list = caseHistory.date_last_list;
            }
            date_next_list = caseHistory.date_next_list;
            fil_no = caseHistory.fil_no;
            fil_year = caseHistory.fil_year;            
            petparty_name = caseHistory.petparty_name;
            resparty_name = caseHistory.resparty_name;
            ciNumber = caseHistory.cino;
            $('#qrcode').qrcode({width: 64,height: 64,text: ciNumber});            
            //code to update pet name to local storage if changed
            var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
            var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
            if(cnrNumbersArray != null){
                var index = cnrNumbersArray.containsSubStringOrHasSubstringOf(ciNumber);
                if(index != -1){
                    var jsonobj = JSON.parse(cnrNumbersArray[index]);
                    if(jsonobj.petparty_name != petparty_name){
                        jsonobj.petparty_name = petparty_name;
                        cnrNumbersArray[index] = JSON.stringify(jsonobj);
                        localStorage.setItem("CNR Numbers HC", JSON.stringify(cnrNumbersArray));
                    }
                    if(jsonobj.resparty_name != resparty_name){
                        jsonobj.resparty_name = resparty_name;
                        cnrNumbersArray[index] = JSON.stringify(jsonobj);
                        localStorage.setItem("CNR Numbers HC", JSON.stringify(cnrNumbersArray));
                    }
                }
            }            
            /**************Case Details******************/

     //heading 
            document.getElementById('court_name').innerHTML = caseHistory.court_name;
            court_name = caseHistory.court_name;

    //case type
            document.getElementById('caseTypeId').innerHTML = caseHistory.type_name;
            type_name = caseHistory.type_name;

    //filing number
            var filing_number = caseHistory.fil_no + "/" + caseHistory.fil_year;
            document.getElementById('filingNumberId').innerHTML = filing_number;

    //Registration number            
            if(caseHistory.reg_no !=null)
            {
                $('#reg_no').show();
                var registration_number = caseHistory.reg_no + "/" + caseHistory.reg_year;
                document.getElementById('regNumberId').innerHTML = registration_number;    
                case_no = caseHistory.case_no;
                reg_no = caseHistory.reg_no;
                reg_year = caseHistory.reg_year;                    
            }
            else
            {
               $('#reg_no').hide(); 
                case_no = caseHistory.case_no;
                reg_no = caseHistory.reg_no;
                reg_year = caseHistory.reg_year;
            }
            
    //Filing date
            var newDateDtfiling = "";
            if(caseHistory.date_of_filing){
                var newcaseHistoryay1 = caseHistory.date_of_filing.split('-');
                //from caseHistoryay concatenate into new date string format: "DD.MM.YYYY"
                newDateDtfiling = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
            }
            document.getElementById('filingDateId').innerHTML = newDateDtfiling;

    //Registration date
            var newDateDtRegis = "";
            if(caseHistory.dt_regis != null)
            {
                if(caseHistory.dt_regis){
                    var newcaseHistoryay = caseHistory.dt_regis.split('-');
                    //from caseHistoryay concatenate into new date string format: "DD.MM.YYYY"
                    newDateDtRegis = (newcaseHistoryay[2] + "-" + newcaseHistoryay[1] + "-" + newcaseHistoryay[0]);
                }
                $('#reg_date').show();
                document.getElementById('regDateId').innerHTML = newDateDtRegis;
            }
            else
            {
                $('#reg_date').hide();                  
            }

    //CNR number
            var org_type = caseHistory.cino.slice(0, 6);
            var serialNo = caseHistory.cino.slice(6, 12);
            var ciyear = caseHistory.cino.slice(12, 16);
            disp_ci_no = org_type + '-' + serialNo + '-' + ciyear;
            document.getElementById('cnrnoId').innerHTML = caseHistory.cino;
            /**************Case Status******************/
            var dt_first_hearing = "";
            if(caseHistory.date_first_list !=null)
            {
                if(caseHistory.date_first_list =='Date Not Given')
                {   
                 dt_first_hearing= caseHistory.date_first_list;  
                }                
                else {
            //first hearing date
                    var newcaseHistoryay1 = caseHistory.date_first_list.split('-');
                    //from caseHistoryay concatenate into new date string format: "DD.MM.YYYY"
                    dt_first_hearing = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
                }
                $('#hearing_date').show();
                document.getElementById('firsthearingDtId').innerHTML = dt_first_hearing;
            }
            else
            {
                $('#hearing_date').hide();             
            }
            var trans_est_flag=caseHistory.transfer_est_flag;
            var trans_est_name=caseHistory.transfer_est_name;
            var trans_est_date_ymd=caseHistory.transfer_est_date;
            if (trans_est_flag=='Y' ||  trans_est_flag=='N')
            {
            document.getElementById('transEstNamerow').style.display='';
            document.getElementById('transEstDaterow').style.display=''; 
            document.getElementById('transEstNameLabel').innerHTML = '';
            var trans_est_date_split='';
            var trans_est_date_dmy='';
            if(trans_est_date_ymd!=null)
            {
                trans_est_date_split=trans_est_date_ymd.split('-');
                trans_est_date_dmy=(trans_est_date_split[2] + "-" + trans_est_date_split[1] +"-"+ trans_est_date_split[0]);
            }
            else
            {
                    trans_est_date_dmy='';
            }
            if(trans_est_flag=='Y')
            {
               document.getElementById('transEstNameLabel').innerHTML = "Case Transfered To Establishment";
            } 
            else
            {
                document.getElementById('transEstNameLabel').innerHTML = "Case Transfered From Establishment"; 
            }
             document.getElementById('transEstNameId').innerHTML = trans_est_name;   
             document.getElementById('transEstDateId').innerHTML = trans_est_date_dmy;
            }
            else
            {
            document.getElementById('transEstNamerow').style.display='none';
            document.getElementById('transEstDaterow').style.display='none';  
            }

    //court no and judge
            var court_number = '';
            if (caseHistory.court_no != 0) {
                court_number = caseHistory.court_no + '-';
            }
            var court_no_desg_name = court_number + caseHistory.court_judge;
            var bench_name = caseHistory.bench_name;
            var judicial_branch = caseHistory.judicialsection;
            var case_state1 = caseHistory.caseState;
            var case_district = caseHistory.caseDist;
            var causelist_type = caseHistory.CauselistType;
            desg_name = caseHistory.desgname;
            if(court_no_desg_name!=null && court_no_desg_name!='')
            {
                $("#coram").show();
                document.getElementById('courtNoId').innerHTML = court_no_desg_name;
            }else{
                $("#coram").hide();
            }            
            if(bench_name!=null)
            {
                $("#bench").show();
                document.getElementById('benchType').innerHTML = bench_name;
            }else{
                $("#bench").hide();
            }            
            if(judicial_branch!=null)
            {
                $("#judicial").show();
                document.getElementById('judicialBranch').innerHTML = judicial_branch;
            }else{
                $("#judicial").hide();
            }
            if(causelist_type != null)
            {
                $('#causelistTr').show();   
                document.getElementById('causelistType').innerHTML = causelist_type; 
            }
            else
                $('#causelistTr').hide();            
            if(case_state1 != null)
            {
                $('#stateTr').show();
                document.getElementById('state').innerHTML = case_state1;                 
            }  
            else
                $('#stateTr').hide();            
            if(case_district != null)
            {
                $('#districtTr').show();  
                document.getElementById('district').innerHTML = case_district;   
            }    
            else
                $('#districtTr').hide();

    //petitioner and advocate
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

            /**************Acts******************/
            var actTable = caseHistory.act;
            if (actTable != null) {
                $("#actsCollapseId").append(actTable);
            } else {
                document.getElementById('brActs').style.display = 'none';
                document.getElementById('actsTableId').style.display = 'none';
            }
            
            
            /*************** Category Details ***********/
            var categoryTable = caseHistory.category_details;
            if (categoryTable != null) {
                $("#categoryCollapseId").append(categoryTable);
            } else {
                document.getElementById('brCategory').style.display = 'none';
                document.getElementById('categoryTableId').style.display = 'none';
            }
            
            /*************** Case Conversion ***********/
            var caseconversionTable = caseHistory.case_convrsion;
            if (caseconversionTable != null) {
                $("#caseconversionCollapseId").append(caseconversionTable);
            } else {
                document.getElementById('brCaseconversion').style.display = 'none';
                document.getElementById('caseconversionTableId').style.display = 'none';
            }
            
            /*************** Main matter Details ***********/
            var mainmatterTable = caseHistory.main_matter;
            if (mainmatterTable != null) {
                $("#mainmatterCollapseId").append(mainmatterTable);
            } else {
                document.getElementById('brMainmatter').style.display = 'none';
                document.getElementById('mainmatterTableId').style.display = 'none';
            }
            
            /*************** Sub matter Details ***********/
            var submatterTable = caseHistory.sub_matter;
            if (submatterTable != null) {
                $("#submatterCollapseId").append(submatterTable);
            } else {
                document.getElementById('brSubmatter').style.display = 'none';
                document.getElementById('submatterTableId').style.display = 'none';
            }
            
            /*************** IA Filing Details ***********/
            var iaDetailsTable = caseHistory.iaFiling;
            if (iaDetailsTable != null) {
                $("#iaDetailsCollapseId").append(iaDetailsTable);
            } else {
                document.getElementById('brIaDetails').style.display = 'none';
                document.getElementById('IaTableId').style.display = 'none';
            }
            
            /*************** Linked Cases Details ***********/
            var linkedDetailsTable = caseHistory.link_cases;
            if (linkedDetailsTable != null) {
                $("#linkedDetailsCollapseId").append(linkedDetailsTable);
            } else {
                document.getElementById('brLinkedDetails').style.display = 'none';
                document.getElementById('LinkedTableId').style.display = 'none';
            }
            

            /**************FIR******************/
            var firDetailsStr = caseHistory.fir_details;
            if (firDetailsStr != null) {
                firDetails = [];
                firDetails = firDetailsStr.split("^");
                if(firDetails[1]!='')
                {
                    document.getElementById('policeStationId').innerHTML = firDetails[1];
                    document.getElementById('firNoId').innerHTML = firDetails[0];
                    document.getElementById('firDetailsyearId').innerHTML = firDetails[2];
                }
                else
                {
                    document.getElementById('brFIR').style.display = 'none';
                    document.getElementById('firTableId').style.display = 'none';
                }
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
                    //from caseHistoryay concatenate into new date string format: "DD.MM.YYYY"
                    caseDecisionDt = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
                }
                document.getElementById('caseDecisionAndDateId').innerHTML = caseDecisionDt;
            } else {
                document.getElementById('brSubordinate').style.display = 'none';
                document.getElementById('subordinateCourtInfoId').style.display = 'none';
            }

            /**************History******************/
            var historyTable = caseHistory.historyOfCaseHearing;
            if (historyTable != null) {
                $("#historyCollapseId").append(historyTable);
            } else {
                document.getElementById('brHistory').style.display = 'none';
                document.getElementById('historyTableId').style.display = 'none';
            }
            
            /**************Processes******************/
            var processTable = caseHistory.processes;
            if (processTable != null) {
                $("#processCollapseId").append(processTable);
            } else {
                document.getElementById('brProcess').style.display = 'none';
                document.getElementById('processTableId').style.display = 'none';
            }

            /**************Interim Order******************/
            var interimOrderTable = caseHistory.interimOrder;
            if (interimOrderTable != null) {
                $("#interimOrderCollapseId").append(interimOrderTable);
            } else {
                document.getElementById('brOrderInterim').style.display = 'none';
                document.getElementById('interimOrderTableId').style.display = 'none';
            }


            /**************Final Order******************/
            var finalOrderTable = caseHistory.finalOrder;
            if (finalOrderTable != null) {
                $("#finalOrderCollapseId").append(finalOrderTable);
            } else {
                document.getElementById('brOrderFinal').style.display = 'none';
                document.getElementById('finalOrderTableId').style.display = 'none';
            } 
            
            
            /**************Document Details******************/
            var documentDetailsTable = caseHistory.document_details;
            if (documentDetailsTable != null) {
                $("#documentDetailsCollapseId").append(documentDetailsTable);
            } else {
                document.getElementById('brDocumentDetails').style.display = 'none';
                document.getElementById('documentDetailsTableId').style.display = 'none';
            }

             /**************Objection Details******************/
            var objectionDetailsTable = caseHistory.objection;
            if (objectionDetailsTable != null) {
                $('#objectionTableId').show();
                $("#objectionCollapseId").append(objectionDetailsTable);
            } else {
                $('#objectionTableId').hide();
                document.getElementById('brObjection').style.display = 'none';
                document.getElementById('objectionTableId').style.display = 'none';
            }
            
            /**************Transfer******************/
            var caseTransferTable = caseHistory.transfer;
            if (caseTransferTable != null) {
                $("#caseTransferCollapseId").append(caseTransferTable);
            } else {
                document.getElementById('brCaseTransfer').style.display = 'none';
                document.getElementById('caseTransferTableId').style.display = 'none';
            }

            var writTable = caseHistory.writinfo;
            if (writTable != null) {
                $("#writCollapseId").append(writTable);
            } else {
                document.getElementById('brWrit').style.display = 'none';
                document.getElementById('writTableId').style.display = 'none';
            }
            date_of_decision = caseHistory.date_of_decision;
            if (date_of_decision != null) {
    //date of decision        
                var newcaseHistoryay1 = caseHistory.date_of_decision.split('-');
                //from caseHistoryay concatenate into new date string format: "DD.MM.YYYY"
                var dt_decision = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
                document.getElementById('decisionDateId').innerHTML = dt_decision;
    //case status
                document.getElementById('caseStatusId').innerHTML = 'CASE DISPOSED';
    //nature of disposal
                var dispName = caseHistory.disp_name ? caseHistory.disp_name : "";   
                disp_name = dispName;           
                var goshwara = caseHistory.goshwara_no;
                var disp_nature1 = '';
                if(goshwara==1)
                {
                        disp_nature1='Contested';
                }
                if(goshwara==2)
                {
                        disp_nature1='Uncontested';
                }
                dispName=disp_nature1+"--"+dispName;                
                document.getElementById('natureOfDisposalId').innerHTML = dispName;
                document.getElementById('stageofcaserow').style.display = 'none';
                document.getElementById('nextHearingDaterow').style.display = 'none';
                document.getElementById('decisionDateDaterow').style.display = 'table-row';
                document.getElementById('caseStatusrow').style.display = 'table-row';
                document.getElementById('natureOfDisposalrow').style.display = 'table-row';
            } else {
                document.getElementById('stageofcaserow').style.display = 'table-row';
                document.getElementById('nextHearingDaterow').style.display = 'table-row';
                document.getElementById('decisionDateDaterow').style.display = 'none';
                document.getElementById('caseStatusrow').style.display = 'none';
                document.getElementById('natureOfDisposalrow').style.display = 'none';

    //stage of case
                if(caseHistory.purpose_name!=null)
                    {
                        $("#stageofcaserow").show();
                        document.getElementById('stageofcaseId').innerHTML = caseHistory.purpose_name;
                    }
                else{
                        $("#stageofcaserow").hide();
                    }                
                    purpose_name = caseHistory.purpose_name ? caseHistory.purpose_name : '';
                    
    //next hearing date  
                var datenextlist = "";
                if(caseHistory.date_next_list!=null){ 
                    if(caseHistory.date_next_list){
                        if(caseHistory.date_next_list =='Date Not Given')
                        {   
                            datenextlist= caseHistory.date_next_list;  
                        }
                        else
                        {
                            var newcaseHistoryay1 = caseHistory.date_next_list.split('-');            
                            datenextlist = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);                              
                        }    
                    }
                    $("#nextHearingDaterow").show();
                    document.getElementById('nexthearingDtId').innerHTML = datenextlist;     
                }else{
                    $("#nextHearingDaterow").hide();
                }
            }
        }else{
            $("#historyContainer").hide();
            // var caseno = getParameterByName('caseno');
            var caseno = window.sessionStorage.getItem("CASE_NOT_EXIST_CASENO") ? (window.sessionStorage.getItem("CASE_NOT_EXIST_CASENO")) : null;

            $("#errorOpnening").show();
            document.getElementById("errMsg").innerHTML = "Error opening case history for case number: <br/> "+caseno;
        }        
        $("#footer").load("footer.html");
    });
    /*
    To save this case to local storage or Remove it from local storage depending on clicked button id.
    If case already exist, then it will display either saved case(If called from my cases) or Remove case(otherwise)
    *@clicked_id : Add case button id or Remove case button id
    */
    function addCase(clicked_id) {
        var caseInfoArray = window.localStorage.getItem("CNR Numbers HC");
        caseInfoArray = (caseInfoArray === null) ? [] : JSON.parse(caseInfoArray);
        //If called from My cases, cino is passed as parameter
        // var cinumber = getParameterByName('cino');
        var cinumber = window.sessionStorage.getItem("CINO") ? (window.sessionStorage.getItem("CINO")) : null;
        var caseNotExistFlag = window.sessionStorage.getItem("CASE_NOT_EXIST") ? (window.sessionStorage.getItem("CASE_NOT_EXIST")) : null;
        
        var substr = '';
        if(cinumber){
            substr = cinumber;
        }else{
            if(caseNotExistFlag){
                substr = (window.sessionStorage.getItem("CASE_NOT_EXIST_CINO"));
            }else{
                var caseInfoStr = createJSONArray();        
                substr = ciNumber;    
            }
        }
        var index = caseInfoArray.containsSubStringOrHasSubstringOf( substr.trim());
        if (index != -1) {
            if (clicked_id == "addCaseButton") {
                alert("Case Already Added");
                return false;
            } else if (clicked_id == "removeCaseButton") {
                if(!alert("Case removed successfully")){
                    myApp.showPleaseWait();
                    caseInfoArray.splice(index, 1);
                    localStorage.setItem("CNR Numbers HC", JSON.stringify(caseInfoArray));
                    setTimeout(function (){ 
                        $("#My_Cases_pannel").trigger("caseRemoved");
                    },400);
                    // alert("Case removed successfully");
                    $("#caseHistoryModal_hc").hide();
                    $("#caseHistoryModal_hc").modal('hide');
                }                
            }
        } else {            
            //alert("Case Added Successfully");
            if(!alert("Case Added Successfully")){
                myApp.showPleaseWait();
                var caseInfoStr = createJSONArray();
                caseInfoArray.push(caseInfoStr);
                var newStr = JSON.stringify(caseInfoArray);
                localStorage.setItem("CNR Numbers HC", newStr);
                document.getElementById("saved_case").style.display = "block";
                document.getElementById("add_case").style.display = "none";  

                setTimeout(function (){ 
                    $("#My_Cases_pannel").trigger("caseAdded");
                },400);
                
                if(noteVar != ""){
                    document.getElementById("Chevron_icon").style.display = "none";
                }
            }            
        }
    }

    //create JSON array from data fetched from web service to save it to local storage
    function createJSONArray() {
        var caseInfoArray = window.localStorage.getItem("CNR Numbers HC");
        caseInfoArray = (caseInfoArray === null) ? [] : JSON.parse(caseInfoArray);        
        var jsonData = {};
        jsonData["cino"] = ciNumber;
        jsonData["type_name"] = type_name;
        jsonData["case_no"] = case_no;
        jsonData["reg_year"] = reg_year;
        jsonData["reg_no"] = reg_no;
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
        jsonData["court_no_desg_name"] = desg_name;
        jsonData["note"] = noteVar; 
        jsonData["disp_name"] = disp_name; 
        jsonData["purpose_name"] = purpose_name;
               
        var caseInfoStr = JSON.stringify(jsonData);
        return caseInfoStr;
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
    function viewBusiness(court_code, dist_code, n_dt, case_number, state_code, businessStatus, todays_date1, court_no, srno) {
        var viewBusinessData = {court_code:(court_code), dist_code:(dist_code), nextdate1:(n_dt), case_number1:(case_number), state_code:(state_code), disposal_flag:(businessStatus), businessDate:(todays_date1), court_no:(court_no), srno:(srno)};
        var showBusinessWebServiceUrl = hostIP + "s_show_business.php";
        //web service call to get data for view business screen
            callToWebService(showBusinessWebServiceUrl, viewBusinessData, viewBusinesssearchResult);
            function viewBusinesssearchResult(data){
            myApp.hidePleaseWait();
            var viewBusinessObj = (data);             
            window.localStorage.setItem('viewBusinessLocalStorageVar',viewBusinessObj.viewBusiness);            
            $.ajax({
                type: "GET",
                url: "view_business.html"
            }).done(function(data) {
                
                $("#businessData").html($(data));
                $("#viewBusinessModal").modal();            
            });
        }
    }

    /*
    called from web service after link click on history
    @court_code : court code
    @dist_code : district code
    @state_code : state code
    @case_number : case number
    @app_cs_no : app cs no
    */
    function viewWritInfo(court_code, dist_code, state_code, case_number, app_cs_no) {
        var writData = {court_code:(court_code), dist_code:(dist_code),  case_number1:(case_number), state_code:(state_code),
        app_cs_no:(app_cs_no)};
        var writInfoWebServiceUrl = hostIP + "s_show_app.php";
        callToWebService(writInfoWebServiceUrl, writData, writInfosearchResult);
        function writInfosearchResult(data){
            myApp.hidePleaseWait();
            var writInfoObj = (data); 
            window.localStorage.setItem('writInfoSessionStorageVar',writInfoObj.writInfo);
            $.ajax({
                type: "GET",
                url: "writ_information.html"
            }).done(function(data) {    
                
                $("#writData").html($(data));
                $("#writInfoModal").modal();       
             });
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

        function go_back_link_history_fun_hc(){
            $("#casedetailslink").focus();
            document.getElementById("saved_case").style.display = "none";
            document.getElementById("add_case").style.display = "block"; 
            backButtonHistory.pop();
            $("#caseHistoryModal_hc").hide();
            window.sessionStorage.removeItem("case_history");
            window.sessionStorage.removeItem("CASE_NOT_EXIST");
            window.sessionStorage.removeItem("CASE_NOT_EXIST_CASENO");
            window.sessionStorage.removeItem("CASE_NOT_EXIST_CINO");
            window.sessionStorage.removeItem("CINO");

            $("#caseHistoryModal_hc").modal('hide');  
              
        }

    $("#menubarClose_history_hc").click(function ()
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

function deleteNoteToDb(){
    
    if(RemoveNoteToCase()){
        closeNoteModal();
        $('#noteTextDisplayDiv').hide();
        $('#Chevron_icon').show();
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
    
    tmp_note_var='';
    noteVar = $("#noteForAddedCase").val();
    tmp_note_var = noteVar;
    if(isValidNote()){
        addNote();    
        document.getElementById("noteTextDisplay").innerHTML = tmp_note_var;
        $("#addNoteModalForAddedCase").modal('hide');
    }else{
        showErrorMessage("Please Enter valid note");
        return false;
    }
}


//This function is called when clicked on add icon for case which is not yet added to history.
function addNoteToCase(){
    tmp_note_var='';
    noteVar = $("#note").val();
    tmp_note_var=noteVar;
    if(isValidNote()){
        addNote();

        document.getElementById("noteTextDisplay").innerHTML = tmp_note_var;
        document.getElementById("noteTextDisplayDiv").style.display = "block"; 
        document.getElementById("noteForAddedCase").innerHTML = tmp_note_var;
        return true;
    }else{
        showErrorMessage("Please Enter valid note");
        return false;
    }
}

function RemoveNoteToCase(){
    tmp_notevar='';
    noteVar = '';
    tmp_notevar = noteVar;
    // if(isValidNote()){
        RemoveNote();

        document.getElementById("noteTextDisplay").innerHTML = tmp_notevar;
        document.getElementById("noteTextDisplayDiv").style.display = "block"; 
        document.getElementById("noteForAddedCase").innerHTML = tmp_notevar;
        return true;
    // }else{
    //     showErrorMessage(labelsarr[831]);
    //     return false;
    
}

function addNote(){
    var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
        var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
        
        var index = cnrNumbersArray ? cnrNumbersArray.containsSubStringOrHasSubstringOf( ciNumber) : -1;
        if(index != -1){
            //if case is not added already
            var jsonobj = JSON.parse(cnrNumbersArray[index]);
            jsonobj.note = noteVar;
            cnrNumbersArray[index] = JSON.stringify(jsonobj);
            localStorage.setItem("CNR Numbers HC", JSON.stringify(cnrNumbersArray));
            $("#My_Cases_pannel").trigger("caseAdded");

        }else{
            //if case is added already
            addCase("addCaseButton");
        }
    
}

function RemoveNote(){
    var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers HC");
        var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
        
        var index = cnrNumbersArray ? cnrNumbersArray.containsSubStringOrHasSubstringOf( ciNumber) : -1;
        if(index != -1){
            //if case is not added already
            var jsonobj = JSON.parse(cnrNumbersArray[index]);
            jsonobj.note = "";
            cnrNumbersArray[index] = JSON.stringify(jsonobj);
            localStorage.setItem("CNR Numbers HC", JSON.stringify(cnrNumbersArray));
            $("#My_Cases_pannel").trigger("caseAdded");
            // console.log('Note Removed');
        }else{
            //if case is added already
            // console.log('Note Removal Failed');
        }
    
}

//This function is called when clicked on add icon for case which is not yet added to history.
/*function addNoteToCase(){
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
    ///^[a-zA-z.\0-9-+()$*@&!?,]*$/;
    ///[`!@#$%^&*()_+\=\[\]{}':"\\|,<>\/?~]/;
    ///^[a-zA-z.\0-9+()$*@&!?,]*$/; 
    var patt = /[`!@#$%^&*()_+\=\[\]{}':"\\|,<>\/?~]/;   
//    var patt = new RegExp(/^[a-zA-z.\' ] ?([a-zA-z.\' ]|[a-zA-z.\' ] )*[a-zA-z.\' ]$/);    
   // return (patt.test(noteVar));
   if(patt.test(noteVar)){        
    return false;
}else{
    return true;
} 
}
