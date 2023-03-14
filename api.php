<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type");

$con = mysqli_connect("localhost","pc-my-account","beqjen-Temcaw-gesso4","papacambridge_myaccount");

function get_pastpapers_file_alias($value,$domain)
{
global $con;
  $fileNameStructure = [];
  $structures = mysqli_query($con, "SELECT * FROM `file_name_structures`");
  while ($row = mysqli_fetch_assoc($structures)) {
    $fileNameStructure[$row['abbriviation']] = $row['name'];
  }
   $filename = $value;
  $filename = pathinfo($filename, PATHINFO_FILENAME);
  if (strpos($filename, "-") !== false) {
    $file = explode('-', $filename);
  } else {
    $file = explode('_', $filename);
  }
  if (sizeof($file) <= 4) {
    $course = array_shift($file);
    if ($domain == '1') {
      $season = preg_replace('/[0-9]+/', '', $file[0]);
      $seasonYear = preg_replace('/[a-z]+/', '', $file[0]);
      $dateTime = \DateTime::createFromFormat('y', $seasonYear);
    }
    $type = $file[1];
    $endPart = $file[count($file) - 1];
    $endPartSplit = str_split($endPart, 1);
    $t = [];
    if ($endPartSplit) {
      if (array_key_exists(0, $endPartSplit) && $endPartSplit[0] != 0) {
        $t[] = 'Paper ' . $endPartSplit[0];
      }
		else{
		   $t[] = 'Paper 0';
		}
      if (array_key_exists(1, $endPartSplit) && $endPartSplit[1] != 0) {
        $t[] = 'Variant ' . $endPartSplit[1];
      }
		else{
		   $t[] = 'Variant 0' ;
		}
    }
    $s = mysqli_query($con, "SELECT * from file_name_structures where abbriviation = '" . $type . "'");

    if (mysqli_num_rows($s) > 0) {
      if ($domain == '1') {
        $fileAlias = $fileNameStructure[$course] . ' ' . (array_keys($fileNameStructure, $fileNameStructure[$course])[0]) . ' ' . $fileNameStructure[$season] . ' ' . $dateTime->format('Y') . ' ' . @$fileNameStructure[$type] . ' ' . (implode(' ', $t));
      }
    } else {
      $fileAlias = $filename;
    }

   // return ['fileName' => $fileAlias];
    return  $fileAlias;
  }
}

switch ($_GET['page'])
{

    case 'select_board':


        if ($_POST['token'] != "C8xWxGvIue37SwP2MEU7W5oKE32fm7Z3JxHfeK897a8eE0SdLl")
        {
				  $files["data"] = array(
                'status' => "error",
                'msg' => "Invalid Token"
            );
            echo json_encode($files);

            exit();
        }

        $files = array();
        $select = mysqli_query($con, "SELECT * from board_setting");

        if (mysqli_num_rows($select) == 0)
        {
            $files["data"] = array(
                'status' => "error",
                'msg' => "Data Not Found"
            );
            echo json_encode($files);
        }

        $response = array();
        $i = 0;

        while ($fetch = mysqli_fetch_assoc($select))
        {
        
            $response[$i]['id'] = $fetch['id'];
            $response[$i]['name'] = $fetch['name'];
    
            $i++;
        }

        echo json_encode($response, JSON_PRETTY_PRINT);

    break;
		
		   case 'domains':

		$board = $_POST['board'];
        if ($_POST['token'] != "C8xWxGvIue37SwP2MEU7W5oKE32fm7Z3JxHfeK897a8eE0SdLl")
        {
			
			  $files["data"] = array(
                'status' => "error",
                'msg' => "Invalid Token"
            );
            echo json_encode($files);

            exit();
        }

        $files = array();
        $select = mysqli_query($con, "SELECT * from setting where board_id='$board'");

        if (mysqli_num_rows($select) == 0)
        {
            $files["data"] = array(
                'status' => "error",
                'msg' => "Data Not Found"
            );
            echo json_encode($files);
        }

        $response = array();
        $i = 0;

        while ($fetch = mysqli_fetch_assoc($select))
        {
        
            $response[$i]['id'] = $fetch['id'];
            $response[$i]['domain'] = $fetch['website_name']." ".$fetch['website_name2'];
    
            $i++;
        }

        echo json_encode($response, JSON_PRETTY_PRINT);

    break;
		
		
		case 'main_file':

		$domain = $_POST['domain'];
        if ($_POST['token'] != "C8xWxGvIue37SwP2MEU7W5oKE32fm7Z3JxHfeK897a8eE0SdLl")
        {
			
				  $files["data"] = array(
                'status' => "error",
                'msg' => "Invalid Token"
            );
            echo json_encode($files);

            exit();
        }

        $files = array();
        $select = mysqli_query($con, "SELECT * from files where domain='$domain' and parent=0  and folder=1 and active=1");

        if (mysqli_num_rows($select) == 0)
        {
            $files["data"] = array(
                'status' => "error",
                'msg' => "Data Not Found"
            );
            echo json_encode($files);
        }

        $response = array();
        $i = 0;

        while ($fetch = mysqli_fetch_assoc($select))
        {
        
            $response[$i]['id'] = $fetch['id'];
            $response[$i]['name'] = $fetch['alias'];
    		 $response[$i]['url'] = $fetch['url_structure'];
            $i++;
        }

        echo json_encode($response, JSON_PRETTY_PRINT);

    break;
		
		
		case 'inner_file':

		$fileid = $_POST['fileid'];
        if ($_POST['token'] != "C8xWxGvIue37SwP2MEU7W5oKE32fm7Z3JxHfeK897a8eE0SdLl")
        {
				  $files["data"] = array(
                'status' => "error",
                'msg' => "Invalid Token"
            );
            echo json_encode($files);

            exit();
        }

        $files = array();
        $select = mysqli_query($con, "SELECT * from files where parent=$fileid");

        if (mysqli_num_rows($select) == 0)
        {
            $files["data"] = array(
                'status' => "error",
                'msg' => "Data Not Found"
            );
            echo json_encode($files);
        }

        $response = array();
        $i = 0;

        while ($fetch = mysqli_fetch_assoc($select))
        {
			$idc = $fetch['id'];
			    $select2 = mysqli_query($con, "SELECT * from files where parent=$idc");
			 
			
        
            $response[$i]['id'] = $fetch['id'];
			   $response[$i]['url'] = $fetch['url_structure'];
			
			$response[$i]['count'] =    ($select2);
			if($fetch['folder']==1){
				  $response[$i]['name'] = $fetch['alias'];
            $response[$i]['url_pdf'] ="";
			}
			else{
					$id= $fetch['id'];
				  $response[$i]['name'] = $fetch['name'];
			
				$selectLink = mysqli_query($con,"select setting.websiteurl,setting.path_folder from files LEFT JOIN setting on setting.id=files.domain where files.id='$id'  and files.active=1");
				$fetchLink = mysqli_fetch_array($selectLink);
				$replace = str_replace(" ","%20","https://".$fetchLink['websiteurl']."/".$fetchLink['path_folder']."upload/".$fetch['name']);
			    $response[$i]['url_pdf'] = $replace;
			}
            $i++;
      
		}
        echo json_encode($response, JSON_PRETTY_PRINT);

    break;
case 'search':
$domain = $_POST['domain'];
		$keyword = $_POST['keyword'];
        if ($_POST['token'] != "C8xWxGvIue37SwP2MEU7W5oKE32fm7Z3JxHfeK897a8eE0SdLl")
        {
				  $files["data"] = array(
                'status' => "error",
                'msg' => "Invalid Token"
            );
            echo json_encode($files);

            exit();
        }

        $files = array();
        $select = mysqli_query($con, "SELECT * from files where domain='$domain' and folder=1 and  name like '%$keyword%'");

        if (mysqli_num_rows($select) == 0)
        {
            $files["data"] = array(
                'status' => "error",
                'msg' => "Data Not Found"
            );
            echo json_encode($files);
        }

        $response = array();
        $i = 0;

        while ($fetch = mysqli_fetch_assoc($select))
        {
        
            $response[$i]['id'] = $fetch['id'];
		
				  $response[$i]['name'] = $fetch['alias'];
       
		
            $i++;
        }

        echo json_encode($response, JSON_PRETTY_PRINT);

    break;

    }
?>
