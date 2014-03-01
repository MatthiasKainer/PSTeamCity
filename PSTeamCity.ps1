$ErrorActionPreference = "Stop";

register PSUrl;
register PSColorWriter;

$script:serverUrl = Read-Prompt-Color -Green "PSTeamCity" -White "Please insert the server url for teamcity";

Set-UrlCredentials;

function Get-TeamCityProjectStatus {
	param(
		[parameter(Mandatory = $true)][string]$project,
		[Func[Object, bool]]$where = { param($item) -not($item.success); }
	);
	
	[xml]$xml = Get-UrlContent "$script:serverUrl/httpAuth/app/rest/projects/$project";
	write-output-color -Green "PSTeamcity" -White "Project $($xml.project.name) loaded";
	$buildTypes = $xml.project.buildTypes;
	
	$allBuilds = @();
	foreach ($build in $buildTypes.GetEnumerator()) {
	    write-output-color -Green "PSTeamcity" -White "Build with id $($build.id)";
		$allBuilds += @{ "item" = Get-TeamCityBuildStatus -buildTypeId $build.id; };
	}
	
	$allBuilds | Where-Object { $where.Invoke($_.item) };
}

function Get-TeamCityBuildStatus
{
	param(
		[string] $buildTypeId
	);
	
   	[xml]$xml = Get-UrlContent $("$script:serverUrl/httpAuth/app/rest/buildTypes/id:$buildTypeId/builds/running:any");
	write-output-color -Green "PSTeamcity" -White "Build with status $($xml.build.status) and state $($xml.build.state)";
	return @{ 
		"success" = $xml.build.status -eq "SUCCESS";
		"running" = $xml.build.state -eq "running";
		"message" = "$($xml.build.buildType.name)";
	};
}

function Set-TeamCityUrl {
	param(
		[parameter(Mandatory = $true)]
		[string]$url
	);
	
	$script:serverUrl = $url;
}