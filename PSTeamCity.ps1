$ErrorActionPreference = "Stop";

register PSUrl;
register PSColorWriter;

$script:serverUrl = Read-Prompt-Color -Green "PSTeamCity" -White "Please insert the server url for teamcity";

Set-UrlCredentialsFor $script:serverUrl;

function Trigger-TeamCityBuild {
	param(
		[parameter(Mandatory = $true)][string] $buildTypeId
	);
	
	Set-UrlContent "$script:serverUrl/httpAuth/action.html?add2Queue=$buildTypeId";	
}

function Get-TeamCityProjectStatus {
	param(
		[parameter(Mandatory = $true)][string[]]$projects,
		[Func[Object, bool]]$where = { param($item) -not($item.success); }
	);
	
	foreach($project in $projects) {
		[xml]$xml = Get-UrlContent "$script:serverUrl/httpAuth/app/rest/projects/$project";
		$buildTypes = $xml.project.buildTypes;
		
		$allBuilds = @();
		foreach ($build in $buildTypes.GetEnumerator()) {
			$allBuilds += @{ "item" = Get-TeamCityBuildStatus -buildTypeId $build.id; };
		}
		
		$allBuilds | Where-Object { $where.Invoke($_.item) };
	}
}

function Get-TeamCityBuildStatus
{
	param(
		[string] $buildTypeId
	);
	
   	[xml]$xml = Get-UrlContent $("$script:serverUrl/httpAuth/app/rest/buildTypes/id:$buildTypeId/builds/running:any");
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