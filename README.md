# EnergiPris
Calculates the Norwegian net electricity cost. Description and usage in Norwegian:

EnergiPris er en powershellmodul som inneholder følgende kommando: Get-EnergiPris

Denne vil kalkulere nettopris inkl nettleie og strømstøtte basert på gjennomsnittsprisen så langt i måneden. Den vil også gjøre et pessimistisk estimat, om dagsprisen resten av måneden er veldig lav (utgangspunkt: 0,01 kr).

Hvis ikke annet er oppgitt, vil den gå ut i fra dagens dato og klokkeslett. Men dette kan overstyres med -Time -Dag og -MND.

Nettleie er hentet ut fra Elvia sine priser (Østlandet), men kan overstyres. Det er tatt hensyn til dag/natt/helg og redusert avgift i januar tom april.

Installasjon:

Last ned modulen, og kopier mappen EnergiPris inn en av Powershell modulmappene på din pc. De finner du ved å skrive $env:PSModulePath

Anbefaler: C:\Users\<dinbruker>\Documents\WindowsPowerShell\Modules

Evt. importer manuelt ved å skrive import-module og peke på EnergiPris.psm1 modulen.
