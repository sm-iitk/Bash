<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<script type="text/javascript" src="validate.js"></script>
<title>Password Change Page</title>
<noscript>Sorry, your browser does not support JavaScript!</noscript>
<style type="text/css">
body { font-family: Verdana,Arial,Courier New; font-size: 0.7em; }
th { text-align: right; padding: 0.8em; }
#container { text-align: center; width: 500px; margin: 5% auto; }
.msg_yes { margin: 0 auto; text-align: center; color: green; background: #D4EAD4; border: 1px solid green; border-radius: 10px; margin: 2px; }
.msg_no { margin: 0 auto; text-align: center; color: red; background: #FFF0F0; border: 1px solid red; border-radius: 10px; margin: 2px; }
</style>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
</head>

<body>
<div id="container">
<h2>Change your password</h2>
<p>Your new password must be 8 characters long or longer and have at least:<br/>
one capital letter, one lowercase letter, &amp; one number.<br/>
You must use a new password, your current password<br/>can not be the same as your new password.</p>

<form action="chp.php" onsubmit="return checkForm()" id="form" method="post" autocomplete="on" name="passwordChange">
<table style="width: 400px; margin: 0 auto;">
	<tr><th>Username:</th><td><input name="uname" type="text" size="20px" autocomplete="off" required/></td></tr>
	<tr><th>Current password:</th><td><input name="oldpass" size="20px" type="password" required/></td></tr>
	<tr><th>New password:</th><td><input name="newpass" size="20px" type="password" required/></td></tr>
	<tr><th>New password (again):</th><td><input name="newpass1" size="20px" type="password" required/></td></tr>
	<tr><td colspan="2" style="text-align: center;" >
	<tr><td><input name="submitted" type="submit" value="Change Password"/></td>
	<td><input name="submitted" type="submit" value="Change Password as admin" formaction="admin.php" />
	<td><input type="reset" value="reset"></td></tr>
	</td></tr>
</table>
</form>

</div>
</body>

</html>
