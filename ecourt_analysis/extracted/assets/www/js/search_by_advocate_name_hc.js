    /*
    variables saved in local/ session storage to retain page session after page reload

    SESSION_COURT_CODE : court complexes selected value- saved in local storage
    SESSION_COURTNAMES : act type selected value- session storage
    SESSION_BACKLINK : current page- session storage
    SESSION_INPUT_1 : advocate name text box input value- session storage
    SESSION_INPUT_2 : under Act text box input value- session storage 
    SET_RESULT : Result after Go button click- session storage 
    */
    $(document).ready(function () {
        second_header();
        backButtonHistory.push("searchcasepage");
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;

        // var rad = document.parentForm.radOpt;
        checkedSearchBy = $("input[name='radOpt']:checked").val();//window.sessionStorage.SESSION_INPUT_2;

        document.getElementById("advocateBarCodeId").style.display = "none";
        document.getElementById("caseListDateId").style.display = "none";
        document.getElementById("enterAdvocateNameId").style.display = "block";
        
        $('#radOpt-' + checkedSearchBy).click();

        arrCourtEstNames = [];
        arrCourtEstCodes = [];

        $('input[type=radio][name=radOpt]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
        //    $("#results_container").empty();
            clearResultFinal();
        });

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            clearResultFinal();
        });

        $("#advocate").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
            clearResultFinal();
        });

        $("#statecode").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
            clearResultFinal();
        });

        $("#year").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
            clearResultFinal();
        });

        $("#barcode").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
            clearResultFinal();
        });
    //statecode keydown
        $("#statecode").on('keydown', function () {
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
              var pat = /^[0-9]*$/;
            if (pat.test($(this).val()) == false) {
                $(".barcode").html(" only numbers ").show().fadeOut("slow");
                $("#barcode").val("");
                 $("#barcode").focus(); 
                return false;
            }
        });
      $("#barcode").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($(this).val().length >= 7) {                
                $(".barcode").html("6 Digits Only in barcode").show().fadeOut("slow");
                $("#barcode").val("");
                $("#barcode").focus(); 
                return false;
            }
            clearResultFinal();
        });
       /// barcode keydown

       $("#year").on('keydown', function () {
              var pat = /^[0-9]*$/;
            if (pat.test($(this).val()) == false) {
                $(".year").html(" only numbers ").show().fadeOut("slow");
                $("#year").val("");
                 $("#year").focus(); 
                return false;
            }
        });
       $("#year").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($(this).val().length >= 5) {                
                $(".year").html("4 Digits Only in year").show().fadeOut("slow");
                $("#year").val("");
                $("#year").focus(); 
                return false;
            }
            clearResultFinal();
        });
    });

    //change UI as per radio button change
    $("#radOpt-1").click(function (e) {
        document.getElementById("advocateBarCodeId").style.display = "none";
        document.getElementById("caseListDateId").style.display = "none";
        document.getElementById("enterAdvocateNameId").style.display = "block";
        document.getElementById("pendingDisposedId").style.display = "block";
    });
    $("#radOpt-2").click(function (e) {
        document.getElementById("advocateBarCodeId").style.display = "block";
        document.getElementById("caseListDateId").style.display = "none";
        document.getElementById("enterAdvocateNameId").style.display = "none";
        document.getElementById("pendingDisposedId").style.display = "block";

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

        $('#statecode').val(window.localStorage.STATE_CODE);
        $('#barcode').val(window.localStorage.BAR_CODE);
        $('#year').val(window.localStorage.YEAR);

        function clearResult(){
            window.sessionStorage.removeItem("SET_RESULT");
            clearResultFinal();
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
        window.sessionStorage.removeItem('SET_RESULT')
            $("#advocate").val("");
             window.localStorage.removeItem("STATE_CODE");
             window.localStorage.removeItem("BAR_CODE");
             window.localStorage.removeItem("YEAR");
        var selectedValue = $('input[name=radOpt]:checked', '#myForm').val();
        var $radios = $('input[name=radOpt1]');
            $radios.filter('[value=Pending]').prop('checked', true);
        if (selectedValue == "1") {
            //window.sessionStorage.removeItem('SESSION_INPUT_1');
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
        clearResultFinal();
    });

    //fetch result of Go button click from web service or session storage
    $("#goButton").click(function (e) {
        e.preventDefault();
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
        window.sessionStorage.setItem("SESSION_PENDING_DISPOSED",$("input[name='radOpt1']:checked").val());
            return populateCasesTable();
        
    });

    //called when getting data from web service
    function populateCasesTable() {
        $("#advocateHeaders").empty();
        $("#accordion_search").empty();
        var date = $('#pickyDate').val();
        var advocateName = $("#advocate").val();
        var year = $("#year").val();
        var statecode = $("#statecode").val();
        var barcode = $("#barcode").val();
         var patt = new RegExp(/^[a-zA-z- ._]*$/);
        checkedSearchByRadioValue = $("input[name='radOpt']:checked").val();
        if (checkedSearchByRadioValue == 1) {
            if (advocateName == '') {
                showErrorMessage("Please Enter Advocate Name");
                $("#advocate").focus();
                return false;
            }
            if (!patt.test(advocateName)) {

            showErrorMessage("Please Enter valid Advocate Name");
            $("#advocate").val("");
              $("#advocate").focus(); 
            return false;

        }
        if ($("#advocate").val().length < 3 || $("#advocate").val().length > 99)
        {
            showErrorMessage("Please Enter at least 3 char in Advocate Name");
            $("#advocate").val("");
              $("#advocate").focus(); 
            return false;
        }

        } else if (checkedSearchByRadioValue == 2) {
            if (statecode == '') {
                showErrorMessage("Please Enter State Code");
               $("#statecode").focus(); 
                return false;
            }
            if ($("#statecode").val().length > 3){
                showErrorMessage("Please Enter valid State Code");
               $("#statecode").val("");
               $("#statecode").focus(); 
                return false;
            }

            if (!patt.test(statecode)) {

           showErrorMessage("Please Enter valid State Code");
               $("#statecode").val("");
               $("#statecode").focus(); 
                return false;
        }

            if (barcode == '') {
                showErrorMessage("Please Enter Barcode");
                 $("#barcode").val("");
                 $("#barcode").focus(); 
                return false;
            }
            if (barcode <= 0) {
            showErrorMessage("Please Enter Non Zero barcode");

            $("#barcode").val("");
            $("#barcode").focus(); 
            return false;
            }


            if (barcode <= 0) {
                showErrorMessage("Please Enter Non Zero barcode");

              $("#barcode").val("");
            $("#barcode").focus(); 
                return false;
            }

                if (year == '') {
                    showErrorMessage("Please Enter Year");
                     $("#year").focus(); 
                     $("#year").val("");
                    return false;
                }
                if (year <= 0) {
                showErrorMessage("Please Enter Non Zero Year");

                 $("#year").focus(); 
                     $("#year").val("");
                return false;
            }
             if(year.toString().length < 4)
            {
                 showErrorMessage("please enter 4 digit year");
                 $("#year").focus(); 
                     $("#year").val("");
                return false;
            }
             var d = new Date();
        var n = d.getFullYear();
        if (year <= 1900 || year > n)
        {
            showErrorMessage("Please Enter Year between 1901 to " + n);
            $("#year").focus(); 
                     $("#year").val("");
            return false;
        }
        } else if (checkedSearchByRadioValue == 3) {
            if (statecode == '') {
                showErrorMessage("Please Enter State Code");
                 $("#statecode").focus(); 
                return false;
            }
            if (barcode == '') {
                showErrorMessage("Please Enter Barcode");
                 $("#barcode").focus(); 
                return false;
            }
            if (year == '') {
                showErrorMessage("Please Enter Year");
                 $("#year").focus(); 
                return false;
            }

            if (date == '') {
                showErrorMessage("Please Select Cause List Date");
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
        for (var i = 0; i < arrCourtEstCodes.length; i++) {
            if (arrCourtEstCodes[i] != ",") {            

                var data = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(arrCourtEstCodes[i]), checkedSearchByRadioValue:(checkedSearchByRadioValue), advocateName:(advocateName), year:(year), barstatecode:(statecode), barcode:(barcode), pendingDisposed:(pendingDisposed), date:(date)};

                var establishment_name;

                var collapseid = 0;
                //populate the result table with court establishment as collapse field
                    callToWebService(searchByAdvocateNameUrl, data, advocateNameSearchResult);
                    function advocateNameSearchResult(data){
                    if (data != null) {
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
                        panel_body.push('<div class="card">');
                        panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                        if (checkedSearchByRadioValue == '3') {
                            panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>Party Name</th><th>Court Name</th><th>Stage Of Case</th></tr></thead><tbody>");
                        } else {
                            panel_body.push("<div id=" + panel_id + " class=' collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>Party Name</th><th>Advocate Name</th></tr></thead><tbody>");
                        }
                        collapseid++;
                        var index = 0;
                        $.each(obj_caseNos, function (key, val) {
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
                                casehistorylink = 'case_history_link';                                    
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
                                casehistorylink = 'case_history_link';                                    
                                var advocateName = name1 + "</br>" + name2;
                                var case_type_number = val.type_name + '/' + val.case_no2 + '/' + val.reg_year;
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

                    } else {
                        establishments_count -= 1;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                    }
                    if (count1 == establishments_count)
                    {
                        myApp.hidePleaseWait(); 
                    }                  
                }
            } else {
                establishments_count -= 1;
                document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
            }
        }
    }

    function clearResultFinal(){
        $("#advocateHeaders").empty();
        $("#accordion_search").empty();
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