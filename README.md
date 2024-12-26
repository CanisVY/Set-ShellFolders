Created for \u\Ramog on Reddit.

This function sets user ShellFolders in registry. Use the csv in the repo to ensure you are following the expected format of the script and the user registry settings.

To run this without importing to your profile:
Import-Module "PathToModule\Set-ShellFolders.Ps1"
Set-ShellFolders -Path "PathToFile\import.csv" -Verbose # Verbose will show you everything it's doing as it does it.
