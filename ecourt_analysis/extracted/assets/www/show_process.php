 define('NFS_REL_PATH','/');
        define('NFS_ABS_PATH','/home/court/');
        define('NFS_DIR_NAME','/nfsshare/njdgJsonObjects/');

        if(isset($_REQUEST['p']))
                $p=$_REQUEST['p'];
        else
                $p='';
        list($estcode,$year,$month,$process_id,$processtype,$est_state_code,$est_dist_code)=explode('/',$p);

        //$data = file_get_contents ("njdg_establishment_json_$est_state_code.json");
        $data = file_get_contents (NFS_REL_PATH.NFS_DIR_NAME."njdg_establishment_json_$est_state_code.json");

        $json_decoded = json_decode(stripslashes($data),true);

        $establishment_arr=$json_decoded[$est_state_code][$est_dist_code];
        //echo 'anil====>'.$estcode.'<br/>';

        $est_arr=array();
        foreach ($establishment_arr as $key => $value)
        {
                $est_arr[$value['national_court_code']]=$value['serverip_order'].'~'.$value['db_name'];
        }
//print_r($est_arr);
        $est_details=$est_arr[$estcode];
        list($server_ip,$db_name)=explode('~',$est_details);


        if($processtype==1)
                $dirname="civil_process/$year/$month/$process_id.pdf";
        else
                $dirname="criminal_process/$year/$month/$process_id.pdf";

        $url="http://$server_ip/$db_name/$dirname";
//echo $url;exit;
        $curl = curl_init($url);
        //$code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        //if($code == 200){
                header('Content-type: application/pdf');
                $contents = curl_exec($curl);
        //      $status = true;
    //}else{
     // $status = false;
?>