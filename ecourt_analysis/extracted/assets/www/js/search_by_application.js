var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
if(labelsarr){
    var totalNoOfEstLabel = labelsarr ? labelsarr[390] : "Total Number of Establishments in Court Complex";
    var totalNoOfCasesLabel = labelsarr ? labelsarr[83] : "Total Number of Cases";
}
    var selectPoliceStationLabel = "Select Police Station";
    var selectFIRType = "Select Fir Type";
    var selectFIRNo = "Enter FIR Number";
    var selectYear = "Enter year";
    var fromDate_label = "From Date";
    var toDate_label = "To Date";
    var courtJudge = "Court-Judge";
    var bailDetails_label = "Bail Details";
    var applDetails_label = "Application Details";
    var remandDetails_label = "Remand Details";
    var accusedName_label = "Accused Name";
    var applDate_label = "Application Date";
    var next_dispDate_label = "Next/Disposed Date";
    var applType_label = "Application Type";
    var applOrders_label = "Application Orders";
    $(document).ready(function () {
        second_header();
        backButtonHistory.push("searchcasepage");
        sessionStorage.setItem("tab", "#profile");
        populateCourtComplexes();
        arrCourtEstCodes = [];

        var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
       if(labelsarr){ 
            $("#casestatus_heading1_label").html(labelsarr[11]);
            $("#search_by_application_label").html(labelsarr[656]);
            $("#court_complex_label").html(labelsarr[269]);
            $("#police_station_label").html(labelsarr[56]);
            $("#fir_type_label").html(labelsarr[424]);
            $("#fir_no_label").html(labelsarr[22]);
            $("#year_label").html(labelsarr[81]);
            $("#goButton").html(labelsarr[26]);
            $("#resetButton").html(labelsarr[57]);
             $("#resetButton").html(labelsarr[57]);
             courtJudge = labelsarr[436];
             fromDate_label = labelsarr[24];
             toDate_label = labelsarr[78];
             bailDetails_label = labelsarr[425];
             applDetails_label = labelsarr[427];
             accusedName_label = labelsarr[658];
             remandDetails_label = labelsarr[416];
             applDate_label = labelsarr[661];
             next_dispDate_label = labelsarr[662];
             applType_label = labelsarr[665];
             applOrders_label = labelsarr[666];
            document.getElementById("remand").innerHTML=(labelsarr[606]);
            document.getElementById("bail").innerHTML=(labelsarr[438]);
            document.getElementById("applic").innerHTML=(labelsarr[433]);
            $("#police_station option[value = '']").text(labelsarr[73]);
            selectPoliceStationLabel = labelsarr[73]; 
            $("#fir_type option[value = '']").text(labelsarr[691]);
            selectFIRType = labelsarr[73];           
            selectYear = labelsarr[683];
            $('#rgyear').attr('placeholder',selectYear);
            selectFIRNo = labelsarr[292];
            $('#fir_no').attr('placeholder',selectFIRNo);
            
       }

        $('#police_station').empty();
        $('#police_station').append('<option id="" value="">'+selectPoliceStationLabel+'</option>');

        if (window.localStorage.SESSION_COURT_CODE != null) {
            populatePoliceStation();
        }
        $('#court_code').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($('#court_code').val() != "") {
                window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
                window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));

            } else {
                window.localStorage.removeItem("SESSION_COURT_CODE");
                window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
            }

            populatePoliceStation();
            $("#Causelist_pannel").trigger("courtCodeChanged");
        });

        // if (window.sessionStorage.SESSION_SELECT_2 != null) {
        //     populatePoliceStation();
        // }
        // if (window.sessionStorage.SESSION_PENDING_DISPOSED != null) {
        //     var selected_radio = window.sessionStorage.SESSION_PENDING_DISPOSED;        
        //     var $radios = $('input[name=radOpt1]');
        //     $radios.filter('[value='+selected_radio+']').prop('checked', true);
        // }
        $('#police_station').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
        });

		$('#fir_type').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
            // if ($('#fir_type').val() == '') {
            //     window.sessionStorage.removeItem("SESSION_SELECT_3");
            // } else {
            //     window.sessionStorage.setItem("SESSION_SELECT_3", $('#fir_type').val());
            // }
        });
        // if (window.sessionStorage.SESSION_INPUT_2 != null) {
        //     $("#rgyear").val(window.sessionStorage.SESSION_INPUT_2);
        // }
        // if (window.sessionStorage.SESSION_INPUT_1 != null) {
        //     $("#fir_no").val(window.sessionStorage.SESSION_INPUT_1);
        // }
        // if (window.sessionStorage.SESSION_SELECT_2 != null && window.localStorage.SESSION_COURT_CODE != null) {
        //     $("#goButton").click();
        // }

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
        });

        //validation
        $("#fir_no").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#accordion_search").empty();
                $("#headers").empty();       
            }
            var pat = /^[a-zA-Z0-9]*$/;
            if ($(this).val().length > 6) {
                $(".fir_number_val").html("6 Digits Only in fir number").show().fadeOut("slow");
                $("#fir_no").val("");
                return false;
            }
            if (pat.test($(this).val()) == false) {
                $(".fir_number_val").html(labelsarr[762]).show().fadeOut("slow");
                $("#fir_no").val("");
                return false;
            }
        });
        $("#rgyear").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
                window.sessionStorage.removeItem("SET_RESULT");
                $("#accordion_search").empty();
                $("#headers").empty();       
            }
            var pat = /^[0-9]*$/;
            if ($(this).val().length > 4) {
                $(".year_error").html(labelsarr[808]).show().fadeOut("slow");
                $("#rgyear").val("");
              return false;
            }
            if (pat.test($(this).val()) == false) {
                $(".year_error").html(labelsarr[808]).show().fadeOut("slow");
                $("#rgyear").val("");
                 $("#rgyear").focus(); 
                return false;
            }
        });

    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        window.localStorage.removeItem('SESSION_COURT_CODE');
        window.sessionStorage.removeItem('SET_RESULT');
        $('#court_code').val("");
        $("#rgyear").val("");
        $("#fir_no").val("");  
        $("#fir_type").val("");
        // $("#fir_type").empty();
        // $("#fir_type").append('<option id="" value="">'+"Select Fir Type"+'</option>');
        $("#police_station").empty(); 
        $('#police_station').append('<option id="" value="">'+selectPoliceStationLabel+'</option>');
        var $radios = $('input[name=radOpt1]');
        $radios.filter('[value=R]').prop('checked', true);  
        $("#accordion_search").empty();
        $("#headers").empty();   
        $("#Causelist_pannel").trigger("courtCodeChanged");   
    });

    //fetch search data from web service or session storage
    $("#goButton").click(function (e) {
        e.preventDefault();
        if(window.sessionStorage.SET_RESULT == null){
        // window.sessionStorage.setItem("SESSION_INPUT_1", $("#fir_no").val());
        // window.sessionStorage.setItem("SESSION_INPUT_2", $("#rgyear").val());    window.sessionStorage.setItem("SESSION_PENDING_DISPOSED",$("input[name='radOpt1']:checked").val());
        return populateCasesTable();
        }

    });

    function populateCasesTable() {
        // $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var selectboxText = $("#court_code option:selected").text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            showErrorMessage(labelsarr[277]);
            //showErrorMessage("Please select court complex");
            return false;
        }

        var selectpolicestationboxText = $("#police_station option:selected").val();

        if (selectpolicestationboxText == null || selectpolicestationboxText=='') {
            showErrorMessage(labelsarr[51]);
            return false;
        }

        // var fir_type = $("#fir_type option:selected").val();       
        // if(fir_type==null || fir_type==''){
        //     showErrorMessage("Please select Fir Type");
        //     return false;
        // }

        var pre_application_type = $("input[name='radOpt1']:checked").val();
        var firNumber = $("#fir_no").val();
        var year = $("#rgyear").val();

       if(!firNumber.length==0){
            if (firNumber === '' || firNumber === null) {
                showErrorMessage(labelsarr[710]);
                $("#fir_no").val("");
                $("#fir_no").focus(); 
                return false;
            }
            if (firNumber <= 0) {
                showErrorMessage(labelsarr[711]);
                $("#fir_no").val("");
                $("#fir_no").focus(); 
                return false;
            }
        }

     var year = $("#rgyear").val();


    if(year !='')
    {

            if (year === '' || year === null) {
                showErrorMessage(labelsarr[712]);
                $("#rgyear").val("");
                $("#rgyear").focus(); 
                return false;
            }
            if (year <= 0) {
                showErrorMessage(labelsarr[708]);
                $("#rgyear").val("");
                 $("#rgyear").focus(); 
                return false;
            }
             if(year.toString().length < 4)
                {
                     showErrorMessage(labelsarr[767]);
                    $("#rgyear").val("");
                     $("#rgyear").focus(); 
                    return false;

                }

            var d = new Date();
            var n = d.getFullYear();
            if (year <= 1900 || year > n)
            {
                showErrorMessage(labelsarr[43] + n);
                $("#rgyear").val("");
                 $("#rgyear").focus(); 
                return false;
            }
        }
        if (window.sessionStorage.getItem("SET_RESULT") == null) {
            var firNumberSearchUrl = hostIP + "pretrialNumberSearch.php";

            var police_stationcode = $('#police_station').val();
			var fir_type = $('#fir_type').val();
            var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
            // var  encrypted_data5=0;
            // if(localStorage.LANGUAGE_FLAG=="english"){
            //      encrypted_data5 = ("0");
            // }else{
            //      encrypted_data5 = ("1");
            // }      
            var encrypted_data5 = (bilingual_flag.toString());
            var request_data = {police_stationcode:(police_stationcode), firNumber:(firNumber), year:(year), pre_application_type:(pre_application_type), fir_type:(fir_type), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
            
            displayCasesTableAppl(firNumberSearchUrl, request_data);
        } else {
            displayCasesTableAppl1();
        }
    }

    function displayCasesTableAppl(url, request_data){

        arrCourtEstCodes = [];
        arrCourtEstCodes = window.localStorage.SESSION_COURT_CODE.split(',');
        total_Cases = '';
        $("#headers").empty();


        var headerArray = [];
        headerArray.push('<label">'+totalNoOfEstLabel+':<span id="totalEstablishmentsSpanId"></span> </label></div>');
        headerArray.push('<br>');
        headerArray.push('<label>'+totalNoOfCasesLabel+': <span id="totalcasesId"></span></label></div>');
        
       
        $("#headers").append(headerArray);

        
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        $("#accordion_search").empty();
       
        myApp.showPleaseWait();
        var establishments_count = arrCourtEstCodes.length;
        
        var applType = '';
        var applorderTiltle = '';
        var count = 0;
        var count1 = 0;

        var jsonData = {};
        // for (var i = 0; i <= arrCourtEstCodes.length - 1; i++) {
            // if(arrCourtEstCodes[i] != ","){
            count++;

            var encrypted_data1 = (state_code_data);
            var encrypted_data2 = (district_code_data);
            var encrypted_data3 = (arrCourtEstCodes);


            var data1 = {state_code:encrypted_data1.toString(),dist_code:encrypted_data2.toString(), court_code_arr:encrypted_data3.toString()};

            var data = $.extend({}, data1, request_data); 


            var establishment_name;
            var collapseid = 0;
            var ordercollapseid = 0;

            //populate the result table with court establishment as collapse field
            callToWebService(url, data, applicationSearchResult);
            function applicationSearchResult(responseData){       

                    var obj_caseNos = null;
                    var preTrial_order_arr = null;
                    var preTrialOrderCount = null;
                    for(const val in responseData){
                        var data = responseData[val] ; 
                                           
                    if(data != null){
                        
                        obj_caseNos = (data.Pretrial);
                        preTrialOrderCount = (data.cnt_order);
                        
                    }
                    if (obj_caseNos != null) {
                        var obj_courtcode = (data.court_code);

                        var obj_establishment_name = (data.establishment_name);
                        
                        var totalCases = (data.total_count);
                        total_Cases= total_Cases = Number(totalCases) + Number(total_Cases);
                       
                        var pre_application_type = (data.pre_application_type);
                        
                        jsonData[JSON.stringify(obj_courtcode)] = JSON.stringify(data);
                        // window.sessionStorage.setItem("SET_RESULT", JSON.stringify(jsonData));
                        window.sessionStorage.setItem("SET_RESULT", true);


                        var panel_body = [];
                       
                        
                        
                        var trHTML = ''; 
                        var court_code = obj_courtcode;
 
                        //panel_id = state_code_data + '_' + district_code_data + '_' + court_code;
                        panel_id = 'card'+state_code_data+district_code_data+court_code;

                        establishment_name = obj_establishment_name;
                        establishment_name = establishment_name + " : " + totalCases;                        
                        
                        if(pre_application_type=='R')
                        {
                            applType = 'Remand Details';
                            applorderTiltle = 'Remand Orders';
                            
                            panel_body.push('<div class="card" id=' + panel_id + '">');
                            panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                            
                            panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th colspan='6'  style='background: #d9edf7 !important;'>remandDetails_label</th></tr><tr><th>Sr.No</th><th>Accused Name</th><th>Type</th><th>Days</th></th><th>fromDate_label</th></th><th>toDate_label</th></tr></thead><tbody>");
                            
                            collapseid++;
                            var index = inner_index= 0;
                            var pre_count='1';
                            $.each(obj_caseNos, function (key, val) {
                                index++;
                             
                                var type= val.type1;
                                var days= val.days;
                                var srno= val.srno;
                                var from_date= val.from_date;
                                var to_date= val.to_date;
                                 var accused_name= val.accused_name;

                                //trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + type + "</td></tr>";
                                panel_body.push("<tr><td>" + index + "</td><td>" + accused_name + "</td> <td>" + type + "</td> <td>" + days + "</td><td>" + from_date + "</td> <td>" + to_date +"</tr>");
                            });
                            
                        }else if(pre_application_type=='B'){
                            applType = 'Bail Details';
                            applorderTiltle = 'Bail Orders';
                            
                            panel_body.push('<div class="card" id=' + panel_id + '">');
                            panel_body.push('<div class="card-header"><h4 class="panel-title"><a class="card-link collapsed panel-title-a" data-parent="#accordion_search" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                            
                            panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th colspan='6'  style='background: #d9edf7 !important;'>bailDetails_label</th></tr><tr><th>Sr.No</th><th>Accused Name</th><th>Application Date</th><th>Status</th><th>next_dispDate_label</th></th><th>Result</th></tr></thead><tbody>");
                            
                            collapseid++;
                            var index = inner_index= 0;
                            var pre_count='1';
                            $.each(obj_caseNos, function (key, val) {
                                index++;
                              
                               
                                var appl_date= val.appl_date;
                                var status= val.status;
                                var next_date= val.next_date;
                                if(val.result==null || val.result =='')
                                    {
                                        
                                        var result = '';
                                    }else{
                                          
                                        var result= val.result;
                                    }
                                
                                 var accused_name= val.accused_name;

                                //trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + type + "</td></tr>";
                                panel_body.push("<tr><td>" + index + "</td><td>" + accused_name + "</td> <td>" + appl_date + "</td> <td>" + status + "</td><td>" + next_date + "</td> <td>" + result +"</tr>");
                            });
                        }else{
                            
                            applType = 'Application Details';
                            applorderTiltle = 'Application Orders';
                            
                            panel_body.push('<div class="card" id=' + panel_id + '">');
                            panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-parent="#accordion_search" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                            
                            panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th colspan='7' style='background: #d9edf7 !important;'>applDetails_label</th></tr><tr><th>Sr.No</th><th>accusedName_label</th><th>applDate_label</th><th>Status</th><th>applType_label</th><th>next_dispDate_label</th></th><th>Result</th></tr></thead><tbody>");
                            
                            
                            collapseid++;
                            var index = inner_index= 0;
                            var pre_count='1';
                            $.each(obj_caseNos, function (key, val) {
                                index++;
                                                             
                                var appl_date= val.appl_date;
                                var status= val.status;
                                var next_date= val.next_date;
                                                                
                                if(val.result==null || val.result =='')
                                    {
                                        
                                        var result = '';
                                    }else{
                                          
                                        var result= val.result;
                                    }
                                
                                var appl_type= val.appl_type;
                                 var accused_name= val.accused_name;

                                //trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + type + "</td></tr>";
                                panel_body.push("<tr><td>" + index + "</td><td>" + accused_name + "</td> <td>" + appl_date + "</td> <td>" + status + "</td><td>" + appl_type + "</td><td>" + next_date + "</td> <td>" + result +"</tr>");
                            });
                        }
                        panel_body.push("</tbody></table></div>");
                        
                        if(preTrialOrderCount>0){
                            preTrial_order_arr = (data.pre_order_arr);
                            
                            panel_body.push("<div><Br>"+"<div style='text-align:left;padding:10px;color:##265a88;font-weight:bold;background: #d9edf7 !important;'>"+applorderTiltle+"</div>");
                            //panel_body.push('<div class="card" id=' + panel_id + '">');
                            
                            
                            panel_body.push("<div id=" + panel_id + " ><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>courtJudge</th><th>Date of Order</th><th>Order</th></tr></thead><tbody>");
                            
                            ordercollapseid++;
                              var order_index = 0;
                            
                            $.each(preTrial_order_arr, function (key, val) {
                                order_index++;                                                          
                                var court_no= val.court_no;
                                var judge_name= val.judge_name;
                                var order_date= val.order_date;
                                                                
                                if(val.result==null || val.result =='')
                                    {                                        
                                        var result = '';
                                    }else{                                          
                                        var result= val.result;
                                    }
                                
                                var orderYr= val.orderYr;
                                var order_id= val.order_id;
                                var crno= val.crno;
                                
                                var state_code = window.localStorage.state_code;
                                var dist_code = window.localStorage.district_code;
                                var data = {court_code:court_code,orderYr:orderYr,order_id:order_id,crno:crno,state_code:state_code,dist_code:dist_code};
                                var data1 = encryptData(data);
                                // var preTrialOrderPDFUrl = hostIP +"preTrialOrder_pdf.php?court_code="+court_code+"&orderYr="+orderYr+"&order_id="+order_id+"&crno="+crno+"&state_code="+state_code+"&dist_code="+dist_code;
                                
                                //http://10.153.6.141/ecourt_mobile_encrypted/ecourt_mobile_encrypted_DC/preTrialOrder_pdf.php?court_code=4&orderYr=2019&order_id=2&crno=MHAU01P0000032019&state_code=1&dist_code=19
                                
                                var preTrialOrderPDFUrl = hostIP +"preTrialOrder_pdf.php?params="+data1;
                                var hrefurl = "<a style='color:#03A8D8;text-decoration:underline;' href="+preTrialOrderPDFUrl+">" +'View' + '</a>';
                                                                
                               panel_body.push("<tr><td>" + order_index + "</td><td>" + judge_name +"-"+court_no + "</td> <td>" + order_date + "</td> <td> "+hrefurl+" </td></tr>");
                            });
                            
                        }
                                                   


                        
                        panel_body.push("</tbody></table></div></div></div>");
                        count1++;
                        panel_body.push('</div>');
                        if (totalCases != 0) {
                            $("#accordion_search").append(panel_body.join(""));
                            
                        } 
                        
//                        $("#preTrialOrder").append(panel_body_order.join(""));
                        
                        //document.getElementById('applTypeOrderId').innerHTML = applorderTiltle;
                        document.getElementById('totalcasesId').innerHTML = total_Cases;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;



                    } else {
                        // establishments_count -= 1;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;

                    }
                }
                    if (count1 == establishments_count){            
                        myApp.hidePleaseWait();             
                    }                

            }

        /*}else {
            establishments_count -= 1;
            document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;

        }*/
        // }   

    }

    function displayCasesTableAppl1(){

        arrCourtEstCodes = [];
        arrCourtEstCodes = window.localStorage.SESSION_COURT_CODE.split(',');
        total_Cases = '';
        $("#headers").empty();

        var headerArray = [];
        headerArray.push('<label">Total Number of Establishments in Court Complex:<span id="totalEstablishmentsSpanId"></span> </label></div>');
        headerArray.push('<br>');
        headerArray.push('<label>Total Number of Cases: <span id="totalcasesId"></span></label></div>');
        $("#headers").append(headerArray);


        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        $("#accordion_search").empty();
        
        var establishments_count = arrCourtEstCodes.length;

        var count = 0;
        var count1 = 0;

        var result = JSON.parse(window.sessionStorage.getItem("SET_RESULT"));
        $.each(result, function (key, val) {
            if (val != null) {
                count++;


                var establishment_name;
                var collapseid = 0;

                //populate the result table with court establishment as collapse field

                var data = JSON.parse(val);
                if (data != null) {

                    var panel_body = [];
                    var totalCases = Object.keys((data.caseNos)).length;
                    total_Cases = Number(totalCases) + Number(total_Cases);
                    var trHTML = '';
                    var court_code = (data.court_code);

                    panel_id = 'card' + state_code_data + '_' + district_code_data + '_' + court_code;


                    establishment_name = (data.establishment_name);
                    establishment_name = establishment_name + " : " + totalCases;

                    panel_body.push('<div class="card">');
                    panel_body.push('<div class="card-header"><h4 class="panel-title"><a class="card-link collapsed panel-title-a" data-parent="#accordion_search" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                    panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>FIR Number/Year</th><th>Party Name</th></tr></thead><tbody>");

                    collapseid++;
                    var index = 0;
                    var case_nos = (data.caseNos);
                    $.each(case_nos, function (key, val) {
                        index++;
                        var petresName = val.petnameadArr;
                        var case_type_number = val.type_name + '/' + val.case_no2 + '/' + val.reg_year;
                        var firNuber_year = '';
                        if(val.fir_no == '' || val.fir_year == 0){
                            firNuber_year = '';
                        }else{
                            firNuber_year = val.fir_no + '/' + val.fir_year;
                        }
                        var casehistorylink = '';
                        if (val.case_no == null) {
                            casehistorylink = 'filing_case_history_link';
                        } else {
                            casehistorylink = 'case_history_link';
                        }
                        var hrefurl = "<a style='color:#03A8D8;text-decoration:underline;' href='#' class='" + casehistorylink + "  'court_code='" + court_code + "'cino='" + val.cino + "'case_no='" + val.case_no + "'>" + case_type_number + '</a>';

                        trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td></tr>";
                        panel_body.push("<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + firNuber_year + "</td> <td>" + petresName + "</td></tr>");
                    });

                    panel_body.push("</tbody></table></div></div>");
                    count1++;
                    panel_body.push('</div>');
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


    //fetch police stations from web service or session storage
    function populatePoliceStation() {
        $('#police_station').empty();
        $('#police_station').append('<option id="" value="">'+selectPoliceStationLabel+'</option>');
        var selectboxText = $("#court_code option:selected").text();
        // var selectboxText = $select.text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }

        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;

        var caseTypeWebServiceUrl = hostIP + "policeStationWebService.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
        // var  encrypted_data5=0;
        // if(localStorage.LANGUAGE_FLAG=="english"){
        //      encrypted_data5 = ("0");
        // }else{
        //      encrypted_data5 = ("1");
        // }
        var encrypted_data5 = (bilingual_flag.toString());
        var caseTypedata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
        
        //web service call to get police stations for selected court complex
        callToWebService(caseTypeWebServiceUrl, caseTypedata, caseTypeSearchResult);
        function caseTypeSearchResult(result){          
                    
            var decodedResult = (result);
            $.each(decodedResult.police_stationlist, function (key, val) {
                var caseTypesArr = val.police_station.split("#");
                $.each(caseTypesArr, function (key, val) {
                    var casetype = val.split("~");
                    $('#police_station').append('<option id="" value="' + casetype[0] + '">' + casetype[1] + '</option>');
                });                    
            }); 
            myApp.hidePleaseWait();
        }

    }

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