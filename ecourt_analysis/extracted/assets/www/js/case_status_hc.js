    $(document).ready(function () {
        $("#footer").load("footer.html");
        state_code_data = localStorage.getItem('state_code');
        district_code_data = localStorage.getItem('district_code');
        $('.btn.case_number').on('click', function (event) {
            event.preventDefault();
            if (validate()) {    
               $.ajax({
                type: "GET",
                url: 'search_by_case_number_hc.html'
         }).done(function(data) {
             window.sessionStorage.setItem("Selected_screen","case_number");
               $("#searchPageData").html(data);
               $("#searchPageModal").modal('show');
             });
            }
        });
        $('.btn.party_name').on('click', function (event) {
            event.preventDefault();
            if (validate()) {
                $.ajax({
                type: "GET",
                url: 'search_by_party_name_hc.html?state_code=' + localStorage.getItem("state_code") + '&dist_code=' + localStorage.getItem("district_code")
            }).done(function(data) {
                window.sessionStorage.setItem("Selected_screen","party_name");
                $("#searchPageData").html(data);
                $("#searchPageModal").modal('show');
              });
            }
        });
        $('.btn.advocate_name').on('click', function (event) {
            event.preventDefault();
            if (validate()) {            
               $.ajax({
                type: "GET",
                url: 'search_by_advocate_name_hc.html'
         }).done(function(data) {
             window.sessionStorage.setItem("Selected_screen","advocate_name");
               $("#searchPageData").html(data);
               $("#searchPageModal").modal('show');
             });
            }
        });
        $('.btn.filling_number').on('click', function (event) {
            event.preventDefault();
            if (validate()) {            
               $.ajax({
                type: "GET",
                url: 'search_by_filing_number_hc.html'
         }).done(function(data) {
             window.sessionStorage.setItem("Selected_screen","filling_number");
               $("#searchPageData").html(data);
               $("#searchPageModal").modal('show');
             });
            }
        });
        $('.btn.fir_number').on('click', function (event) {
            event.preventDefault();
            if (validate()) {            
               $.ajax({
                type: "GET",
                url: 'search_by_fir_number_hc.html'
         }).done(function(data) {
             window.sessionStorage.setItem("Selected_screen","fir_number");
               $("#searchPageData").html(data);
               $("#searchPageModal").modal('show');
             });
            }
        });
        $('.btn.case_type').on('click', function (event) {
            event.preventDefault();
            if (validate()) {            
               $.ajax({
                type: "GET",
                url: 'search_by_case_type_hc.html'
         }).done(function(data) {
             window.sessionStorage.setItem("Selected_screen","case_type");
               $("#searchPageData").html(data);
               $("#searchPageModal").modal('show');
             });
            }
        });
        $('.btn.act').on('click', function (event) {
            event.preventDefault();
            if (validate()) {            
               $.ajax({
                type: "GET",
                url: 'search_by_act_hc.html'
         }).done(function(data) {
             window.sessionStorage.setItem("Selected_screen","act");
               $("#searchPageData").html(data);
               $("#searchPageModal").modal('show');
             });
            }
        });
        $('.btn.caveat').on('click', function (event) {
            event.preventDefault();
            if (validate()) {            
               $.ajax({
                type: "GET",
                url: 'search_by_caveat_hc.html'
         }).done(function(data) {
             window.sessionStorage.setItem("Selected_screen","caveat");
               $("#searchPageData").html(data);
               $("#searchPageModal").modal('show');
             });
            }
        });
    });

    function validate() {
        //state_code_data = window.localStorage.getItem('state_code');
        //district_code_data = window.localStorage.getItem('district_code');
        var state_code_data = $("#state_code").val();
        var district_code_data = $("#dist_code").val();
        
        if (state_code_data == null || state_code_data=='') {
            alert("Please select High Court");
            return false;
        }
        if (district_code_data == null || district_code_data=='') {
            alert("Please select Bench");
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
