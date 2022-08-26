# Remote-Desktop
`desktop-files` contains files that are copied to the 'desktop' to provide information on the icons as well
as any other information such as how the xfce4 panel should look.

`French` contains configuration and translation files necessary for the i18n of remote desktop. `mo-files` contains translations
for the applications, while `Firefox` and `vscode` require extra installations and configuration (ie not set by ENV variables)

`qgis-2022.gpg.key` is used by qgis.sh to aid in installing qgis, this key expires on Aug 8, 2023 and will need to be rotated ex. https://github.com/StatCan/aaw-kubeflow-containers/pull/378

`start-remote-desktop.sh` a more custom version of `start-custom.sh` as it also sets 
the other ENV variables of `LC_ALL` and `LANGUAGE` and modifies the vscode json file to set the preferred locale.
