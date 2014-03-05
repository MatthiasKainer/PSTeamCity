PSTeamCity
==========

Powershell Tools to get the teamcity build status for a project, and trigger a new build

## Usage


Trigger a new build

> Trigger-TeamCityBuild -buildTypeId buildtypeid

Get all successful builds in project

> Get-TeamCityProjectStatus -project mybuild -where { param($item) $item.success }

Get all running builds in project

> Get-TeamCityProjectStatus -project mybuild -where { param($item) $item.running }
