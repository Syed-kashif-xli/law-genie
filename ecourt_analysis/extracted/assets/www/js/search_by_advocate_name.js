var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
if(labelsarr){
    var totalNoOfEstLabel = labelsarr ? labelsarr[390] : "Total Number of Establishments in Court Complex";
    var totalNoOfCasesLabel = labelsarr ? labelsarr[83] : "Total Number of Cases";
    var advoLabel = labelsarr ? labelsarr[3] : "Advocate";
}
        var advocatePlaceholder = "Advocate";
        var barcodePlaceholder = "barcode";
        var yearPlaceholder = "year";
        var statecodePlaceholder = "statecode";

        $(document).ready(function () {
            second_header();
            backButtonHistory.push("searchcasepage");
            sessionStorage.setItem("tab", "#profile");

            var rad = document.parentForm.radOpt;

            document.getElementById("advocateBarCodeId").style.display = "none";
            document.getElementById("caseListDateId").style.display = "none";
            document.getElementById("enterAdvocateNameId").style.display = "block";
            
            populateCourtComplexes();

            var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
            if(labelsarr){
                    $("#casestatus_heading1_label").html(labelsarr[11]);
                    $("#search_by_advocate_name_label").html(labelsarr[63]);
                    $("#court_complex_label").html(labelsarr[269]);
                    $("#search_by_label").html(labelsarr[61]);
                    $("#advoname").html(labelsarr[4]);
                    $("#bar_code").html(labelsarr[5]);
                    $("#datecaselist").html(labelsarr[278]);
                    
                    $("#advocate_bar_code_label1").html(labelsarr[3]);
                    $("#advocate_bar_code_label2").html(labelsarr[5]);

                    $("#case_list_date_label").html(labelsarr[276]);
                    $("#advocate_label").html(labelsarr[3]);
                    $("#rad1").html(labelsarr[31]);
                    $("#rad2").html(labelsarr[21]);
                    $("#rad3").html(labelsarr[7]);
                    $("#goButton").html(labelsarr[26]);
                    $("#resetButton").html(labelsarr[57]);

                    advocatePlaceholder = labelsarr[3];
                    $('#advocate').attr('placeholder',advocatePlaceholder);

                    barcodePlaceholder = labelsarr[5];
                    $('#barcode').attr('placeholder',barcodePlaceholder);
                    yearPlaceholder = labelsarr[81];
                    $('#year').attr('placeholder',yearPlaceholder);
                    statecodePlaceholder = labelsarr[692];
                    $('#statecode').attr('placeholder',statecodePlaceholder);

            }

            $('#court_code').change(function () {
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
                if ($('#court_code').val() != "") {
                    window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
                    window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));
                }else {
                    window.localStorage.removeItem("SESSION_COURT_CODE");
                    window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
                }
                $("#Causelist_pannel").trigger("courtCodeChanged");
            });

            arrCourtEstCodes = [];
     
            $('input[type=radio][name=radOpt]').change(function () {
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
                window.sessionStorage.removeItem("SET_RESULT");
            });

            $('input[type=radio][name=radOpt1]').change(function () {
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            });            

            $("#advocate").on('keydown', function () {
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            });

            $("#statecode").on('keydown', function () {
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            });

            $("#year").on('keydown', function () {
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            });

            $("#barcode").on('keydown', function () {
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            });
        //statecode keydown
            $("#statecode").on('keydown', function () {
                if(window.sessionStorage.SET_RESULT != null){
                    window.sessionStorage.removeItem("SET_RESULT");
                    $("#results_container").empty();
                    $("#advocateHeaders").empty();
                    $("#accordion_search").empty();
                }
                var pat = /^[a-zA-Z]*$/;
                if (pat.test($(this).val()) == false) {
                    $(".statecode").html(" only letter").show().fadeOut("slow");
                    $("#statecode").val("");
                    $("#statecode").focus(); 
                    return false;
                }
            });


        /// barcode keydown

        $("#barcode").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            }
                var pat = /^[0-9]*$/;
                if (pat.test($(this).val()) == false) {
                    $(".barcode").html(" only numbers ").show().fadeOut("slow");
                    $("#barcode").val("");
                    $("#barcode").focus(); 
                    return false;
                }
            });
        $("#barcode").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            }
                window.sessionStorage.removeItem("SET_RESULT");
                if ($(this).val().length >= 7) {                
                    $(".barcode").html(labelsarr[806]).show().fadeOut("slow");
                    $("#barcode").val("");
                    $("#barcode").focus(); 
                    return false;
                }
            });
        /// barcode keydown

        $("#year").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            }
                var pat = /^[0-9]*$/;
                if (pat.test($(this).val()) == false) {
                    $(".year").html(" only numbers ").show().fadeOut("slow");
                    $("#year").val("");
                    $("#year").focus(); 
                    return false;
                }
            });
        });


        //change UI as per radio button change
        $("#radOpt-1").click(function (e) {
            document.getElementById("advocateBarCodeId").style.display = "none";
            document.getElementById("caseListDateId").style.display = "none";
            document.getElementById("enterAdvocateNameId").style.display = "block";
            document.getElementById("pendingDisposedId").style.display = "block";
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            }
        });
        $("#radOpt-2").click(function (e) {
            document.getElementById("advocateBarCodeId").style.display = "block";
            document.getElementById("caseListDateId").style.display = "none";
            document.getElementById("enterAdvocateNameId").style.display = "none";
            document.getElementById("pendingDisposedId").style.display = "block";
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            }

            //fill state code, bar code and year text boxed from local storage
            if (window.localStorage.STATE_CODE != null) {
                $('#statecode').val(window.localStorage.STATE_CODE);
            }
            if (window.localStorage.BAR_CODE != null) {
                $('#barcode').val(window.localStorage.BAR_CODE);
            }
            if (window.localStorage.YEAR != null) {
                $('#year').val(window.localStorage.YEAR);
            }
        });
        $("#radOpt-3").click(function (e) {
            document.getElementById("advocateBarCodeId").style.display = "block";
            document.getElementById("caseListDateId").style.display = "block";
            document.getElementById("enterAdvocateNameId").style.display = "none";
            document.getElementById("pendingDisposedId").style.display = "none";
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#results_container").empty();
                $("#advocateHeaders").empty();
                $("#accordion_search").empty();
            }

            $('#statecode').val(window.localStorage.STATE_CODE);
            $('#barcode').val(window.localStorage.BAR_CODE);
            $('#year').val(window.localStorage.YEAR);

            function clearResult(){
                window.sessionStorage.removeItem("SET_RESULT");
            }

            $('#pickyDate').attr('readonly', true);

            $('#pickyDate').datepicker({dateFormat: 'dd-mm-yy',
                maxDate: +30 ,
            minDate: -7,
            // beforeShowDay: enableAllTheseDays,
            onSelect: clearResult});

            var now = new Date();

            var day = ("0" + now.getDate()).slice(-2);
            var month = ("0" + (now.getMonth() + 1)).slice(-2);

            var today = (day) + "-" + (month) + "-" + now.getFullYear();

            $('#pickyDate').val(today);
        });

        //clear form
        $("#resetButton").click(function (e) {
            e.preventDefault();
            window.localStorage.removeItem('SESSION_COURT_CODE');
            window.sessionStorage.removeItem('SET_RESULT');
            $('#court_code').val("");
            $("#advocate").val("");
            window.localStorage.removeItem("STATE_CODE");
            window.localStorage.removeItem("BAR_CODE");
            window.localStorage.removeItem("YEAR");
            var selectedValue = $('input[name=radOpt]:checked', '#myForm').val();
            var $radios = $('input[name=radOpt1]');
            $radios.filter('[value=Pending]').prop('checked', true);
            if (selectedValue == "1") {
                window.localStorage.removeItem("STATE_CODE");
                window.localStorage.removeItem("BAR_CODE");
                window.localStorage.removeItem("YEAR");

            } else if (selectedValue == "2" || selectedValue == "3") {
                $("#year").val("");
                $("#statecode").val("");
                $("#barcode").val("");
                window.localStorage.removeItem("STATE_CODE");
                window.localStorage.removeItem("BAR_CODE");
                window.localStorage.removeItem("YEAR");
            }
            $("#results_container").empty();
            $("#advocateHeaders").empty();
            $("#accordion_search").empty();
            $("#Causelist_pannel").trigger("courtCodeChanged"); 
            
        });

        //fetch result of Go button click from web service or session storage
        $("#goButton").click(function (e) {
            e.preventDefault();
            if (window.sessionStorage.getItem("SET_RESULT") == null) {
            var year = $("#year").val();
            var statecode = $("#statecode").val();
            var barcode = $("#barcode").val();

            var STATE_CODE = window.localStorage.STATE_CODE;
            var BAR_CODE = window.localStorage.BAR_CODE;
            var YEAR = window.localStorage.YEAR;

            if (STATE_CODE != statecode) {
                window.localStorage.setItem("STATE_CODE", statecode);
            }

            if (BAR_CODE != barcode) {
                window.localStorage.setItem("BAR_CODE", barcode);
            }

            if (YEAR != year) {
                window.localStorage.setItem("YEAR", year);
            }        
            return populateCasesTable();
            } 

        });

        //called when getting data from web service
        function populateCasesTable() {
            $("#results_container").empty();
            $("#advocateHeaders").empty();
            $("#accordion_search").empty();
            var selectboxText = $("#court_code option:selected").text();
            if (window.localStorage.SESSION_COURT_CODE == null || window.localStorage.SESSION_COURT_CODE == '') {
                showErrorMessage(labelsarr[277]);
                //showErrorMessage("Please select court complex");
                return false;
            }

            var date = $('#pickyDate').val();

            var advocateName = $("#advocate").val();
            var year = $("#year").val();
            var statecode = $("#statecode").val();
            var barcode = $("#barcode").val();
            var patt = new RegExp(/^[a-zA-z- ._]*$/);

            checkedSearchByRadioValue = $("input[name='radOpt']:checked").val();


            if (checkedSearchByRadioValue == 1) {
                if (advocateName == '') {
                    showErrorMessage(labelsarr[93]);
                    $("#advocate").focus();
                    return false;
                }
                if(localStorage.LANGUAGE_FLAG=="english"){     
                // if(bilingual_flag == "1"){     
                    if (!patt.test(advocateName)) {
                        showErrorMessage(labelsarr[713]);
                        $("#advocate").val("");
                        $("#advocate").focus(); 
                        return false;
                    }
                }else{
                    var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;
                    if(format.test(advocateName)){ 
                        showErrorMessage(labelsarr[713]);
                        $("#advocate").val("");
                        $("#advocate").focus();    
                        return false;
                    }
                }
                if ($("#advocate").val().length < 3 || $("#advocate").val().length > 99)
                {
                    showErrorMessage(labelsarr[33]);
                    $("#advocate").val("");
                    $("#advocate").focus(); 
                    return false;
                }

            } else if (checkedSearchByRadioValue == 2) {
                if (statecode == '') {
                    showErrorMessage(labelsarr[290]);
                $("#statecode").focus(); 
                    return false;
                }
                if ($("#statecode").val().length > 3){
                    showErrorMessage(labelsarr[703]);
                $("#statecode").val("");
                $("#statecode").focus(); 
                    return false;
                }

                if (!patt.test(statecode)) {

            showErrorMessage(labelsarr[703]);
                $("#statecode").val("");
                $("#statecode").focus(); 
                    return false;
            }

                if (barcode == '') {
                    showErrorMessage(labelsarr[95]);
                    $("#barcode").val("");
                    $("#barcode").focus(); 
                    return false;
                }
                if (barcode <= 0) {
                showErrorMessage(labelsarr[714]);

                $("#barcode").val("");
                $("#barcode").focus(); 
                return false;
                }


                if (barcode <= 0) {
                    showErrorMessage(labelsarr[714]);

                $("#barcode").val("");
                $("#barcode").focus(); 
                    return false;
                }

                    if (year == '') {
                        showErrorMessage(labelsarr[115]);
                        $("#year").focus(); 
                        $("#year").val("");
                        return false;
                    }
                    if (year <= 0) {
                    showErrorMessage(labelsarr[708]);

                    $("#year").focus(); 
                        $("#year").val("");
                    return false;
                }
                if(year.toString().length < 4)
                {
                    showErrorMessage(labelsarr[42]);
                    $("#year").focus(); 
                        $("#year").val("");
                    return false;
                }
                var d = new Date();
            var n = d.getFullYear();
            if (year <= 1900 || year > n)
            {
                showErrorMessage(labelsarr[43] + n);
                $("#year").focus(); 
                        $("#year").val("");
                return false;
            }
            } else if (checkedSearchByRadioValue == 3) {
                if (statecode == '') {
                    showErrorMessage(labelsarr[290]);
                    $("#statecode").focus(); 
                    return false;
                }
                if (barcode == '') {
                    showErrorMessage(labelsarr[95]);
                    $("#barcode").focus(); 
                    return false;
                }
                if (year == '') {
                    showErrorMessage(labelsarr[115]);
                    $("#year").focus(); 
                    return false;
                } 
                if (year <= 0) {
                    showErrorMessage(labelsarr[708]);

                    $("#year").focus(); 
                        $("#year").val("");
                    return false;
                }
                if(year.toString().length < 4)
                {
                    showErrorMessage(labelsarr[42]);
                    $("#year").focus(); 
                        $("#year").val("");
                    return false;
                }
                var d = new Date();
                var n = d.getFullYear();
                if (year <= 1900 || year > n)
                {
                    showErrorMessage(labelsarr[43] + n);
                    $("#year").focus(); 
                    $("#year").val("");
                    return false;
                }

                if (date == '') {
                    showErrorMessage(labelsarr[767]);
                    $("#pickyDate").focus(); 
                    return false;
                }
            }

            var courtCodesArr = window.localStorage.SESSION_COURT_CODE;

            court_code_data = courtCodesArr[0];
            var searchByAdvocateNameUrl = "";

            var pendingDisposed = "";
            arrCourtEstCodes = [];
            arrCourtEstCodes = window.localStorage.SESSION_COURT_CODE.split(",");

            total_Cases = '';

            $("#advocateHeaders").empty();

            var headerArray = [];

            headerArray.push('<label>'+totalNoOfEstLabel+':<span id="totalEstablishmentsSpanId"></span></label></div>');

            headerArray.push('<br>');
            if (checkedSearchByRadioValue == '3') {
                headerArray.push('<label>' + "Advocate's Cause list: " + date + '</label></div>');
                headerArray.push('<br>');
            }

            if (checkedSearchByRadioValue == '2' || checkedSearchByRadioValue == '3') {
                headerArray.push('<label>'+advoLabel+': <span id="advocateNameId"></span></label></div>');
                headerArray.push('<br>');
            }
            headerArray.push('<label>'+totalNoOfCasesLabel+':<span id="totalcasesId"></span></label></div>');

            $("#advocateHeaders").append(headerArray);
            if (checkedSearchByRadioValue == '3') {
                searchByAdvocateNameUrl = hostIP + "causeListWebService.php";
            } else {
                searchByAdvocateNameUrl = hostIP + "searchByAdvocateName.php";
                pendingDisposed = $("input[name='radOpt1']:checked").val();
            }
            var state_code_data = window.localStorage.state_code;
            var district_code_data = window.localStorage.district_code;

            var establishments_count = arrCourtEstCodes.length;
            
            $("#accordion_search").empty();

            var count1 = 0;
            myApp.showPleaseWait(); 
            var jsonData = {};
            var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
            // var  encrypted_data5=0;
            // if(localStorage.LANGUAGE_FLAG=="english"){
            //     encrypted_data5 = ("0");
            // }else{
            //     encrypted_data5 = ("1");
            // }
            var encrypted_data5 = (bilingual_flag.toString());
            //for (var i = 0; i < arrCourtEstCodes.length; i++) {
                //if (arrCourtEstCodes[i] != ",") {            

                    var data = {state_code:(state_code_data), dist_code:(district_code_data), court_code_arr:arrCourtEstCodes.toString(), checkedSearchByRadioValue:(checkedSearchByRadioValue), advocateName:(advocateName), year:(year), barstatecode:(statecode), barcode:(barcode), pendingDisposed:(pendingDisposed), date:(date), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
                    var data1 = {state_code:state_code_data, dist_code:district_code_data, court_code_arr:arrCourtEstCodes.toString(), checkedSearchByRadioValue:checkedSearchByRadioValue, advocateName:advocateName, year:year, barstatecode:statecode, barcode:barcode, pendingDisposed:pendingDisposed, date:date, language_flag:localStorage.LANGUAGE_FLAG, bilingual_flag:bilingual_flag.toString()};
                    var establishment_name;
                    
                    var collapseid = 0;                    
                    //populate the result table with court establishment as collapse field
                    callToWebService(searchByAdvocateNameUrl, data, advocateNameSearchResult);
                    function advocateNameSearchResult(responseData){
                        
                        if (responseData != null) {
                            if(responseData.msg){
                                 if((responseData.status)=='fail'){
                                     myApp.hidePleaseWait();
                                     showErrorMessage((responseData.msg));
                                 }
                            }else{        
                                for(const val in responseData){
                                    var data = responseData[val] ; 
                                                                       
                                var obj_courtcode = (data.court_code);
                                
                                var obj_establishment_name = (data.establishment_name);

                                var obj_caseNos = (data.caseNos);
                                
                                if(data.advocateName != null){
                                    var obj_advocate_name = (data.advocateName);
                                }
                                
                                jsonData[JSON.stringify(obj_courtcode)] = JSON.stringify(data);
                                
                                // window.sessionStorage.setItem("SET_RESULT", JSON.stringify(jsonData));
                                window.sessionStorage.setItem("SET_RESULT", true);

                                

                                var panel_body = [];

                                if (checkedSearchByRadioValue == '2' || checkedSearchByRadioValue == '3') {
                                    var advocateName = obj_advocate_name;
                                    document.getElementById("advocateNameId").innerHTML = advocateName;
                                }
                                
                                var totalCases = Object.keys(obj_caseNos).length;
                                
                                total_Cases = Number(totalCases) + Number(total_Cases);
                                
                                var trHTML = '';
                                var court_code = obj_courtcode;

                                panel_id = 'card' + state_code_data + '_' + district_code_data + '_' + court_code;


                                establishment_name = obj_establishment_name;
                                establishment_name = establishment_name + " : " + totalCases;
                                

                                panel_body.push('<div class="card" >');
                                panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                                if (checkedSearchByRadioValue == '3') {
                                    panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>Party Name</th><th>Court Name</th><th>Stage Of Case</th></tr></thead><tbody>");
                                } else {
                                    panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>Party Name</th><th>Advocate Name</th></tr></thead><tbody>");
                                }
                                
                                collapseid++;
                                var index = 0;
                                var txt_type_name=null;
                                var txt_adv_name1=null;
                                var txt_adv_name2=null;
                                $.each(obj_caseNos, function (key, val) {
                                    index++;
                                    // if(localStorage.LANGUAGE_FLAG=="english"){
                                    if(bilingual_flag == "0"){
                                        txt_type_name=val.type_name;
                                        txt_adv_name1 = val.adv_name1;
                                        txt_adv_name2 = val.adv_name2;
                                    }else{
                                        txt_type_name=val.ltype_name;
                                        txt_adv_name1 = val.ladv_name1;
                                        txt_adv_name2 = val.ladv_name2;
                                    }
                                    
                                    var petresName = val.petnameadArr;


                                    if (checkedSearchByRadioValue == '3') {
                                        var name1 = "";
                                        var name2 = "";
                                        if (val.adv_name1 != null) {
                                            name1 = val.adv_name1;
                                        }
                                        if (val.adv_name2 != null) {
                                            name2 = val.adv_name2;
                                        }
                                        var casehistorylink = '';
                                        if (val.case_no == null) {
                                            casehistorylink = 'filing_case_history_link';
                                        } else {
                                            casehistorylink = 'case_history_link';
                                        }
                                        var advocateName = name1 + "</br>" + name2;
                                        var case_type_number = txt_type_name + '/' + val.case_no2 + '/' + val.case_year;
                                        var hrefurl = "<a data-toggle='modal' data-target='#loading' style='color:#03A8D8;text-decoration: underline;' href='#' class='" + casehistorylink + "  'court_code='" + court_code + "'case_no='" + val.case_no + "'>" + case_type_number + '</a>';

                                        trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + val.court_detArr + "</td><td>" + val.purposeArr + "</td></tr>";
                                        panel_body.push("<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + val.court_detArr + "</td><td>" + val.purposeArr + "</td></tr>");
                                      

                                    } else {
                                        var name1 = "";
                                        var name2 = "";
                                        if (txt_adv_name1 != null) {
                                            name1 = txt_adv_name1;
                                        }
                                        if (txt_adv_name2 != null) {
                                            name2 = txt_adv_name2;
                                        }
                                        var casehistorylink = '';

                                        if (val.case_no == null) {
                                            casehistorylink = 'filing_case_history_link';
                                        } else {
                                            casehistorylink = 'case_history_link';
                                        }
                                        var advocateName = name1 + "</br>" + name2;
                                        var case_type_number = txt_type_name + '/' + val.case_no2 + '/' + val.reg_year;
                                        var hrefurl = "<a data-toggle='modal' data-target='#loading' style='color:#00BEFC;text-decoration: underline;' href='#' class='" + casehistorylink + "  'court_code='" + court_code + "'case_no='" + val.case_no + "'>" + case_type_number + '</a>';

                                        trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + advocateName + "</td></tr>";
                                        panel_body.push("<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + advocateName + "</td></tr>");
                                    }
                                });
                                
                                panel_body.push("</tbody></table></div></div>");

                                panel_body.push('</div>');
                                count1++;
                                if (Number(totalCases) != 0) {
                                    $("#accordion_search").append(panel_body.join(""));


                                } 
                                
                                /*else {
                                    establishmentCountWithCases -= 1;
                                }*/
                                
                                document.getElementById('totalcasesId').innerHTML = total_Cases;
                                document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                          }
                        }
                        } else {                                                      
                            document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                        }
                        if (count1 == establishments_count)
                        {

                            myApp.hidePleaseWait(); 

                        }
                    
                    }
                /*} else {
                    establishments_count -= 1;
                    document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                }*/
            //}
        }

        //called when getting data from local storage
        function populateCasesTable1() {
            $("#totalEstablishments").empty();
            $("#results_container").empty();

            var selectboxText = $("#court_code option:selected").text();
            if (window.localStorage.SESSION_COURT_CODE == null) {
                showErrorMessage(labelsarr[765]);
                return false;
            }

            var date = $('#pickyDate').val();

            var advocateName = $("#advocate").val();
            var year = $("#year").val();
            var statecode = $("#statecode").val();
            var barcode = $("#barcode").val();

            checkedSearchByRadioValue = $("input[name='radOpt']:checked").val();


            if (checkedSearchByRadioValue == 1) {
                if (advocateName == '') {
                    showErrorMessage(labelsarr[93]);
                    $("#advocate").focus(); 
                    return false;
                }
            } else if (checkedSearchByRadioValue == 2) {

                if (statecode == '') {
                    showErrorMessage(labelsarr[702]);
                    $("#statecode").focus(); 
                    return false;
                }
                if (barcode == '') {
                    showErrorMessage(labelsarr[704]);
                    $("#barcode").focus(); 
                    return false;
                }
                if (year == '') {
                    showErrorMessage(labelsarr[115]);
                    $("#year").focus(); 
                    return false;
                }
            } else if (checkedSearchByRadioValue == 3) {
                if (statecode == '') {
                    showErrorMessage(labelsarr[702]);
                    $("#statecode").focus(); 
                    return false;
                }
                if (barcode == '') {
                    showErrorMessage(labelsarr[704]);
                    $("#barcode").focus(); 
                    return false;
                }
                if (year == '') {
                    showErrorMessage(labelsarr[115]);
                    $("#year").focus(); 
                    return false;
                }

                if (date == '') {
                    showErrorMessage(labelsarr[767]);
                    $("#year").focus(); 
                    return false;
                }
            }

            var courtCodesArr = window.localStorage.SESSION_COURT_CODE;


            court_code_data = courtCodesArr[0];
            var searchByAdvocateNameUrl = "";

            var pendingDisposed = "";
            arrCourtEstCodes = [];
            arrCourtEstCodes = window.localStorage.SESSION_COURT_CODE.split(",");

            total_Cases = '';

            $("#advocateHeaders").empty();

            var headerArray = [];



            headerArray.push('<label>Total Number of Establishments in Court Complex:<span id="totalEstablishmentsSpanId"></span> </label></div>');

            headerArray.push('<br>');
            if (checkedSearchByRadioValue == '3') {
                headerArray.push('<label>' + "Advocate's Cause list: " + date + '</label></div>');
                headerArray.push('<br>');
            }

            if (checkedSearchByRadioValue == '2' || checkedSearchByRadioValue == '3') {
                headerArray.push('<label>Advocate: <span id="advocateNameId"></span></label></div>');
                headerArray.push('<br>');
            }
            headerArray.push('<label>Total Number of Cases: <span id="totalcasesId"></span></label></div>');


            $("#advocateHeaders").append(headerArray);


            var state_code_data = window.localStorage.state_code;
            var district_code_data = window.localStorage.district_code;

            var establishments_count = arrCourtEstCodes.length;

            $("#accordion_search").empty();

            var count1 = 0;

            var result = JSON.parse(window.sessionStorage.getItem("SET_RESULT"));
            $.each(result, function (key, val) {
                if (val != null) {

                    var establishment_name;

                    var collapseid = 0;

                    var data = JSON.parse(val);
                    if (data != null) {

                        var panel_body = [];

                        if (checkedSearchByRadioValue == '2' || checkedSearchByRadioValue == '3') {
                            var advocateName = (data.advocateName);
                            document.getElementById("advocateNameId").innerHTML = advocateName;
                        }
                        var totalCases = Object.keys((data.caseNos)).length;

                        total_Cases = Number(totalCases) + Number(total_Cases);

                        var trHTML = '';
                        var court_code = (data.court_code);

                        panel_id = state_code_data + '_' + district_code_data + '_' + court_code;


                        establishment_name = (data.establishment_name);
                        establishment_name = establishment_name + " : " + totalCases;


                        panel_body.push('<div class="card">');
                        panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-parent="#accordion_search" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                        if (checkedSearchByRadioValue == '3') {
                            panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>Party Name</th><th>Court Name</th><th>Stage Of Case</th></tr></thead><tbody>");
                        } else {
                            panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>Party Name</th><th>Advocate Name</th></tr></thead><tbody>");
                        }

                        collapseid++;
                        var index = 0;
                        var case_nos = (data.caseNos);
                        $.each(case_nos, function (key, val) {
                            index++;
                            var petresName = val.petnameadArr;


                            if (checkedSearchByRadioValue == '3') {
                                var name1 = "";
                                var name2 = "";
                                if (val.adv_name1 != null) {
                                    name1 = val.adv_name1;
                                }
                                if (val.adv_name2 != null) {
                                    name2 = val.adv_name2;
                                }
                                var casehistorylink = '';
                                if (val.case_no == null) {
                                    casehistorylink = 'filing_case_history_link';
                                } else {
                                    casehistorylink = 'case_history_link';
                                }
                                var advocateName = name1 + "</br>" + name2;
                                var case_type_number = val.type_name + '/' + val.case_no2 + '/' + val.case_year;
                                var hrefurl = "<a data-toggle='modal' data-target='#loading' style='color:#03A8D8;text-decoration: underline;' href='#' class='" + casehistorylink + "  'court_code='" + court_code + "'case_no='" + val.case_no + "'>" + case_type_number + '</a>';

                                trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + val.court_detArr + "</td><td>" + val.purposeArr + "</td></tr>";
                                panel_body.push("<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + val.court_detArr + "</td><td>" + val.purposeArr + "</td></tr>");
                                

                            } else {
                                var name1 = "";
                                var name2 = "";
                                if (val.adv_name1 != null) {
                                    name1 = val.adv_name1;
                                }
                                if (val.adv_name2 != null) {
                                    name2 = val.adv_name2;
                                }
                                var casehistorylink = '';
                                if (val.case_no == null) {
                                    casehistorylink = 'filing_case_history_link';
                                } else {
                                    casehistorylink = 'case_history_link';
                                }
                                var advocateName = name1 + "</br>" + name2;
                                var case_type_number = val.type_name + '/' + val.case_no2 + '/' + val.reg_year;
                                var hrefurl = "<a  style='color:#00BEFC;text-decoration: underline;' href='#' class='" + casehistorylink + "  'court_code='" + court_code + "'case_no='" + val.case_no + "'>" + case_type_number + '</a>';

                                trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + advocateName + "</td></tr>";
                                panel_body.push("<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td><td>" + advocateName + "</td></tr>");
                            }
                        });

                        panel_body.push("</tbody></table></div></div>");

                        panel_body.push('</div>');
                        count1++;
                        if (Number(totalCases) != 0) {
                            $("#accordion_search").append(panel_body.join(""));

                        } 
                        document.getElementById('totalcasesId').innerHTML = total_Cases;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;

                    } else {
                        establishments_count -= 1;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                    }

                } else {
                    establishments_count -= 1;
                    document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                }
            });
            var panels = localStorage.panels === undefined ? new Array() : JSON.parse(localStorage.panels); //get all panels
            for (var i in panels) { //<-- panel is the name of the cookie
                if ($("#" + panels[i]).hasClass('panel-collapse')) // check if this is a panel
                {
                    $("#" + panels[i]).collapse("show");
                }
            }
        }

        $(document).on("show.bs.collapse", ".collapse", function (event) {
            var active = $(this).attr('id');
            var panels = localStorage.panels === undefined ? new Array() : JSON.parse(localStorage.panels);
            if ($.inArray(active, panels) == -1) //check that the element is not in the array
                panels.push(active);
            localStorage.panels = JSON.stringify(panels);
        });

        $(document).on("hidden.bs.collapse", ".collapse", function (event) {
            var active = $(this).attr('id');
            var panels = localStorage.panels === undefined ? new Array() : JSON.parse(localStorage.panels);
            var elementIndex = $.inArray(active, panels);
            if (elementIndex !== -1) //check the array
            {
                panels.splice(elementIndex, 1); //remove item from array
            }
            localStorage.panels = JSON.stringify(panels); //save array on localStorage
        });
        // function closeNav() {

        //         document.getElementById("mySidenav").style.display = "none";
        //     }
        // $("#menubarClose").click(function ()
        //     {
        //         if ($("#mySidenav").is(':visible'))
        //         {
        //             closeNav();
        //         } 
        //     });

            
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