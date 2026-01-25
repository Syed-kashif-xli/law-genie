var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
if(labelsarr){
    var totalNoOfEstLabel = labelsarr ? labelsarr[390] : "Total Number of Establishments in Court Complex";
    var totalNoOfCasesLabel = labelsarr ? labelsarr[83] : "Total Number of Cases";
}

var search_value;
var state_selected, district_selected;


var selectAnywhereLabel = "Anywhere"
var selectStartingWithLabel = "Starting With"
var selectSubCourtLabel = "Subordinate Court"
var selectCaveatNoLabel = "Caveat No."

var selectStateLabel = "Select State";
var selectDistrict = "Select District";
var selectCaseType = "Select Case Type";
var EnterCaseNo = "Enter Case Number";
var EnterYear = "Enter year";

var enterCaveatorNameLabel = "Enter Caveator Name";
var enterCaveateeNameLabel = "Enter Caveatee Name";
var enterCaveatorTeeName = "Enter Caveator/Caveatee Name";
var subordinateCourtName = "Select Subordinate Court Name";
var enterCaveatNo = "Enter Caveat Number";
var enterCaveatYear = "Enter Caveate Year";

    $(document).ready(function () {
        second_header();
        backButtonHistory.push("searchcasepage");
        sessionStorage.setItem("tab", "#profile");        
        displayCaveatSearchDiv('anywhere');      
        
        populateCourtComplexes();

        var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
        if(labelsarr){       
                $("#casestatus_heading1_label").html(labelsarr[11]);
                $("#search_by_caveat_label").html(labelsarr[450]);
                $("#court_complex_label").html(labelsarr[269]);
                $("#search_type_label1").html(labelsarr[68]);
                $("#search_type_label2").html(labelsarr[59]);
                $("#caveator_name_label").html(labelsarr[471]);
                $("#caveatee_name_label").html(labelsarr[469]);       

                 $("#caveator_caveatee_name_label").html(labelsarr[648]); 


                $("#select_state_label").html(labelsarr[106]);
                $("#select_district_label").html(labelsarr[107]);
                $("#subordinate_court_name_label").html(labelsarr[391]);
                $("#case_type_label").html(labelsarr[12]);
                $("#case_filing_number").html(labelsarr[10]);
                $("#year_label").html(labelsarr[81]);
                $("#decision_date_label").html(labelsarr[146]);

                $("#caveat_year_label").html(labelsarr[81]);
                $("#caveat_number1").html(labelsarr[333]); 
                $("#caveat_year_label").html(labelsarr[81]);    

            /*  $("#caveat_number1").html(labelsarr[333]); */
                $("#caveat_year_label").html(labelsarr[81]);

                $("#goButton").html(labelsarr[26]);
                $("#resetButton").html(labelsarr[57]);
            /*  document.getElementById("caveator").innerHTML=(labelsarr[31]);
                document.getElementById("caveatee").innerHTML=(labelsarr[21]); */
                document.getElementById("caseno").innerHTML=(labelsarr[9]);
                document.getElementById("filingno").innerHTML=(labelsarr[120]);

                selectAnywhereLabel = labelsarr[477];
                $("#select_search_type option[value = 'Anywhere']").text(selectAnywhereLabel);
                selectStartingWithLabel = labelsarr[476];
                $("#select_search_type option[value = 'StartingWith']").text(selectStartingWithLabel);
                selectSubCourtLabel = labelsarr[473];
                $("#select_search_type option[value = 'SubordinateCourt']").text(selectSubCourtLabel);
                selectCaveatNoLabel = labelsarr[472];
                $("#select_search_type option[value = 'CaveatNo.']").text(selectCaveatNoLabel);

                $("#select_state option[value = '']").text(labelsarr[106]);
                selectStateLabel = labelsarr[106];
                $("#select_district option[value = '']").text(labelsarr[107]);
                selectDistrict = labelsarr[107];
                $("#case_type option[value = '']").text(labelsarr[12]);
                selectCaseType = labelsarr[12];
                $("#subordinate_court_name option[value = '']").text(labelsarr[811]);
                subordinateCourtName = labelsarr[811];

                enterCaveatorNameLabel = labelsarr[685];
                $('#caveator_name').attr('placeholder',enterCaveatorNameLabel);

                enterCaveateeNameLabel = labelsarr[686];
                $('#caveatee_name').attr('placeholder',enterCaveateeNameLabel);

                enterCaveatorTeeName = labelsarr[687];
                $('#caveator_caveatee_name').attr('placeholder',enterCaveatorTeeName);
                document.getElementById("caveator").innerHTML=(labelsarr[751]);
                document.getElementById("caveatee").innerHTML=(labelsarr[649]);

                
                EnterCaseNo = labelsarr[682];
                $('#case_number').attr('placeholder',EnterCaseNo);

                EnterYear = labelsarr[683];
                $('#case_year').attr('placeholder',EnterYear);

                enterCaveatNo = labelsarr[689];
                $('#caveat_number').attr('placeholder',enterCaveatNo);

                $("#subordinate_court_name option[value = '']").text(labelsarr[688]);
                subordinateCourtName = labelsarr[688];

                enterCaveatYear = labelsarr[690];
                $('#caveat_year').attr('placeholder',enterCaveatYear)

        }
        
        
        $('#court_code').change(function () {
            // window.sessionStorage.removeItem("SESSION_COURTNAMES");
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
            if ($('#court_code').val() != "") {
                
                window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
                window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));
                resetSearchOnComplexChange();
                resetSearchType();
                if(search_value=="SubordinateCourt"){
                    populateState();
                    resetSearchOnComplexChange();
                    resetSearchType();
                }
            } else {
                window.localStorage.removeItem("SESSION_COURT_CODE");
                window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
            }
            
            if($('#court_code').val() == window.localStorage.SESSION_COURT_CODE)
            {
                resetSearchOnComplexChange();
                resetSearchType();
            } 
            $("#Causelist_pannel").trigger("courtCodeChanged");
           
        });
        
        $('#select_state').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($('#select_state').val() == '') {
               state_selected = '';
                //Reset district to empty...
                $("#select_district").empty();
                var select = document.getElementById("select_district");
                var el = document.createElement("option");
                el.textContent = selectDistrict;
                el.value = '';
                el.selected = true;
                select.appendChild(el);
                
                //Reset subordinate court name to empty...
                $("#subordinate_court_name").empty();
                var select = document.getElementById("subordinate_court_name");
                var el = document.createElement("option");
                el.textContent = subordinateCourtName;
                el.value = '';
                el.selected = true;
                select.appendChild(el);
                
                //Reset case type to empty...
                document.getElementById('case_type').value = '';
            } else {
                state_selected =  $('#select_state').val();
                populateDistrict(state_selected);
            }
            
        });
        
        $('#select_district').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($('#select_district').val() == '') {
               district_selected = '';
                 //Reset subordinate court name to empty...
                $("#subordinate_court_name").empty();
                var select = document.getElementById("subordinate_court_name");
                var el = document.createElement("option");
                el.textContent = subordinateCourtName;
                el.value = '';
                el.selected = true;
                select.appendChild(el);
                
                //Reset case type to empty...
                document.getElementById('case_type').value = '';
            } else {
                 district_selected = $('#select_district').val();
                populateLowerCourt(state_selected, district_selected);
            }
            
        });
        
         $('#pickyDate').attr('readonly', true);

            $('#pickyDate').datepicker({dateFormat: 'dd-mm-yy',

//                                        maxDate: +30 ,
//                                        minDate: -7,
                                       // onSelect: clearResult
                                       });
        var now = new Date();

        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);

        var today = (day) + "-" + (month) + "-" + now.getFullYear();

        $('#pickyDate').val(today);
      
        
    });

function isNumber(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}

$("#select_search_type").change(function () {
    document.getElementById('caveatSearch').innerHTML = "";
    search_value = $("#select_search_type").val();
    resetSearchOnComplexChange();
    switch(search_value){
           
        case "Anywhere" :
            displayCaveatSearchDiv('anywhere');
            break;
            
        case "StartingWith" :
            displayCaveatSearchDiv('starting_with');
            break;
            
        case "SubordinateCourt" :
            populateState();
            
            displayCaveatSearchDiv('subordinate_court');
            break;
            
        case "CaveatNo." :
            displayCaveatSearchDiv('caveat_no');
            break;
            
            
    }
    
});

    $('input[type=radio][name=radOpt2]').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty(); 
    });

    $('#radOpt_case_no').click(function(e){
        $('#case_filing_number').text("Case Number")
        $('#case_filing_number').html(labelsarr[10]);
        $('#case_number').attr("placeholder","Enter Case Number")
    });

    $('#radOpt_filing_no').click(function(e){
        $('#case_filing_number').text("Filing Number")
        $('#case_filing_number').text(labelsarr[120]);
        $('#case_number').attr("placeholder","Enter Filing Number")
    });
    
    $("#caveator_name").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var pat = /^[a-zA-z .'_-]*$/;
        if ($(this).val().length > 99) {
            $(".caveator_name").html("99 letter in caveator name").show().fadeOut("slow");
            $("#caveator_name").val("");
            return false;
        }
        if(localStorage.LANGUAGE_FLAG=="english"){
            // if(bilingual_flag == "1"){
            if (pat.test($(this).val()) == false) {
                $(".caveator_name").html(" only letters ").show().fadeOut("slow");
                $("#caveator_name").val("");
                return false;
            } 
        }else{
            var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
            if(format.test($(this).val())){            
                $(".caveator_name").html(" only letters ").show().fadeOut("slow");
                $("#caveator_name").val("");
                return false;
            }            
        }    
    });

    $("#caveatee_name").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var pat = /^[a-zA-z .'_-]*$/;
        if ($(this).val().length > 99) {
            $(".caveatee_name").html("99 letter in caveatee name").show().fadeOut("slow");
            $("#caveatee_name").val("");
            return false;
        }
        if(localStorage.LANGUAGE_FLAG=="english"){
            // if(bilingual_flag == "1"){
            if (pat.test($(this).val()) == false) {
                $(".caveatee_name").html(" only letters ").show().fadeOut("slow");
                $("#caveatee_name").val("");
                return false;
            } 
        }else{
            var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
            if(format.test($(this).val())){            
                $(".caveatee_name").html(" only letters ").show().fadeOut("slow");
                $("#caveatee_name").val("");
                return false;
            }             
        }
    });

    $("#caveator_caveatee_name").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var pat = /^[a-zA-z .'_-]*$/;
        if ($(this).val().length > 99) {
            $(".caveator_caveatee_name").html("99 letter in caveator caveatee name").show().fadeOut("slow");
            $("#caveator_caveatee_name").val("");
            return false;
        }
        if(localStorage.LANGUAGE_FLAG=="english"){
            // if(bilingual_flag == "1"){
            if (pat.test($(this).val()) == false) {
                $(".caveator_caveatee_name").html(" only letters ").show().fadeOut("slow");
                $("#caveator_caveatee_name").val("");
                return false;
            } 
        }else{
            var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
            if(format.test($(this).val())){            
                $(".caveator_caveatee_name").html(" only letters ").show().fadeOut("slow");
                $("#caveator_caveatee_name").val("");
                return false;
            }             
        } 

    });

    $("#case_number").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();
               
        if ($(this).val().length >= 7) {
            $(".case_number").html(labelsarr[807]).show().fadeOut("slow");
            $(this).val("");
            return false;
        }
    });

    $("#case_year").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        if ($(this).val().length > 4) {
            $(".case_year").html(labelsarr[808]).show().fadeOut("slow");
            $("#case_year").val("");    
            return false;
        }
    });

    $("#caveat_number").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();
    });

    $("#caveat_year").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        if ($(this).val().length > 4) {
            $(".caveat_year").html(labelsarr[808]).show().fadeOut("slow");
            $("#caveat_year").val("");    
            return false;
        }
    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        resetSearchOnComplexChange();
        resetSearchType();
        window.localStorage.removeItem('SESSION_COURT_CODE');
        window.sessionStorage.removeItem('SET_RESULT');
        $('#court_code').val("");
        $('#caveator_name').val("");
        $('#caveatee_name').val("");
        $('#caveator_caveatee_name').val("");
        $('#caveat_number').val("");
        $('#caveat_year').val("");
        $('#case_number').val("");
        $('#case_year').val("");
        var $subordinate_radios = $('input[name=radOpt3]');
        $subordinate_radios.filter('[value=2]').prop('checked', true);
        var $startingWith_radios = $('input[name=radOpt2]');
        $startingWith_radios.filter('[value=Caveator]').prop('checked', true);
        $("#headers").empty();
        $("#accordion_search").empty();
        $("#Causelist_pannel").trigger("courtCodeChanged"); 
    });

    //fetch search result after Go button click from web service or session storage
    $("#goButton").click(function (e) {
        e.preventDefault();
        if(window.sessionStorage.SET_RESULT == null){
            populateCaveatSearch();
        }
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

    // document.addEventListener("backbutton", onBackKeyDown, false);

    // function onBackKeyDown(e) 
    // {
    //     e.preventDefault();  
    //     window.location.replace("index.html");

    // }


function populateCaveatSearch(){
    if(window.localStorage.SESSION_COURT_CODE==null || window.localStorage.SESSION_COURT_CODE=='')
        {
            showErrorMessage(labelsarr[277]);
            //showErrorMessage("Please select court complex");
            $("#court_code").val("");
            $("#court_code").focus(); 
            return false;
            }
    var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
    // var  encrypted_data5=0;
    // if(localStorage.LANGUAGE_FLAG=="english"){
    //      encrypted_data5 = encryptData("0");
    // }else{
    //      encrypted_data5 = encryptData("1");
    // }
    var encrypted_data5 = (bilingual_flag.toString());
    var selectedSearchTypeVal = $('#select_search_type').val();
    var searchByCaveatURL = hostIP + "searchCaveat.php";
    
    var state_code_data = window.localStorage.state_code;
    var dist_code_data = window.localStorage.district_code;
    var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
    
    var arrCourtEstCodes = window.localStorage.SESSION_COURT_CODE.split(',');
    var total_cases = 0;
    
    $("#headers").empty();
    $("#accordion_search").empty();
        var headerArray = [];
        headerArray.push('<label">'+totalNoOfEstLabel+':<span id="totalEstablishmentsSpanId"></span> </label></div>');
        headerArray.push('<br>');
        headerArray.push('<label>'+totalNoOfCasesLabel+': <span id="totalcasesId"></span></label></div>');
        
        
    var establishments_count = arrCourtEstCodes.length;

        var count = 0;
        var count1 = 0;

    // for (var i = 0; i <= arrCourtEstCodes.length - 1; i++)  {
        
            // if(arrCourtEstCodes[i] != ","){
                
                
                var court_code_data = arrCourtEstCodes;
                var pat = /^[a-zA-z .'_-]*$/;
                
    switch(selectedSearchTypeVal){
        
        case 'Anywhere':
            var caveator_name= $('#caveator_name').val();
            var caveatee_name= $('#caveatee_name').val();

            if((caveator_name=='' || caveator_name==null) && (caveatee_name=='' || caveatee_name==null))
                {
                    showErrorMessage(labelsarr[486]);
                    $("#caveator_name").val("");
                    $("#caveator_name").focus(); 
                    return false;
                }
            
            if($('#caveator_name').val().length < 3)
                {
                    showErrorMessage(labelsarr[763]);
                    $('#caveator_name').val("");
                    $('#caveator_name').focus();
                    return false;
                }
            if(localStorage.LANGUAGE_FLAG=="english"){
            // if(bilingual_flag == "1"){
                if (pat.test($("#caveator_name").val()) == false) {
                    $(".caveator_name").html(" only letters").show().fadeOut("slow");
                    $("#caveator_name").val("");
                    return false;
                } 
                if (pat.test($("#caveatee_name").val()) == false) {
                    $(".caveatee_name").html(" only letters").show().fadeOut("slow");
                    $("#caveatee_name").val("");
                    return false;
                } 
            }else{
                var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
                if(format.test($("#caveator_name").val())){            
                    $(".caveator_name").html(" only letters").show().fadeOut("slow");
                    $("#caveator_name").val("");
                    return false;
                } 
                if(format.test($("#caveatee_name").val())){            
                    $(".caveatee_name").html(" only letters").show().fadeOut("slow");
                    $("#caveatee_name").val("");
                    return false;
                } 
            } 
            
            if((caveatee_name.length>0 || caveatee_name!='') && $('#caveatee_name').val().length < 3)
                {
                    showErrorMessage(labelsarr[764]);
                    $('#caveatee_name').val("");
                    $('#caveatee_name').focus();
                    return false;
                }
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code_arr:(court_code_data).toString(),caveator_name:(caveator_name),caveatee_name:(caveatee_name),action_code:('1'),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
            break;
            
         case 'StartingWith':
            
            var starting_wit_RadioVal = $("input[name='radOpt2']:checked").val();
            if(starting_wit_RadioVal == 'Caveator')
               { 
                   var caveator_name= $('#caveator_caveatee_name').val();
                    var caveatee_name= "";}
            else{
                    var caveatee_name= $('#caveator_caveatee_name').val();
                    var caveator_name="";}
            
            
            if($('#caveator_caveatee_name').val()=='' || $('#caveator_caveatee_name').val()==null)
                {
                   
                    showErrorMessage(labelsarr[765]);
                    $("#caveator_caveatee_name").val("");
                    $("#caveator_caveatee_name").focus(); 
                    return false;
                }
           
            if($('#caveator_caveatee_name').val().length < 3)
                {
                    showErrorMessage(labelsarr[763]);
                    $('#caveator_caveatee_name').val("");
                    $('#caveator_caveatee_name').focus();
                    return false;
                }
                
            if(localStorage.LANGUAGE_FLAG=="english"){
            // if(bilingual_flag == "1"){
                if (pat.test($("#caveator_caveatee_name").val()) == false) {
                    $(".caveator_caveatee_name").html(" only letters").show().fadeOut("slow");
                    $("#caveator_caveatee_name").val("");
                    return false;
                } 
            }else{
                var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
                if(format.test($("#caveator_caveatee_name").val())){            
                    $(".caveator_caveatee_name").html(" only letters").show().fadeOut("slow");
                    $("#caveator_caveatee_name").val("");
                    return false;
                }
            } 
          
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code_arr:(court_code_data).toString(),caveator_name:(caveator_name),caveatee_name:(caveatee_name),starting_wit_RadioVal:(starting_wit_RadioVal),action_code:('2'),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
            break;
            
         /*case 'Soundex':
            
            var starting_wit_RadioVal = $("input[name='radOpt2']:checked").val();
            if(starting_wit_RadioVal == 'Caveator')
               { 
                   var caveator_name= $('#caveator_caveatee_name').val();
                    var caveatee_name= "";}
            else{
                    var caveatee_name= $('#caveator_caveatee_name').val();
                    var caveator_name="";}
            
            break;*/
            
        case 'SubordinateCourt':
            
            var subordinate_court_name=$('#subordinate_court_name').val();
            var filing_type = $("input[name='radOpt3']:checked").val();
            var case_type=$('#case_type').val();
            var case_number=$('#case_number').val();
            var case_year=$('#case_year').val();
            var date_of_decision=$('#pickyDate').val();
            
            if ($('#select_state').val() == '') {
                showErrorMessage(labelsarr[52]);
                //showErrorMessage("Please select state");
                return false;
            }
            if ($('#select_district').val() == '') {
                showErrorMessage(labelsarr[49]);
                //showErrorMessage("Please select district");
                return false;
            }
            
            if (subordinate_court_name == '') {
                showErrorMessage(labelsarr[706]);
                return false;
            } 
            
            if (case_type == '') {
                showErrorMessage(labelsarr[44]);
                return false;
            }
            if (case_number == '') {
                showErrorMessage(labelsarr[35]);
                $("#case_number").val("");
                $("#case_number").focus(); 
                return false;
            } 
            
            if (case_year == '') {
                showErrorMessage(labelsarr[115]);
                $("#case_year").val("");
                $("#case_year").focus(); 
                return false;
            } 
            
             if(case_year.toString().length < 4)
            {
                showErrorMessage(labelsarr[42]);
                $("#case_year").val("");
                $("#case_year").focus(); 
                return false;
            }
            var d = new Date();
            var n = d.getFullYear();
            if (case_year <= 1900 || case_year > n)
            {
                showErrorMessage(labelsarr[43] + n);
                $("#case_year").val("");
                $("#case_year").focus(); 
                return false;
            }
            
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code_arr:(court_code_data).toString(),subordinate_court_name:(subordinate_court_name),filing_type:(filing_type),case_type:(case_type),case_number:(case_number),case_year:(case_year),date_of_decision:(date_of_decision),action_code:('4'),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
            break;
            
        case 'CaveatNo.':
            
            var caveat_number=$('#caveat_number').val();
            
            var caveat_year=$('#caveat_year').val();
           
            if (caveat_number == '') {
                showErrorMessage(labelsarr[482]);
                $("#caveat_number").val("");
                $("#caveat_number").focus(); 
                return false;
            }
            
            if (caveat_year == '') {
                showErrorMessage(labelsarr[81]);
                $("#caveat_year").val("");
                $("#caveat_year").focus(); 
                return false;
            } 
            
             if(caveat_year.toString().length < 4)
            {
                showErrorMessage(labelsarr[42]);
                $("#caveat_year").val("");
                $("#caveat_year").focus(); 
                return false;
            }
            var d = new Date();
            var n = d.getFullYear();
            if (caveat_year <= 1900 || caveat_year > n)
            {
                showErrorMessage(labelsarr[43] + n);
                $("#caveat_year").val("");
                $("#caveat_year").focus(); 
                return false;
            }
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code_arr:(court_code_data).toString(),caveat_number:(caveat_number),caveat_year:(caveat_year),action_code:('5'),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
            break;
            
    }
        
        var collapseid = 0;
        myApp.showPleaseWait();
        callToWebService(searchByCaveatURL, caveatData, searchByCaveatResult);
        function searchByCaveatResult(responseData){  
            for(const val in responseData){
                var result = responseData[val] ; 
                
            count++;           
            try{
                if(result != null){                    
                    if(result.msg){
                        if((result.status)=='fail'){
                            myApp.hidePleaseWait();
                            showErrorMessage((result.msg));
                        }
                    }else{ 
                        var totalCasesCnt = (result.totalCases);
                        total_cases += (result.totalCases);                   
                    if( totalCasesCnt!= 0){

                        window.sessionStorage.setItem("SET_RESULT", true);

                        decodedResult = (result.caveatSearchTable);
                        
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;

                        var obj_establishment_name = (result.court_name); 
                        
                        var panel_body = [];
                        //var total_Cases = Number(totalCases) + Number(total_Cases);
                        var trHTML = '';

                        panel_id = 'card' + state_code_data + '_' + dist_code_data + '_' + collapseid;

                        //establishment_name = obj_establishment_name;
                        establishment_name = obj_establishment_name.court_name;
                        establishment_name = establishment_name + " : " + (result.totalCases);

                        panel_body.push('<div class="card">');
                        panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-parent="#accordion_search" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                        panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'>");
                        panel_body.push(decodedResult);
                        panel_body.push('</div>');

                        collapseid++;

                        $("#accordion_search").append(panel_body.join(""));
                        /*if (Number(totalCases) != 0) {
                            $("#accordion_search").append(panel_body.join("")); 
                        }*/ 
                        document.getElementById('totalcasesId').innerHTML = total_cases;
                    }else{
                        
                        document.getElementById('totalcasesId').innerHTML = total_cases;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                    }
                }
            }
        }catch(e)
            {
                myApp.hidePleaseWait();     
            }
        }
            if (count1 == (establishments_count-1)){            
                myApp.hidePleaseWait();             
            }
            count1++;
        }
    // }else {
            /*If connection to establishment fails, reduce the total number of establishments*/
//                establishments_count -= 1;
                //document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;

            // }

        // }
    $("#headers").append(headerArray);
  
}



//fetch states from web service or session storage
    function populateState() {
        state_selected = '';
        $('#select_state').empty();
        $('#select_state').append('<option id="" value="">'+selectStateLabel+'</option>');
        $('#case_type').empty();
        $('#case_type').append('<option id="" value="">'+selectCaseType+'</option>');
//        var selectboxText = $("#court_code option:selected").text();
//        var selectboxText = $select.text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }

        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var district_code_data = window.localStorage.district_code;

        var stateWebService_Url = hostIP + "stateWebServiceCaveat.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
        // var encrypted_data5=null;
        // if(localStorage.LANGUAGE_FLAG=="english"){
        //      encrypted_data5 = encryptData("0");
        // }else{
        //      encrypted_data5 = encryptData("1");
        // }
        var encrypted_data5 = (bilingual_flag.toString());

        var stateData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
        //web service call to get states
        callToWebService(stateWebService_Url, stateData, caveatStateWSResult);
        function caveatStateWSResult(result){
         
            var decodedResult = (result.states);
                
            $.each(decodedResult, function (key, val) {
                if(val.state_name){
                    if(val.state_name!=""){  
                        $('#select_state').append('<option id="" value="' + val.state_id + '">' + val.state_name + '</option>');
                    }
                }
            }); 
            
            if (state_selected != null) {
                
                document.getElementById('select_state').value = state_selected;
                //populateDistrict(state_selected);
            }else{
                document.getElementById('select_state').value = '';
            }
                
            var decodedResult1 = (result.lcaseType);
                
            $.each(decodedResult1, function (key, val) {               
                $('#case_type').append('<option id="" value="' + val.lcase_type + '">' + val.type_name + '</option>');
            }); 
            
            myApp.hidePleaseWait();
        }

    }


//fetch District from web service or session storage
    function populateDistrict(state_selected) {
        district_selected = '';
        $('#select_district').empty();
        $('#select_district').append('<option id="" value="">'+selectDistrict+'</option>');
//        var selectboxText = $("#court_code option:selected").text();
//        var selectboxText = $select.text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }

        var establishment_state_code = state_selected;
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;

        var districtWebService_hcUrl = hostIP + "districtWebServiceCaveat.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
            // var encrypted_data5=null;
            // if(localStorage.LANGUAGE_FLAG=="english"){
            //      encrypted_data5 = encryptData("0");
            // }else{
            //      encrypted_data5 = encryptData("1");
            // }
        var encrypted_data5 = (bilingual_flag.toString());

        var districtData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data), establishment_state_code:(establishment_state_code),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
        //web service call to get states
        callToWebService(districtWebService_hcUrl, districtData, districtWebServiceResult);
        function districtWebServiceResult(result){                                            
            var decodedResult = (result.districts);
                
            $.each(decodedResult, function (key, val) {  
                if(val.dist_name){
                    if(val.dist_name!=""){                           
                        $('#select_district').append('<option id="" value="' + val.dist_code + '">' + val.dist_name + '</option>');
                    }
                }
            }); 
                
            if (district_selected != null) {
                
                document.getElementById('select_district').value = district_selected;
            }else{
                document.getElementById('select_district').value = '';
            }

            myApp.hidePleaseWait();
        }

    }


//fetch District from web service or session storage
    function populateLowerCourt(state_selected, district_selected) {
        $('#subordinate_court_name').empty();
        $('#subordinate_court_name').append('<option id="" value="">'+subordinateCourtName+'</option>');
//        var selectboxText = $("#court_code option:selected").text();
//        var selectboxText = $select.text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }

        var establishment_state_code = state_selected;
        var state_code_data = window.localStorage.state_code;
        var dist_code_data = window.localStorage.district_code;
        var establishment_district_code = district_selected;

        var lowerCourtWebServiceUrl = hostIP + "lowerCourtCaveat.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
            // var encrypted_data5=null;
            // if(localStorage.LANGUAGE_FLAG=="english"){
            //      encrypted_data5 = encryptData("0");
            // }else{
            //      encrypted_data5 = encryptData("1");
            // }
        var encrypted_data5 = (bilingual_flag.toString());
        var lowerCourtData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),establishment_state_code:(establishment_state_code),establishment_district_code:(establishment_district_code),language_flag:encrypted_data4.toString(),bilingual_flag:encrypted_data5.toString()};
       
        //web service call to get states
        callToWebService(lowerCourtWebServiceUrl, lowerCourtData, lowerCourtWebServiceResult);
        function lowerCourtWebServiceResult(result){           
            var decodedResult = (result.lowerCourt);
                
            $.each(decodedResult, function (key, val) {               
                $('#subordinate_court_name').append('<option id="" value="' + val.lower_court_code + '">' + val.oname + '</option>');
            }); 
            
            myApp.hidePleaseWait();
        }

    }

    function caveatHistory(caveat_number,court_code) {
        
        var state_code_data = window.localStorage.state_code;
        var dist_code_data = window.localStorage.district_code;
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
//        var court_code_data = courtCodesArr[0];
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
            // var encrypted_data5=null;
            // if(localStorage.LANGUAGE_FLAG=="english"){
            //      encrypted_data5 = encryptData("0");
            // }else{
            //      encrypted_data5 = encryptData("1");
            // }
        var encrypted_data5 = (bilingual_flag.toString());
        var caveatHistoryData = {court_code:(court_code), dist_code:(dist_code_data), caveat_number:(caveat_number), state_code:(state_code_data), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};

        var caveatCaseHistoryUrl = hostIP + "caveatCaseHistoryWebService.php";
        
        //web service call to get data for view business screen
        callToWebService(caveatCaseHistoryUrl, caveatHistoryData, caveatCaseHistoryWebServiceResult);
        function caveatCaseHistoryWebServiceResult(data){

            //save business data in local storage to use in view business page
            myApp.hidePleaseWait();

            var data = JSON.stringify(data.caveathistory);
            data = data.replace(/"/g, "");
            backButtonHistory.push("casehistory");
            var strheader = '<div class="row page-header-title" style="position:fixed;top:0;left:0;right:0;z-index:996;height:38px"><div class="col-12 "><h4 style="font-size: 1.2rem;padding-top: 5px;" class="">eCourts Services</h4></div></div>';
            strheader+='<div class="row container1" id="second_header3" style="background:#fff; border-bottom: 1px solid gray;position:fixed;top:0;left:0;right:0;z-index:996;margin-top:38px;"><div class="col-6 text-left"><h4 style="font-size:30px;cursor:pointer;margin-left:10px;margin:5px;"><a href="#" class="text-white" id="go_back_link_3" data-rel="back" onclick="goBackLinkClicked();return false;"><img src="images/back-icon.png" height="40"></a></h4></div></div>';
            data = strheader + data;                
            $("#caseHistoryModal").show();
            $("#historyData").html(data);

            $("#historyData").css("margin-top", "100px");
            $("#caseHistoryModal").modal();                                    
                       
        }; 

    }
function displayCaveatSearchDiv(div_id)
{
   // window.sessionStorage.setItem("CAVEAT_SEARCH_RADIO", div_id);
    switch(div_id)
        {
            case 'anywhere':
                    document.getElementById("anywhere").style.display = "block";
                    document.getElementById("starting_with").style.display = "none";
                    document.getElementById("subordinate_court").style.display = "none";
                    document.getElementById("caveat_no").style.display = "none";
            break;
            case 'starting_with':
                    document.getElementById("anywhere").style.display = "none";
                    document.getElementById("starting_with").style.display = "block";
                    document.getElementById("subordinate_court").style.display = "none";
                    document.getElementById("caveat_no").style.display = "none";
            break;
            case 'soundex':
                    document.getElementById("anywhere").style.display = "none";
                    document.getElementById("starting_with").style.display = "block";
                    document.getElementById("subordinate_court").style.display = "none";
                    document.getElementById("caveat_no").style.display = "none";
            break;
            case 'subordinate_court':
                    document.getElementById("anywhere").style.display = "none";
                    document.getElementById("starting_with").style.display = "none";
                    document.getElementById("subordinate_court").style.display = "block";
                    document.getElementById("caveat_no").style.display = "none";
            break; 
            case 'caveat_no':
                    document.getElementById("anywhere").style.display = "none";
                    document.getElementById("starting_with").style.display = "none";
                    document.getElementById("subordinate_court").style.display = "none";
                    document.getElementById("caveat_no").style.display = "block";
            break;
        }
}

function resetSearchType(){
    $("#select_search_type").val(""); 
    document.getElementById('select_search_type').value = 'Anywhere';
    $("#select_search_type").trigger("change"); 
    
}


function resetSearchOnComplexChange(){
    $("#caveator_name").val(""); 
    $("#caveatee_name").val("");
    $("#caveator_caveatee_name").val("");
    $("#case_number").val("");
    $("#case_year").val("");
    $("#caveat_number").val("");
    $("#caveat_year").val("");
    
     state_selected = '';
    //Reset state to empty...
    $("#select_state").empty();
    var select1 = document.getElementById("select_state");
    var el = document.createElement("option");
    el.textContent = selectStateLabel;
    el.value = '';
    el.selected = true;
    select1.appendChild(el);
    
    district_selected = '';
    //Reset district to empty...
    $("#select_district").empty();
    var select2 = document.getElementById("select_district");
    var el = document.createElement("option");
    el.textContent = selectDistrict;
    el.value = '';
    el.selected = true;
    select2.appendChild(el);

    //Reset subordinate court name to empty...
    $("#subordinate_court_name").empty();
    var select3 = document.getElementById("subordinate_court_name");
    var el = document.createElement("option");
    el.textContent = subordinateCourtName;
    el.value = '';
    el.selected = true;
    select3.appendChild(el);

    //Reset case type to empty...
    document.getElementById('case_type').value = '';

    $("#headers").empty();
    $("#accordion_search").empty();
    $("#totalEstablishments").empty();
}


// function go_back_link_searchPage_fun(){
    
//     backButtonHistory.pop();
   
//     $("#totalEstablishments").remove();
//     $("#searchPageModal").modal('hide');
// }

function go_back_link_searchPage_fun(){
    
    backButtonHistory.pop();  
    window.sessionStorage.removeItem("SET_RESULT");      
    $("#searchPageModal").modal('hide');
}

function goBackLinkClicked(){
    backButtonHistory.pop();
    $("#caveatDetailsHeader").focus();
    window.sessionStorage.removeItem("case_history");
    $("#caseHistoryModal").modal('hide'); 
}

function go_back_link_history_fun(){        
    backButtonHistory.pop();
    $("#caveatDetailsHeader").focus();
    window.sessionStorage.removeItem("case_history");
    $("#caseHistoryModal").modal('hide');  

}

$("#menubarClose").click(function (e)
{
    //e.preventDefault();
    if ($("#mySidenav1").is(':visible'))
    {
        closeNav1();
    }
});