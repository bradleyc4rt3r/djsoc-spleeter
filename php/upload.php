<?php

// Verify Upload
$allowedExts = array('mp3', 'wav', 'mpeg', 'wav', 'flac', 'ogg', 'm4a', 'wma');
if(isset($_POST['submit'])) {
    $filename = str_replace(' ', '', basename($_FILES["fileToUpload"]["name"]));
    $fileNameCmps = explode(".", $filename);
    $fileType = strtolower(end($fileNameCmps));
    $zipFile = preg_replace('/\\.[^.\\s]{3,4}$/', '', $filename) .".zip";
    $split_dir = "/data/envs/" . $filename . "/";
    $output_dir = "/data/complete/" . preg_replace('/\\.[^.\\s]{3,4}$/', '', $filename) . "/";

    if(in_array($fileType, $allowedExts)) {
        $returnCode = 0;
    } else {
        $returnCode = 1;
        die("File format is not allowed.");
    }
} else {
    die("Not a POST request.");
}

function prepEnv($split_dir, $filename) {
    try {
        if (!is_dir("/data/envs/" . $filename . "/")) {
            shell_exec('mkdir /data/envs/' . $filename);
            shell_exec('chmod 0777 /data/envs/' . $filename);
        }
    } catch (Exception $e) {
        die ("Could not create directory: " . $split_dir);
    }


    try {
        global $returnCode;
        $target_file = '/data/envs/' . $filename . "/" . $filename;
        if (!move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
            $returnCode = 1;
            throw new Exception('Could not move file: ' . $filename);
        }
        $returnCode = 0;
    } catch (Exception $e) {
        die ($e->getMessage());
    }
}

function activateSpleeter($filename) {
    chdir('/var/www/html/');
    $shell_command = "bash -i ./activate-spleeter.sh " . $filename;
    shell_exec($shell_command);
}


function zipFiles($filename, $zipFile) {
    $rootPath = realpath('/data/complete/' . preg_replace('/\\.[^.\\s]{3,4}$/', '', $filename) . '/');
    $zip = new ZipArchive();
    $zip->open($zipFile, ZipArchive::CREATE | ZipArchive::OVERWRITE);

    // Create recursive directory iterator
    /** @var SplFileInfo[] $files */
    $files = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($rootPath),
        RecursiveIteratorIterator::LEAVES_ONLY
    );

    foreach ($files as $name => $file)
    {
        if (!$file->isDir())
        {
            $filePath = $file->getRealPath();
            $relativePath = substr($filePath, strlen($rootPath) + 1);
            $zip->addFile($filePath, $relativePath);
        }
    }
    $zip->close();
}

function downloadZip($filename, $zipFile){
    if(isset($_POST['submit'])) {
        $zipDir = "/data/complete/" . preg_replace('/\\.[^.\\s]{3,4}$/', '', $filename);
        $zipPath = $zipDir . '/' . $zipFile;
        $oldZipPath = "/var/www/html/" . $zipFile;

        shell_exec("sudo -H -u brad bash -i -c 'chmod -R 0777 '" . $zipDir);
        if(!rename($oldZipPath, $zipPath)) {
            die("Could not move zip: " . $zipFile);
        }
        else {
            global $returnCode;
            $returnCode == 0;
        }

        chdir($zipDir);
        if (headers_sent()) {
            die("HTTP headers already sent");
        } else {
            header('Content-type: application/zip');
            header('Content-Disposition: attachment; filename=' . $zipFile);
            header('Content-Length: ' . filesize($zipFile));
            readfile($zipFile);
        }
    }

}
// Main

if($returnCode == 0) {
    try{
        global $filename;
        global $output_dir;
        global $zipFile;
        prepEnv($split_dir, $filename);
        activateSpleeter($filename);

        if(!file_exists($output_dir)) {
            throw new Exception("Split unsuccessful: " . $filename);
        } else {
            zipFiles($filename, $zipFile);
            downloadZip($filename, $zipFile);
        }
    } catch (Exception $e) {
        die ($e -> getMessage());
    }
} else {
    die("An unknown problem occurred...");
}
?>
