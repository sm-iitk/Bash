<?php
$return_message="";
$username = $_POST['uname'];
$oldPassword = $_POST['oldpass'];
$newPassword = $_POST['newpass'];


$time = date("Y-m-d H:i:s"); 

$fh = fopen('user-info', 'r') or die($php_errormsg);
$usercnt = 0;
while (!feof($fh)) {
    $line = fgets($fh);
//    if (preg_match($username, $line)) { $usercnt = $usercnt+1; echo $usercnt;}
    if ( substr_count($line,$username)) { $usercnt = $usercnt+1;}
}
fclose($fh);


if ($usercnt < 10 ) {
        $date_of_expiry = time() + (86400 * 30) ; // 86400 = 1 day
        $cookie_file = 'user-info';
        setcookie($username, $username, $date_of_expiry);
        if (!isset($_COOKIE['count']))  {
                $cnt = 1;
                setcookie('count', $cnt, $date_of_expiry);
        }
        elseif (($_COOKIE['count'])<=5) {
                $cnt = ++$_COOKIE['count'];
                setcookie("count", $cnt);
        }
        else {
                echo "Your have accessed the page more than 10 times. Try after 1 day";
                exit;
        }
        file_put_contents($cookie_file, $time . ":  ", FILE_APPEND | LOCK_EX);
        file_put_contents($cookie_file, "Ldap Username: ". $username. ", ", FILE_APPEND | LOCK_EX);
     //   file_put_contents($cookie_file, "Usercount in file: ". $usercnt. ", ", FILE_APPEND | LOCK_EX);
        file_put_contents($cookie_file, "IP address: ". $_SERVER['REMOTE_ADDR']. ", ", FILE_APPEND | LOCK_EX);
   //     file_put_contents($cookie_file, "Client Info:[ ".  $_SERVER['HTTP_USER_AGENT'] . "], ", FILE_APPEND | LOCK_EX);
      //  file_put_contents($cookie_file, "Count: ". $_COOKIE['count']. ", \n", FILE_APPEND | LOCK_EX);
//        exit;
}
else {
        die("You have tried password change of user $username many times. Please contact system admin.\n");
}



if (isset($_POST["submitted"])) 
	{
		changePassword($username,$oldPassword,$newPassword);
	}
function changePassword($username, $old_password, $new_password)
	{
	$return_message=exec("sh ldap-chp.sh $username $old_password $new_password");
	if($return_message=="0")
		{
		echo "Your password has been Changed!\n";
		}
	else
		{
		echo "Error while changing password : $return_message \n";
		}

	}
?>

