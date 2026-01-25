    $(document).ready(function () {                 
        $("#footer").load("footer.html");                
        $("#Case_Status_pannel").unbind("languageChanged").bind("languageChanged", function () {
             labelsarr = JSON.parse(window.sessionStorage.GLOBAL_LABELS);
             $("#case_number_span").html(labelsarr[9]);
             $("#party_span").html(labelsarr[30]);
             $("#filing_number_span").html(labelsarr[120]);
             $("#fir_number_span").html(labelsarr[22]);
             $("#advocate_span").html(labelsarr[3]);
             $("#act_span").html(labelsarr[1]);
             $("#case_type_span").html(labelsarr[12]);
            $("#caveat_span").html(labelsarr[602]);
            $("#pre_trial_span").html(labelsarr[603]);
        });        
        state_code_data = localStorage.getItem('state_code');
        district_code_data = localStorage.getItem('district_code');
        $('.btn.case_number').on('click', function (event) {
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_case_number.html'
             }).done(function(data) { 
                window.sessionStorage.setItem("Selected_screen","case_number");
                   $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $("#casestatus_heading1_label").focus();
             });
            }
        });
        $('.btn.party_name').on('click', function (event) {
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_party_name.html?state_code=' + localStorage.getItem("state_code") + '&dist_code=' + localStorage.getItem("district_code")
             }).done(function(data) {
                 window.sessionStorage.setItem("Selected_screen","party_name");
                $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
        $('.btn.advocate_name').on('click', function (event) {
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_advocate_name.html'
             }).done(function(data) {
                 window.sessionStorage.setItem("Selected_screen","advocate_name");
                $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
        $('.btn.filling_number').on('click', function (event) {
             event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_filing_number.html'
             }).done(function(data) { 
                 window.sessionStorage.setItem("Selected_screen","filling_number");
                 $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
        $('.btn.fir_number').on('click', function (event) {          
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_fir_number.html'
             }).done(function(data) { 
                 window.sessionStorage.setItem("Selected_screen","fir_number");
                 $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
        $('.btn.case_type').on('click', function (event) {            
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_case_type.html'
             }).done(function(data) {
                 window.sessionStorage.setItem("Selected_screen","case_type");
                $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
        $('.btn.act').on('click', function (event) {            
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_act.html'
             }).done(function(data) { 
                 window.sessionStorage.setItem("Selected_screen","act");
                 $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
        
          $('.btn.caveat').on('click', function (event) {            
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_caveat.html'
             }).done(function(data) { 
                 window.sessionStorage.setItem("Selected_screen","caveat");
                 $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
         $('.btn.pre_trial_appl').on('click', function (event) {            
            event.preventDefault();
            if (validate()) {    
                $.ajax({
                    type: "GET",
                    url: 'search_by_application.html'
             }).done(function(data) { 
                 window.sessionStorage.setItem("Selected_screen","pre_trial_appl");
                 $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
                 $(".page-title-main").focus();
             });
            }
        });
    });

    function validate() {
        state_code_data = window.localStorage.getItem('state_code');
        district_code_data = window.localStorage.getItem('district_code');
        if (state_code_data == null) {
            alert(labelsarr[52]);
            return false;
        }
        if (district_code_data == null) {
            alert(labelsarr[49]);
            return false;
        }
        return true;
    }

    $(function () {
        $("#searchPageModal").swipe({
            swipeStatus: function (event, phase, direction, distance, fingerCount) {
                return false;
            }
        });
    });
