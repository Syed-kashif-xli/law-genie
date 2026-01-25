    /*
    variables saved in local/ session storage to retain page session after page reload

    SESSION_COURT_CODE : court complexes selected value- saved in local storage  
    SESSION_SELECT_2 : police stations selected value- saved in session storage          
    SESSION_BACKLINK : current page- session storage 
    SESSION_INPUT_1 : fir number input value- session storage 
    SESSION_INPUT_2 : year input value- session storage 
    SET_RESULT : Result after Go button click- session storage 
    */
   var selectPoliceStationLabel = "Select Police Station";
    $(document).ready(function () {
        backButtonHistory.push("searchcasepage");
        second_header();
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;
        arrCourtEstNames = [];
        arrCourtEstCodes = [];

        $('#select_state').empty();
        $('#select_state').append('<option id="" value="">Select State</option>');

       
        
        if (window.localStorage.SESSION_COURT_CODE != null) {
             populateState();
            //populatePoliceStation();
        }
        
        $('#select_state').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
             $("#headers").empty(); 
             
            if ($('#select_state').val() == '') {
                window.sessionStorage.removeItem("SESSION_SELECT_STATE");
            } else {
                window.sessionStorage.setItem("SESSION_SELECT_STATE", $('#select_state').val());
                populateDistrict(window.sessionStorage.SESSION_SELECT_STATE);
            }
        });
       /*  
        if(window.sessionStorage.SESSION_SELECT_DISTRICT!=null)
            {*/
            //  populateDistrict(window.sessionStorage.SESSION_SELECT_STATE);
           // } 
        $('#select_district').change(function () {
            
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
            if ($('#select_district').val() == '') {
                window.sessionStorage.removeItem("SESSION_SELECT_DISTRICT");
            } else {
                
                window.sessionStorage.setItem("SESSION_SELECT_DISTRICT", $('#select_district').val());
                 populatePoliceStationHC(window.sessionStorage.SESSION_SELECT_DISTRICT);
            }
            
        });
        
      /*   if (window.sessionStorage.SESSION_SELECT_2 != null) {
            populatePoliceStationHC(window.sessionStorage.SESSION_SELECT_DISTRICT);
        }
        if (window.sessionStorage.SESSION_PENDING_DISPOSED != null) {
            var selected_radio = window.sessionStorage.SESSION_PENDING_DISPOSED;        
            var $radios = $('input[name=radOpt1]');
            $radios.filter('[value='+selected_radio+']').prop('checked', true);
        } */
        $('#police_station').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();
           /*  if ($('#police_station').val() == '') {
               window.sessionStorage.removeItem("SESSION_SELECT_2");
            } else {
                window.sessionStorage.setItem("SESSION_SELECT_2", $('#police_station').val());
            } */
        });
       /*  if (window.sessionStorage.SESSION_INPUT_2 != null) {
            $("#rgyear").val(window.sessionStorage.SESSION_INPUT_2);
        }
        if (window.sessionStorage.SESSION_INPUT_1 != null) {
            $("#fir_no").val(window.sessionStorage.SESSION_INPUT_1);
        }
        if (window.sessionStorage.SESSION_SELECT_2 != null && window.localStorage.SESSION_COURT_CODE != null && window.sessionStorage.SESSION_SELECT_STATE != null) {
            $("#goButton").click();
        }

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
        }); */

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#totalEstablishments").empty();
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
                $(".fir_number_val").html(" only letters, numbers ").show().fadeOut("slow");
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
                $(".year_error").html("4 Digits Only in year").show().fadeOut("slow");
                $("#rgyear").val("");
              return false;
            }
            if (pat.test($(this).val()) == false) {
                $(".year_error").html(" only letters, numbers ").show().fadeOut("slow");
                $("#rgyear").val("");
                 $("#rgyear").focus(); 
                return false;
            }
        });

    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        //window.localStorage.removeItem('SESSION_COURT_CODE');
   //     window.sessionStorage.removeItem('#fir_no');
  //      window.sessionStorage.removeItem('#rgyear');
       // window.sessionStorage.removeItem('#police_station');
        window.sessionStorage.removeItem('SET_RESULT');
        $("#select_state").val('');
        $("#select_district").val('');
        $("#police_station").empty(); 
        $('#police_station').append('<option id="" value="">'+selectPoliceStationLabel+'</option>');
        var $radios = $('input[name=radOpt1]');
        $radios.filter('[value=Pending]').prop('checked', true);  
        $("#case_type").val('');
        $("#fir_no").val('');
        $("#rgyear").val('');
        
        $("#totalEstablishments").empty();
        $("#accordion_search").empty();
        $("#headers").empty(); 
        //location.reload();
    });

    //fetch search data from web service or session storage
    $("#goButton").click(function (e) {
        e.preventDefault();
       /*  window.sessionStorage.setItem("SESSION_INPUT_1", $("#fir_no").val());
        window.sessionStorage.setItem("SESSION_INPUT_2", $("#rgyear").val());    window.sessionStorage.setItem("SESSION_PENDING_DISPOSED",$("input[name='radOpt1']:checked").val()); */
        if(window.sessionStorage.SET_RESULT == null){
        return populateCasesTable();
        }

    });

    function populateCasesTable() {
       
   // $("#totalEstablishments").empty();
        $("#results_container").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var select_state_text = $("#select_state option:selected").val();
        if(select_state_text==null || select_state_text==''){
            showErrorMessage("Please select State");
                return false;
        }
        
        var dist = $("#select_district option:selected").val();
        if(dist==0 || dist=='')
            {
                showErrorMessage("Please select District");
                return false;
            }
        
        var selectpolicestationboxText = $("#police_station option:selected").val();
                
        if (selectpolicestationboxText == null || selectpolicestationboxText=='') {
            showErrorMessage("Please select Police Station");
            return false;
        }

        var pendingDisposed = $("input[name='radOpt1']:checked").val();


        var firNumber = $("#fir_no").val();
        var year = $("#rgyear").val();

       if(!firNumber.length==0){
            if (firNumber === '' || firNumber === null) {
                showErrorMessage("Please Enter Valid FIR Number");
                $("#fir_no").val("");
                $("#fir_no").focus(); 
                return false;
            }
            if (firNumber <= 0) {
                showErrorMessage("Please Enter Non Zero FIR Number");
                $("#fir_no").val("");
                $("#fir_no").focus(); 
                return false;
            }

        }

     var year = $("#rgyear").val();


    if(year !='')
    {

            if (year === '' || year === null) {
                showErrorMessage("Please Enter Valid Year");
                $("#rgyear").val("");
                $("#rgyear").focus(); 
                return false;
            }
            if (year <= 0) {
                showErrorMessage("Please Enter Non Zero Year");
                $("#rgyear").val("");
                 $("#rgyear").focus(); 
                return false;
            }
             if(year.toString().length < 4)
                {
                     showErrorMessage("please enter 4 digit year");
                    $("#rgyear").val("");
                     $("#rgyear").focus(); 
                    return false;

                }

            var d = new Date();
            var n = d.getFullYear();
            if (year <= 1900 || year > n)
            {
                showErrorMessage("Please Enter Year between 1901 to " + n);
                $("#rgyear").val("");
                 $("#rgyear").focus(); 
                return false;
            }
        }
        window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_fir_number_hc.html");
        if (window.sessionStorage.getItem("SET_RESULT") == null) {
            var firNumberSearchUrl = hostIP + "firNumberSearch.php";

            var police_stationcode = $("#police_station option:selected").val();

            var request_data = {police_stationcode:(police_stationcode),firNumber:(firNumber),year:(year), pendingDisposed:(pendingDisposed)};
            displayCasesTableFir(firNumberSearchUrl, request_data);
        } 
        //else {
           // displayCasesTableFir1();
       // }
    }

    function displayCasesTableFir(url, request_data){

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
         myApp.showPleaseWait();
        var establishments_count = arrCourtEstCodes.length;

        var count = 0;
        var count1 = 0;

        var jsonData = {};
        for (var i = 0; i <= arrCourtEstCodes.length - 1; i++) {
            if(arrCourtEstCodes[i] != ","){
            count++;

            var encrypted_data1 = (state_code_data);
            var encrypted_data2 = (district_code_data);
            var encrypted_data3 = (arrCourtEstCodes[i]);


            var data1 = {state_code:encrypted_data1.toString(),dist_code:encrypted_data2.toString(), court_code:encrypted_data3.toString()};

            var data = $.extend({}, data1, request_data); 


            var establishment_name;
            var collapseid = 0;

            //populate the result table with court establishment as collapse field
                callToWebService(url, data, firSearchResult);

                function firSearchResult(data){
                    var obj_caseNos = null;
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

                        panel_id = 'card' + state_code_data + '_' + district_code_data + '_' + court_code;


                        establishment_name = obj_establishment_name;
                        establishment_name = establishment_name + " : " + totalCases;

                        panel_body.push('<div class="card">');
                        panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-toggle="collapse" data-parent="#accordion_search" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                        panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>FIR Number/Year</th><th>Party Name</th></tr></thead><tbody>");

                        collapseid++;
                        var index = 0;
                        $.each(obj_caseNos, function (key, val) {
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
                            
                            casehistorylink = 'case_history_link';
                           
                            var hrefurl = "<a  data-toggle='modal' data-target='#loading' style='color:#03A8D8;text-decoration:underline;' href='#' class='"+casehistorylink+"  'court_code='" + court_code + "'cino='" + val.cino + "'case_no='" + val.case_no + "'>" + case_type_number + '</a>';

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
                        establishments_count -= 1;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;

                    }

                    if (count1 == establishments_count){            
                        myApp.hidePleaseWait();             
                    }               

            }
                    /*setTimeout(function(){ p.abort(); }, 60000);*/

        }else {
            establishments_count -= 1;
            document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;

        }
        }   
    }


//fetch states from web service or session storage
    function populateState() {
        $('#select_state').empty();
        $('#select_state').append('<option id="" value="">Select State</option>');
//        var selectboxText = $("#court_code option:selected").text();
//        var selectboxText = $select.text();
       

        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;

        var stateWebService_hcUrl = hostIP + "stateWebService_hc.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];

        var stateData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data)};
        //web service call to get states
        callToWebService(stateWebService_hcUrl, stateData, firStateSearchResult);
        function firStateSearchResult(result){   
                var decodedResult = (result.states);                    
                $.each(decodedResult, function (key, val) {
                        $('#select_state').append('<option id="" value="' + val.state_id + '">' + val.state_name + '</option>');
                });
            myApp.hidePleaseWait();
        }
    }

//fetch District from web service or session storage
    function populateDistrict(state_selected) {
        $('#select_district').empty();
        $('#select_district').append('<option id="" value="">Select District</option>');
//        var selectboxText = $("#court_code option:selected").text();
//        var selectboxText = $select.text();
       

        var establishment_state_code = state_selected;
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;

//        var stateWebService_hcUrl = "http://" + hostIP + "districtWebService_hc.php";
        var stateWebService_hcUrl = hostIP + "districtWebService.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];

        var stateData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data), establishment_state_code:(establishment_state_code), action_code:('fir_subordinate')};
        //web service call to get states
            callToWebService(stateWebService_hcUrl, stateData, policeStationStateSearchResult);
            function policeStationStateSearchResult(result){
                var decodedResult = (result.districts);                         
                $.each(decodedResult, function (key, val) {
                        $('#select_district').append('<option id="" value="' + val.dist_code + '">' + val.dist_name + '</option>');
                });                      
                myApp.hidePleaseWait();
            }
    }

    //fetch police stations from web service or session storage
    function populatePoliceStationHC(establishment_district_code) {
        $('#police_station').empty();
        $('#police_station').append('<option id="" value="">Select Police Station</option>');
        /*var selectboxText = $("#court_code option:selected").text();
        // var selectboxText = $select.text();*/
       
        
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var establishment_district_code = establishment_district_code;
        var establishment_state_code = window.sessionStorage.SESSION_SELECT_STATE;
        
        var policeStationWebServiceUrl = hostIP + "policeStationWebService.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];

        var policaStationdata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data),establishment_state_code:(establishment_state_code),establishment_district_code:(establishment_district_code)};
        //web service call to get police stations for selected court complex
            callToWebService(policeStationWebServiceUrl, policaStationdata, policeStationSearchResult);
            function policeStationSearchResult(val){
                var decodedResult = (val);
                $.each(decodedResult.police_stationlist, function (key, val) {
                    if(val.police_station!=null)
                    {
                        var caseTypesArr = val.police_station.split("#");
                        $.each(caseTypesArr, function (key, val) {
                        var casetype = val.split("~");
                        $('#police_station').append('<option id="" value="' + casetype[0] + '">' + casetype[1] + '</option>');
                        });
                        /*  if (window.sessionStorage.SESSION_SELECT_2 != null) {
                            document.getElementById('police_station').value = window.sessionStorage.SESSION_SELECT_2;
                        } */
                    }                    
                });                 
                myApp.hidePleaseWait();
            }
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