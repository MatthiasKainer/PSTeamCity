PSTeamCity
==========

Powershell Tools to get the teamcity build status

## Usage

Get all successful builds in project

> Get-TeamCityProjectStatus -project mybuild -where { param($item) $item.success }

Get all running builds in project

> Get-TeamCityProjectStatus -project mybuild -where { param($item) $item.running }
