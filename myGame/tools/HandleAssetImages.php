<?php

$file_seperator = '\\';

function collectImages($dir, &$map){
	$file_seperator = $GLOBALS['file_seperator'];
	if(file_exists($dir)){
		$list = array_diff(scandir($dir), array('.', '..'));
		foreach ($list as $value){
			$fullname = $dir . $file_seperator . $value;
			if(is_dir($fullname)){
				collectImages($fullname, $map);
			}else{
				if ($map[$value] != null){
					echo "warning! the name " . $value . " is dupicated\n";
					echo $dir . "\n";
					echo $map[$value] . "\n";
					$map[$value] = "NULL FLAG";// dont set it null
					//$map[$value] = $fullname;// dont remove the name
				}else{
					$map[$value] = $fullname;
				}
				// echo $dir . $value . "\n";
			}
		}
	}
}

function collectImageTable($dir, &$map){
	$file_seperator = $GLOBALS['file_seperator'];
	$atlas_manager = $dir .  $file_seperator . "atlasManager.lua";
	if(file_exists($atlas_manager)){
		$str = file_get_contents($atlas_manager);
		$lines = explode("\n", $str);
		$start = false;
		$files = array();
		for($i = 0; $i < count($lines); $i++){
			if($start){
				if(preg_match("/}/", $lines[$i]) == 1){
					break;
				}
				// echo $lines[$i] . "\n";
				$matches = array();
				if(preg_match("/\s*[a-z0-9A-Z]+\s*=\s*require\(\"view\.atlas\.(.+)\"\)/", $lines[$i], $matches) == 1){
					if(preg_match("/^\s*--/", $lines[$i]) == 0){
						// echo $matches[1] . "\n";
						array_push($files, $matches[1]);
					}
				}
			}else{
				if(preg_match("/s_atlasConfig/", $lines[$i]) == 1){
					$start = true;
				}
			}
		}
		foreach($files as $value){
			$fullname = $dir .  $file_seperator . $value . ".lua";
			if(file_exists($fullname)){
				$str = file_get_contents($fullname);
				$lines = explode("\n", $str);
				for($i = 0; $i < count($lines); $i++){
					$matches = array();
					if(preg_match("/\[\"(.+)\"\]/", $lines[$i], $matches) == 1){
						$map[$matches[1]] = 1;
					}
				}
			}
		}
	}

}

function handleImages(&$fileMap, &$atlasMap){
	foreach ($atlasMap as $key => $value) {
		if($fileMap[$key] && $fileMap[$key] != "NULL FLAG"){
			echo $fileMap[$key] . " is deleted!\n";
			unlink($fileMap[$key]);
		}
	}
}

$image_path = $argv[1];
$map =  array();
collectImages($image_path, $map);
$atlasMap = array();
$atlas_path = $argv[2] . $file_seperator . "view" . $file_seperator . "atlas";
collectImageTable($atlas_path, $atlasMap);
// var_dump($atlasMap);
handleImages($map, $atlasMap);
