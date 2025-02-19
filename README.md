# Power BI Automation Toolkit

Automation toolkit for Power BI deployment and maintenance using PowerShell and REST APIs.

## Features
- Template-based Power BI file generation
- Multi-client deployment automation
- Data source connection management
- DAX measure updates across multiple files
- Configuration management

## Prerequisites
- Power BI Desktop
- Visual Studio Code
- PowerShell 7.0 or higher
- Power BI Management Module

## Setup
1. Clone this repository
2. Install required PowerShell modules:
   ```powershell
   Install-Module -Name MicrosoftPowerBIMgmt
   ```
3. Configure your client settings in `config/clients.json`
4. Place your Power BI template in `templates/`

## Usage
See documentation in `docs/` for detailed usage instructions.