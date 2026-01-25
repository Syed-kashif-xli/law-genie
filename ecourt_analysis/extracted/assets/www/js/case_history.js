var ltype_name;
var lpetparty_name;
var lresparty_name;
var lestablishment_name;
var lstate_name;
var ldistrict_name;
var lcourt_no_desg_name;
var tmp_notevar='';
var disp_name='';
var ldisp_name=''; 
var purpose_name='';
var lpurpose_name='';
//variable to check If state code of current case is there in selected language state codes
var stateCodePresentInSelectedLanguage;

var transToEstNameLabel = "Case Transfered To Establishment";
var transFromEstNameLabel = "Case Transfered From Establishment";

var caseAddedLabel = "Case Added Successfully";
var caseRemovedLabel = "Case Removed Successfully";

    $(document).ready(function () {
        backButtonHistory.push("casehistory");
        function localizeLabels(){
            // if(stateCodePresentInSelectedLanguage){
                var labelsarr = JSON.parse(window.sessionStorage.GLOBAL_LABELS);       
                $("#case_history_label").html(labelsarr[137]);
                $("#case_details_label").html(labelsarr[136]);
                $("#caseType_label").html(labelsarr[12]);
                $("#filingNumber_label").html(labelsarr[120]);
                $("#filing_date_label").html(labelsarr[124]);
                $("#registration_no_label").html(labelsarr[142]);
                $("#registration_date_label").html(labelsarr[143]);
                $("#CNR_no_label").html(labelsarr[144]);
                $("#casestatus_label").html(labelsarr[11]);
                $("#first_hearing_date_label").html(labelsarr[145]);
                $("#next_hearing_date_label").html(labelsarr[91]);
                $("#stage_of_case_label").html(labelsarr[92]);
                $("#decision_date_label").html(labelsarr[146]);
                $("#case_status_label").html(labelsarr[11]);
                $("#nature_of_disposal_label").html(labelsarr[147]);
                $("#transToEstNameLabel").html(labelsarr[326]);
                $("#transFromEstNameLabel").html(labelsarr[324]);
                $("#transfer_date_label").html(labelsarr[171]);
                $("#court_no_label").html(labelsarr[18]);
                $("#and_label").html(labelsarr[175]);
                $("#judge_label").html(labelsarr[150]);
                $("#QR_code_label").html(labelsarr[784]);        
                $("#pet_and_advoc1").html(labelsarr[122]);
                $("#pet_and_advoc2").html(labelsarr[175]);
                $("#pet_and_advoc3").html(labelsarr[3]);
                $("#resp_and_advoc1").html(labelsarr[470]);
                $("#resp_and_advoc2").html(labelsarr[175]);
                $("#resp_and_advoc3").html(labelsarr[3]);         
                $("#acts_label").html(labelsarr[177]);
                $("#main_matters_label").html(labelsarr[231]);
                $("#sub_matters_label").html(labelsarr[233]);
                $("#IA_details_label").html(labelsarr[567]);
                $("#linked_cases_label").html(labelsarr[570]);
                $("#FIR_details_label").html(labelsarr[158]);
                $("#policeStation_label").html(labelsarr[56]);
                $("#FIR_no_label").html(labelsarr[22]);
                $("#yearLabel").html(labelsarr[81]);        
                $("#case_no_and_year_label1").html(labelsarr[10]);
                $("#case_no_and_year_label2").html(labelsarr[175]);
                $("#case_no_and_year_label3").html(labelsarr[81]);
                $("#subord_court_info_label").html(labelsarr[156]);
                $("#court_no_and_name_label1").html(labelsarr[18]);
                $("#court_no_and_name_label2").html(labelsarr[175]);
                $("#court_no_and_name_label3").html(labelsarr[176]);
                $("#case_decision_date_label").html(labelsarr[771]);
                $("#hist_case_hearing_label").html(labelsarr[128]);
                $("#writ_info_label").html(labelsarr[162]);
                $("#case_trans_det_bet_courts_label").html(labelsarr[170]);
                $("#interim_orders_label").html(labelsarr[599]);
                $("#processes_label").html(labelsarr[616]);
                $("#final_orders_judgemnt_label1").html(labelsarr[600]);
                $("#final_orders_judgemnt_label2").html(labelsarr[313]);
                caseAddedLabel = labelsarr[631];
                caseRemovedLabel = labelsarr[632];
                $("#addcaselabel").html(labelsarr[768]);
                $("#savedcaselabel").html(labelsarr[773]);
                $("#note_label").html(labelsarr[818]+": ");
                $(".addnotecase").html(labelsarr[829]);
                $("#addNoteModal_label_case").html(labelsarr[829]);
                $("#addNoteModalForAddedCase_lbl_case").html(labelsarr[829]);
                $('#note').attr('placeholder',labelsarr[817]);  
                $('#noteForAddedCase').attr('placeholder',labelsarr[817]); 
            // }
        }
        
        $("#header_srchpage1").load("case_history_header.html", function (response, status, xhr) {
            var labelsarr = JSON.parse(window.sessionStorage.GLOBAL_LABELS);            

            $('#go_back_link_3').on('click', function (event) { 
                backButtonHistory.pop();                
                document.getElementById("saved_case").style.display = "none";
                document.getElementById("add_case").style.display = "block";        
                $("#history_location_btn").focus();   
                $("#caseHistoryModal").hide();
                window.sessionStorage.removeItem("case_history");
                window.sessionStorage.removeItem("CASE_NOT_EXIST");
                window.sessionStorage.removeItem("CASE_NOT_EXIST_CASENO");
                window.sessionStorage.removeItem("CASE_NOT_EXIST_CINO");
                window.sessionStorage.removeItem("CINO");
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
            // flag = getParameterByName('flag');

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
            //     window.location.replace("index.html");
            // });
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

            if(cinumber){
                substr = cinumber;
            }else{
                // var caseNotExistFlag = getParameterByName('caseNotExist');
                if(!caseNotExistFlag){
                    // var caseInfoStr = createJSONArray();
                    //substr = caseInfoStr.substring(9,25);
                    var obj1 = window.sessionStorage.getItem('case_history');
                    var history1 = obj1 ? JSON.parse(obj1) : null;                                       
                    if(obj1!=null||obj1!=''){
                        substr =history1.cino;
                    }
                    
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

        //get history data from session storage

        var retrievedObject = window.sessionStorage.getItem('case_history');
        var caseHistory = retrievedObject ? JSON.parse(retrievedObject) : null;
        if (caseHistory != null) {            
            complex_code = caseHistory.complex_code;            
            court_code = caseHistory.court_code;            
            establishment_name = caseHistory.court_name;
            lestablishment_name = caseHistory.lcourt_name;
            establishment_code = caseHistory.est_code;
            state_code = caseHistory.state_code;
            district_code = caseHistory.district_code;
            state_name = caseHistory.state_name;
            lstate_name = caseHistory.lstate_name;
            district_name = caseHistory.district_name;
            ldistrict_name = caseHistory.ldistrict_name;
            hide_pet_name = caseHistory.hide_pet_name;
            hide_partyname_est = caseHistory.hide_partyname_est;
            hide_res_name = caseHistory.hide_res_name;       
            stateCodePresentInSelectedLanguage = localizedStateCodesArr.indexOf(parseInt(state_code)) == -1 ? false : true;
            if(caseHistory.date_last_list == null){
                date_last_list = '';
            }else{
                date_last_list = caseHistory.date_last_list;
            }
            date_next_list = caseHistory.date_next_list;
            petparty_name = caseHistory.pet_name;
            if(hide_pet_name == 'Y' || hide_partyname_est == 'Y' || hide_partyname_est == 'y'){
                lpetparty_name = caseHistory.petparty_name;
            }else{
                 lpetparty_name = caseHistory.lpet_name;
            }
            resparty_name = caseHistory.res_name;
            if(hide_res_name == 'Y' || hide_partyname_est == 'Y' || hide_partyname_est == 'y'){
                lresparty_name = caseHistory.resparty_name;
            }else{
                lresparty_name = caseHistory.lres_name;
            }                
            ciNumber = caseHistory.cino;
            $('#qrcode').qrcode({width: 64,height: 64,text: ciNumber});            
            //code to update pet name to local storage if changed
            var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers");
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
            }
            
            /**************Case Details******************/

     //heading 
            if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
                document.getElementById('court_name').innerHTML = caseHistory.court_name;
            }else{
                document.getElementById('court_name').innerHTML = caseHistory.lcourt_name;
            }
            court_name = caseHistory.court_name;

    //case type
            type_name = caseHistory.type_name;
            ltype_name = caseHistory.ltype_name;
            if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
                document.getElementById('caseTypeId').innerHTML = caseHistory.type_name;
             }else{
                document.getElementById('caseTypeId').innerHTML = caseHistory.ltype_name;
             }
            

    //filing number
            var filing_number = caseHistory.fil_no + "/" + caseHistory.fil_year;
            document.getElementById('filingNumberId').innerHTML = filing_number;

    //Registration number
            var registration_number = caseHistory.reg_no + "/" + caseHistory.reg_year;
            document.getElementById('regNumberId').innerHTML = registration_number;
            case_no = caseHistory.case_no;
            reg_no = caseHistory.reg_no;
            reg_year = caseHistory.reg_year;

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
            if(caseHistory.dt_regis){
                var newcaseHistoryay = caseHistory.dt_regis.split('-');
                //from caseHistoryay concatenate into new date string format: "DD.MM.YYYY"
                newDateDtRegis = (newcaseHistoryay[2] + "-" + newcaseHistoryay[1] + "-" + newcaseHistoryay[0]);
            }
            document.getElementById('regDateId').innerHTML = newDateDtRegis;

    //CNR number
            var org_type = caseHistory.cino.slice(0, 6);
            var serialNo = caseHistory.cino.slice(6, 12);
            var ciyear = caseHistory.cino.slice(12, 16);
            disp_ci_no = org_type + '-' + serialNo + '-' + ciyear;
            document.getElementById('cnrnoId').innerHTML = caseHistory.cino;
            
            /**************Case Status******************/
            var dt_first_hearing = "";
            if (caseHistory.date_first_list) {
    //first hearing date
                var newcaseHistoryay1 = caseHistory.date_first_list.split('-');
                //from caseHistoryay concatenate into new date string format: "DD.MM.YYYY"
                dt_first_hearing = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);

            }
            document.getElementById('firsthearingDtId').innerHTML = dt_first_hearing;

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
               document.getElementById('transEstNameLabel').innerHTML = transToEstNameLabel;
            } 
            else
            {
                document.getElementById('transEstNameLabel').innerHTML = transFromEstNameLabel; 
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
            if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
                var court_no_desg_name = court_number + caseHistory.desgname;
            }else{
                var court_no_desg_name = court_number + caseHistory.ldesgname;
            }
            desg_name = caseHistory.desgname;
            ldesg_name = caseHistory.ldesgname;
            document.getElementById('courtNoId').innerHTML = court_no_desg_name;

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
                document.getElementById('caseStatusId').innerHTML = labelsarr[141];
                
    //nature of disposal
                if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
                    var dispName = caseHistory.disp_name ? caseHistory.disp_name : "";                     
                }else{
                    var dispName = caseHistory.ldisp_name ? caseHistory.ldisp_name : "";                    
                }  
                disp_name= caseHistory.disp_name;      
                ldisp_name= caseHistory.ldisp_name;          
                var goshwara = caseHistory.goshwara_no;
                var disp_nature1 = '';
                if(goshwara==1)
                {
                        disp_nature1=labelsarr[299];
                }
                if(goshwara==2)
                {
                        disp_nature1=labelsarr[300];
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
               if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
                    document.getElementById('stageofcaseId').innerHTML = caseHistory.purpose_name;
               }else{
                   document.getElementById('stageofcaseId').innerHTML = caseHistory.lpurpose_name;
               }
               purpose_name = caseHistory.purpose_name ? caseHistory.purpose_name : '';
               lpurpose_name = caseHistory.lpurpose_name ? caseHistory.lpurpose_name : '';
    //next hearing date  
                var datenextlist = "";
                if(caseHistory.date_next_list){
                    var newcaseHistoryay1 = caseHistory.date_next_list.split('-');            
                    datenextlist = (newcaseHistoryay1[2] + "-" + newcaseHistoryay1[1] + "-" + newcaseHistoryay1[0]);
                }
                document.getElementById('nexthearingDtId').innerHTML = datenextlist;

            }
        }else{
            $("#historyContainer").hide();
            document.getElementById("history_location_btn").style.display="none";
            //var caseno = getParameterByName('caseno');
            var caseno = window.sessionStorage.getItem("CASE_NOT_EXIST_CASENO") ? (window.sessionStorage.getItem("CASE_NOT_EXIST_CASENO")) : null;
            $("#errorOpnening").show();
            document.getElementById("errMsg").innerHTML = "Error opening case history for case number: <br/> "+caseno;
        }
        $("#footer").load("footer.html");
        localizeLabels();
    });

    /*
    To save this case to local storage or Remove it from local storage depending on clicked button id.
    If case already exist, then it will display either saved case(If called from my cases) or Remove case(otherwise)
    *@clicked_id : Add case button id or Remove case button id
    */
    function addCase(clicked_id) {
        var caseInfoArray = window.localStorage.getItem("CNR Numbers");
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
                alert(labelsarr[830]);
                return false;
            } else if (clicked_id == "removeCaseButton") {
                if(!alert(caseRemovedLabel)){ 
                    myApp.showPleaseWait();
                    caseInfoArray.splice(index, 1);
                    localStorage.setItem("CNR Numbers", JSON.stringify(caseInfoArray));
                    setTimeout(function (){ 
                        $("#My_Cases_pannel").trigger("caseRemoved");
                    },400);
                    // alert(caseRemovedLabel);
                    $("#caseHistoryModal").hide();
                    $("#caseHistoryModal").modal('hide'); 
                }
            }
        } else {
             //alert(caseAddedLabel);
			if(!alert(caseAddedLabel)){                        
                myApp.showPleaseWait();
                var caseInfoStr = createJSONArray();
                caseInfoArray.push(caseInfoStr);
                var newStr = JSON.stringify(caseInfoArray);
                localStorage.setItem("CNR Numbers", newStr);                
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
        var caseInfoArray = window.localStorage.getItem("CNR Numbers");
        caseInfoArray = (caseInfoArray === null) ? [] : JSON.parse(caseInfoArray);
        var jsonData = {};
        jsonData["cino"] = ciNumber;
        jsonData["type_name"] = type_name;
        jsonData["case_no"] = case_no;
        jsonData["reg_year"] = reg_year;
        jsonData["reg_no"] = reg_no;
        jsonData["petparty_name"] = petparty_name;
        jsonData["resparty_name"] = resparty_name;
        jsonData["fil_year"] = '0';
        jsonData["fil_no"] = '0';
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
        jsonData["ltype_name"] = ltype_name;
        jsonData["lpetparty_name"] = lpetparty_name;
        jsonData["lresparty_name"] = lresparty_name;
        jsonData["lestablishment_name"] = lestablishment_name;
        jsonData["lstate_name"] = lstate_name;
        jsonData["ldistrict_name"] = ldistrict_name;
        jsonData["lcourt_no_desg_name"] = ldesg_name;        
        jsonData["note"] = noteVar;  
        jsonData["disp_name"] = disp_name;  
        jsonData["ldisp_name"] = ldisp_name; 
        jsonData["purpose_name"] = purpose_name;  
        jsonData["lpurpose_name"] = lpurpose_name;   
            
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
    function viewBusiness(court_code, dist_code, n_dt, case_number, state_code, businessStatus, todays_date1, court_no) {
        
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
        var  encrypted_data5=0;
        if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
             encrypted_data5 = ("0");
        }else{
             encrypted_data5 = ("1");
        }        
        var viewBusinessData = {court_code:(court_code), dist_code:(dist_code), nextdate1:(n_dt), case_number1:(case_number), state_code:(state_code), disposal_flag:(businessStatus), businessDate:(todays_date1), court_no:(court_no), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
        var showBusinessWebServiceUrl = hostIP + "s_show_business.php";
        //web service call to get data for view business screen
        callToWebService(showBusinessWebServiceUrl, viewBusinessData, viewBusinessResult);
        function viewBusinessResult(data){
            myApp.hidePleaseWait();
            var viewBusinessObj = (data);
            //save business data in local storage to use in view business page
            window.localStorage.setItem('viewBusinessLocalStorageVar',viewBusinessObj.viewBusiness);
            //flag is sent so that if true(If called from my cases) Remove case button can be displayed on page reload
            // window.location = 'view_business.html?go_back_link=' + 'case_history.html'+'&flag='+flag;
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
       
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
        var  encrypted_data5=0;
        if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
             encrypted_data5 = ("0");
        }else{
             encrypted_data5 = ("1");
        }        
        var writData = {court_code:(court_code), dist_code:(dist_code),  case_number1:(case_number), state_code:(state_code),
        app_cs_no:(app_cs_no), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
        var writInfoWebServiceUrl = hostIP + "s_show_app.php";
        callToWebService(writInfoWebServiceUrl, writData, writInfoWebServiceResult);
        function writInfoWebServiceResult(data){
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

    $("#menubarClose_history").click(function ()
    {
        if ($("#mySidenav3").is(':visible'))
        {
            document.getElementById("mySidenav3").style.display = "none";
        } 
    });

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
    
    function mapMarkerClickedFromHistory(){
        window.sessionStorage.setItem("navigation_link", "case_history.html");
        window.sessionStorage.setItem("state_code", state_code);
        window.sessionStorage.setItem("dist_code", district_code);
        window.sessionStorage.setItem("court_code", court_code);
        window.sessionStorage.setItem("complex_code", complex_code);
        $.ajax({
            type: "GET",
            url: 'map.html',
        }).done(function(data) { 
            $("#mapData").html(data);
            $("#mapModal").modal();
        });
    }

    function go_back_link_history_fun(){  
        if(($("#addNoteModalForAddedCase").data('bs.modal') || {})._isShown){              
            $("#addNoteModalForAddedCase").modal('hide');
        }else if(($("#addNoteModal").data('bs.modal') || {})._isShown){            
            $("#addNoteModal").modal('hide');
       }else{                  
            document.getElementById("saved_case").style.display = "none";
            document.getElementById("add_case").style.display = "block";    
            backButtonHistory.pop();       
            $("#history_location_btn").focus();   
            $("#caseHistoryModal").hide();
            window.sessionStorage.removeItem("case_history");
            window.sessionStorage.removeItem("CASE_NOT_EXIST");
            window.sessionStorage.removeItem("CASE_NOT_EXIST_CASENO");
            window.sessionStorage.removeItem("CASE_NOT_EXIST_CINO");
            window.sessionStorage.removeItem("CINO");        
            $("#caseHistoryModal").modal('hide');  
       }
    }


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
      
        $('#noteTextDisplayDiv').hide();
        $("#noteTextDisplayDiv").modal('hide');
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

function RemoveNote(){
    var cnrNumbersLocalStorage = localStorage.getItem("CNR Numbers");
        var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
        
        var index = cnrNumbersArray ? cnrNumbersArray.containsSubStringOrHasSubstringOf( ciNumber) : -1;
        if(index != -1){
            //if case is not added already
            var jsonobj = JSON.parse(cnrNumbersArray[index]);
            jsonobj.note = "";
            cnrNumbersArray[index] = JSON.stringify(jsonobj);
            localStorage.setItem("CNR Numbers", JSON.stringify(cnrNumbersArray));
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
    /* var patt = /^[a-zA-z.\0-9-+()$*@&!?,]*$/;   
    var patt = new RegExp(/^[a-zA-z.\' ] ?([a-zA-z.\' ]|[a-zA-z.\' ] )*[a-zA-z.\' ]$/);    
    return (patt.test(noteVar));*/
// /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/;
    var format = /[`!@#$%^&*()_+\=\[\]{}':"\\|,<>\/?~]/;
    if(format.test(noteVar)){        
        return false;
    }else{
        return true;
    } 
}
