<?php

$work_path = dirname(__FILE__);

$compiled_info_file = $work_path . '\\.compiledinfo.txt';
if(file_exists($compiled_info_file)){
	$str = file_get_contents($compiled_info_file);
	if($str){
		$compiled_info = unserialize($str);
	}else{
		$compiled_info = array();
	}
}else{
	echo "compiled info not exited \n";
	$compiled_info = array();
}
$compile_file = $argv[1];

function abort($file){
	echo "INPUT FILE ERROR! -> " . $file . "\n";
	// die();
}

function getPath($file){
	return preg_replace("/\\\w*.lua/", "", $file);
}

// function recurse_copy($src,$dst) {
//     // $dir = opendir($src);
//     @mkdir($dst);
//     while(false !== ( $file = readdir($dir)) ) {
//         if (( $file != '.' ) && ( $file != '..' )) {
//             if ( is_dir($src . '/' . $file) ) {
//                 recurse_copy($src . '/' . $file,$dst . '/' . $file);
//             }
//             else {
//                 copy($src . '/' . $file,$dst . '/' . $file);
//             }
//         }
//     }
//     closedir($dir);
// } 

function copyFileToTemp($file, $cache_file){
	// echo "copyFileToTemp:";
	// echo $file . " to ";
	// echo $cache_file . "\n";
	$curpath = dirname($cache_file);
	// echo $curpath . "\n";
	if(!file_exists($curpath)){
		mkdir($curpath, 0777, true);
	}
	return copy($file, $cache_file);
}

function encode($file, $cache_file, $work_path, &$compiled_info){
	$is_outdated = true;
	// echo '$file = ' . $file . "\n";
	$md5_value = md5_file($file);
	$shortname = preg_replace("/^.*scripts/", "\\scripts", $file);
	// if(preg_match("/config\.lua/", $file)){
	// 	echo '$file = ' . $file . "\n";
	// 	printf('$md5_value = ' . $md5_value . "\n");
	// 	printf('old md5_value = ' . $compiled_info[$shortname] . "\n");
	// }
	if($compiled_info[$shortname]){
		if ($md5_value == $compiled_info[$shortname]){
			// echo $md5_value . "\n";
			// echo $compiled_info[$file] . "\n";
			$is_outdated = false;
		}
	}
	if(!file_exists($cache_file)){
		$is_outdated = true;
	}
	if($is_outdated){
		$encoder = $work_path . '\\BinaryEncoder.exe';
		// echo $encoder . "\n";
		printf($shortname . " is recompiled\n");
		exec($encoder . ' ' . $file);
		$byfile = preg_replace("/\.lua/", ".bylua", $file);
		if(file_exists($byfile)){
			copyFileToTemp($byfile, $cache_file);
			rename($byfile, $file);
		}else{
			abort($file);
		}
		$compiled_info[$shortname] = $md5_value;
	}else{
		// $file_path = dirname($file);
		copy($cache_file, $file);
	}
}

$compile_path = $argv[1];

function encodePath($src, $work_path, &$compiled_info){
	$dir = opendir($src);
	while(false !== ( $file = readdir($dir)) ) {
		if (( $file != '.' ) && ( $file != '..' )) {
			$full_path_file = $src . '\\' . $file;
            if(is_dir($full_path_file)) {
            	encodePath($full_path_file, $work_path, $compiled_info);
            }else {
            	if(preg_match("/\.lua/", $full_path_file) && !preg_match("/\w*test\w*\.lua/", $full_path_file)){
            		if(preg_match("/scripts/", $full_path_file)){
						$cache_file = preg_replace("/^.*scripts/", "\\scripts", $full_path_file);
						$cache_file = preg_replace("/\.lua/", ".bylua", $cache_file);
						$folder_temp = $work_path . '\\.compiled.cache\\';
						$cache_file = $folder_temp . $cache_file;
						encode($full_path_file, $cache_file, $work_path, $compiled_info);
					}
            	}
            	else{
            		$shortname = preg_replace("/^.*scripts/", "\\scripts", $full_path_file);
            		if(preg_match("/debug\.log/", $full_path_file) || preg_match("/\w*test\w*\.lua/", $full_path_file)){
            			echo $shortname . " is deleted\n";
            			unlink($full_path_file);
            		}else{
            			echo $shortname . " is ignored\n";
            		}
            	}
            }
        }
	}
	closedir($dir);
}

encodePath($compile_path, $work_path, $compiled_info);

$str = serialize($compiled_info);
// echo $str . "\n";
file_put_contents($compiled_info_file, $str);