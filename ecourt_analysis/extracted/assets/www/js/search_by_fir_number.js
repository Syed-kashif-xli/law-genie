var uniform_code=[];
var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
if(labelsarr){
    var totalNoOfEstLabel = labelsarr ? labelsarr[390] : "Total Number of Establishments in Court Complex";
    var totalNoOfCasesLabel = labelsarr ? labelsarr[83] : "Total Number of Cases";
    var partyNameLabel = labelsarr ? labelsarr[30] : "Party Name";
    var srNoLabel = labelsarr ? labelsarr[84] : "Sr.No";
    var caseNoLabel = labelsarr ? labelsarr[9] : "Case Number";
    var firNoLabel = labelsarr ? labelsarr[22]+"/"+labelsarr[81] : "FIR Number/Year";

    var selectPoliceStationLabel = "Select Police Station";
    var selectFIRNoLabel = "Enter FIR Number";
    var selectYearLabel = "Enter year";
}
$(document).ready(function () {
    second_header();
    backButtonHistory.push("searchcasepage");

    sessionStorage.setItem("tab", "#profile");
    populateCourtComplexes();
    arrCourtEstNames = [];
    arrCourtEstCodes = [];

    var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
    if(labelsarr){       
        $("#casestatus_heading1_label").html(labelsarr[11]);
        $("#search_by_fir_no_label").html(labelsarr[457]);
        $("#court_complex_label").html(labelsarr[269]);
        $("#police_station_label").html(labelsarr[56]);
        $("#fir_no_label").html(labelsarr[22]);
        $("#year_label").html(labelsarr[81]);
        $("#goButton").html(labelsarr[26]);
        $("#resetButton").html(labelsarr[57]);
        document.getElementById("rad1").innerHTML=(labelsarr[31]);
        document.getElementById("rad2").innerHTML=(labelsarr[21]);
        document.getElementById("rad3").innerHTML=(labelsarr[7]);
        $("#police_station option[value = '']").text(labelsarr[73]);
        selectPoliceStationLabel = labelsarr[73];

        selectFIRNoLabel = labelsarr[292];
        $('#fir_no').attr('placeholder',selectFIRNoLabel);

        selectYearLabel = labelsarr[683];
        $('#rgyear').attr('placeholder',selectYearLabel);
    }
    $('#police_station').empty();
    $('#police_station').append('<option id="" value="">'+selectPoliceStationLabel+'</option>');

    if (window.localStorage.SESSION_COURT_CODE != null) {
        populatePoliceStation();
    }
    $('#court_code').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty(); 
        if ($('#court_code').val() != "") {
            window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
            window.sessionStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));

        } else {
            window.localStorage.removeItem("SESSION_COURT_CODE");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
        }

        populatePoliceStation();
        $("#Causelist_pannel").trigger("courtCodeChanged");
    });

    $('#police_station').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();             
    });

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
    $("#police_station").empty(); 
    $('#police_station').append('<option id="" value="">'+selectPoliceStationLabel+'</option>');
    var $radios = $('input[name=radOpt1]');
    $radios.filter('[value=Pending]').prop('checked', true);  
    $("#accordion_search").empty();
    $("#headers").empty(); 
    $("#Causelist_pannel").trigger("courtCodeChanged"); 
});

//fetch search data from web service or session storage
$("#goButton").click(function (e) {
    e.preventDefault();
   // if(window.sessionStorage.SET_RESULT != null){
        return populateCasesTable();
   // }

});

function populateCasesTable() {
    $("#results_container").empty();
    
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

    var pendingDisposed = $("input[name='radOpt1']:checked").val();


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
                showErrorMessage(labelsarr[42]);
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
    window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_fir_number.html");
    if (window.sessionStorage.getItem("SET_RESULT") == null) {
        var firNumberSearchUrl = hostIP + "firNumberSearch.php";

        var police_stationcode = $("#police_station option:selected").val();
        var var_uniform_code = uniform_code[police_stationcode];
        var uniformcodestr = var_uniform_code ? var_uniform_code.toString() : 0;
        var request_data = {police_stationcode:(police_stationcode),firNumber:(firNumber),year:(year), pendingDisposed:(pendingDisposed),uniform_code:(uniformcodestr)};
        
        displayCasesTableFir(firNumberSearchUrl, request_data);
    }
    // else {
    //     displayCasesTableFir1();
    // }
}

function displayCasesTableFir(url, request_data){

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

    var count = 0;
    var count1 = 0;

    var jsonData = {};
    // for (var i = 0; i <= arrCourtEstCodes.length - 1; i++) {
        // if(arrCourtEstCodes[i] != ","){
        count++;

        var encrypted_data1 = (state_code_data);
        var encrypted_data2 = (district_code_data);
        var encrypted_data3 = (arrCourtEstCodes);
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
        // var encrypted_data5=null;
        // if(localStorage.LANGUAGE_FLAG=="english"){
        //     encrypted_data5 = encryptData("0");
        // }else{
        //     encrypted_data5 = encryptData("1");
        // }
        var encrypted_data5 = (bilingual_flag.toString());
        var data1 = {state_code:encrypted_data1.toString(), dist_code:encrypted_data2.toString(),  court_code_arr:encrypted_data3.toString(), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
        
        var data = $.extend({}, data1, request_data); 


        var establishment_name;
        var collapseid = 0;

        //populate the result table with court establishment as collapse field
        callToWebService(url, data, firSearchResult);
        function firSearchResult(responseData){              
            var obj_caseNos = null;
            for(const val in responseData){
                var data = responseData[val] ; 
                            
            if(data != null){
                obj_caseNos = (data.caseNos);
            }
            if (obj_caseNos != null) {
                var obj_courtcode = (data.court_code);

                var obj_establishment_name = (data.establishment_name);

                jsonData[JSON.stringify(obj_courtcode)] = JSON.stringify(data);
                // window.sessionStorage.setItem("SET_RESULT", JSON.stringify(jsonData));
                window.sessionStorage.setItem("SET_RESULT", true);


                var panel_body = [];
                var totalCases = obj_caseNos.length;
                total_Cases = Number(totalCases) + Number(total_Cases);
                var trHTML = '';
                var court_code = obj_courtcode;

                panel_id = 'card'+ state_code_data + '_' + district_code_data + '_' + court_code;


                establishment_name = obj_establishment_name;
                establishment_name = establishment_name + " : " + totalCases;

                panel_body.push('<div class="card" >');
                panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-toggle="collapse" data-parent="#accordion_search" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>"+srNoLabel+"</th><th>"+caseNoLabel+"</th><th>"+firNoLabel+"</th><th>"+partyNameLabel+"</th></tr></thead><tbody>");

                collapseid++;
                var index = 0;
                var txt_type_name=null;
                $.each(obj_caseNos, function (key, val) {
                    index++;
                    // if(localStorage.LANGUAGE_FLAG=="english"){
                    if(bilingual_flag != "1"){
                        txt_type_name=val.type_name;
                    }else{
                        txt_type_name=val.ltype_name;
                    }
                    
                    var petresName = val.petnameadArr;
                    var case_type_number = txt_type_name + '/' + val.case_no2 + '/' + val.reg_year;
                    var firNuber_year = '';
                    if(val.fir_no == '' || val.fir_year == 0){
                        firNuber_year = '';
                    }else{
                        firNuber_year = val.fir_no + '/' + val.fir_year;
                    }                        
                    var casehistorylink = '';
                    if(val.case_no == null){
                        casehistorylink = 'filing_case_history_link';
                    }else{
                        casehistorylink = 'case_history_link';
                    }
                    var hrefurl = "<a style='color:#03A8D8;text-decoration:underline;' href='#' class='"+casehistorylink+"  'court_code='" + court_code + "'cino='" + val.cino + "'case_no='" + val.case_no + "'>" + case_type_number + '</a>';

                    trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td></tr>";
                    panel_body.push("<tr><td>" + index + "</td><td>" + hrefurl + "</td> <td>" + firNuber_year + "</td> <td>" + petresName + "</td></tr>");
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


//fetch police stations from web service or session storage
function populatePoliceStation() {
    $('#police_station').empty();
    $('#police_station').append('<option id="" value="">'+selectPoliceStationLabel+'</option>');
   // var selectboxText = $("#court_code option:selected").text();
    //var selectboxText = $("#court_code").text();
    if (window.localStorage.SESSION_COURT_CODE == null) {
        return false;
    }

    var state_code_data = window.localStorage.state_code;
    var district_code_data = window.localStorage.district_code;

    var policeStationWebServiceUrl = hostIP + "policeStationWebService.php";
    var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

    court_code_data = courtCodesArr[0];
    var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
    // var encrypted_data5=null;
    // if(localStorage.LANGUAGE_FLAG=="english"){
    //     encrypted_data5 = encryptData("0");
    // }else{
    //     encrypted_data5 = encryptData("1");
    // }
    encrypted_data5 = (bilingual_flag.toString());
    var data = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
    
    //web service call to get police stations for selected court complex
    callToWebService(policeStationWebServiceUrl, data, policeStationSearchResult);

    function policeStationSearchResult(result){ 
        myApp.hidePleaseWait();
        var decodedResult = (result);
        $.each(decodedResult.police_stationlist, function (key, val) {
            var caseTypesArr = val.police_station.split("#");
            uniform_code = val.uniform_code;            
            $.each(caseTypesArr, function (key, val) {
                var casetype = val.split("~");
                $('#police_station').append('<option id="" value="' + casetype[0] + '">' + casetype[1] + '</option>');
            });
            if (window.sessionStorage.SESSION_SELECT_2 != null) {
                document.getElementById('police_station').value = window.sessionStorage.SESSION_SELECT_2;
            }
        });      
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