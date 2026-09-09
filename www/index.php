<?php
$conn = new mysqli("db", "appuser", "apppassword", "appdb");
?>
<!DOCTYPE html>
<html><head><title>Contacts</title>
<style>body{font-family:Arial;margin:40px} table{border-collapse:collapse} td,th{border:1px solid #ccc;padding:8px;}</style>
</head><body>
<h1>Rolodex Contacts</h1>
<?php
if($conn->connect_error){ die("Database connection failed: ".$conn->connect_error); }
$result=$conn->query("SELECT * FROM contacts ORDER BY last_name");
echo '<table><tr><th>First Name</th><th>Last Name</th><th>Email</th><th>Phone</th></tr>';
while($row=$result->fetch_assoc()){
 echo '<tr><td>'.$row['first_name'].'</td><td>'.$row['last_name'].'</td><td>'.$row['email'].'</td><td>'.$row['phone'].'</td></tr>';
}
echo '</table>';
?>
</body></html>
