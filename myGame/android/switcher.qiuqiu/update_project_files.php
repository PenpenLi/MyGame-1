<?php

$mainFile = "../proj/app/src/main/java/com/boyaa/gaple/Game.java";
// $mainFile = "Game2.java";

// $mainContent = str_replace("import com.boyaa.gaple.R;", "", $mainContent);
// $mainContent = str_replace("import com.boyaa.gaple.qiuqiu.R;", "", $mainContent);


function fixJavaImport($mainFile){
	$mainContent = file_get_contents($mainFile);
	$lines = explode("\n", $mainContent);
	$index = 0;
	while ($index < count($lines)) {
		$line = $lines[$index];
		if(preg_match("/import com.boyaa.gaple.R;/", $line)){
			array_splice($lines, $index, 1);
			continue;
		}
		if(preg_match("/import com.boyaa.gaple.qiuqiu.R;/", $line)){
			array_splice($lines, $index, 1);
			continue;
		}
		$index = $index + 1;
	}
	array_splice( $lines, 1, 0, array( "import com.boyaa.gaple.qiuqiu.R;\r" ) );
	file_put_contents($mainFile, implode("\n",$lines));
}

// fixJavaImport("../proj/app/src/main/java/com/boyaa/gaple/Game.java");
// fixJavaImport("../proj/app/src/main/java/com/boyaa/gaple/utils/head/SaveHeadImage.java");
// fixJavaImport("../proj/app/src/main/java/com/boyaa/gaple/utils/head/FeedbackPicture.java");
// fixJavaImport("../proj/app/src/main/java/com/boyaa/google/gcm/GCMListenerService.java");
// fixJavaImport("../proj/app/src/main/java/com/boyaa/google/gcm/RegistrationIntentService.java");
// fixJavaImport("../proj/app/src/main/java/com/boyaa/gaple/AppStartDialog.java");
// fixJavaImport("../proj/app/src/main/java/com/boyaa/gaple/AppStartDialog.java");

function fixLuaProjChannelId($mainFile){
	$mainContent = file_get_contents($mainFile);
	$lines = explode("\n", $mainContent);
	$index = 0;
	$isChanged = false;
	while ($index < count($lines)) {
		$line = $lines[$index];
		if(preg_match("/GameConfig.ROOT_CGI_SID/", $line)){
			array_splice($lines, $index, 1, array( "GameConfig.ROOT_CGI_SID          = \"2\"\r" ));
			$isChanged = true;
			break;
		}
		$index = $index + 1;
	}
	if($isChanged){
		file_put_contents($mainFile, implode("\n",$lines));
	}
	return $isChanged;
}

$ret = fixLuaProjChannelId("../../runtime/Resource/scripts/gameConfig.lua");
if($ret){
	print("Change GameConfig.ROOT_CGI_SID in gameConfig.lua!\n");
}else{
	print("Fail to change GameConfig.ROOT_CGI_SID in gameConfig.lua!\n");
}