<?php
shell_exec("/opt/upload_bucket.sh");
header('Location: http://localhost:80/upload.html?success=true');
?>
