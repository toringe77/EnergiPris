Function Get-EnergiPris
{
    <#
        .SYNOPSIS
        Regner ut netto pris per kWh.
        .DESCRIPTION
        Funksjonen vil regne ut netto pris inkl. nettleie og strømstøtte (Netto totalpris). Den vil også beregne hva som er grensen for når du faktisk får penger for å bruke strøm (Nullnivå (Pessimistisk)). Det er også en del andre tall for den som er intressert. Funksjonen vil hente foreløpig gjennomsnittspris fra web, med mindre man spesifiserer dette manuelt. Denne prisen blir cachet og den henter kun data på nytt på en ny dag for å hindre hamring av websiden. Man kan spesifisere region, og også time, dag, måned og år.
        
        MERK: Prisene og avgiftene vil variere, så denne funksjonen er ferskvare.
        .PARAMETER Pris
        Timespris du vil basere deg på.
        .PARAMETER GjennomsnittsPris
        (Foreløpig) månedlig gjennomsnittspris
        .PARAMETER Region
        Velg region.
        .PARAMETER Offline
        Ikke hent månedlig gjennomsnittspris fra web, selv om Gjennomsnittspris ikke er satt.
        .PARAMETER LavestePris
        Laveste mulige pris på strømbørsen (Satt til 0.01 kr). Denne brukes til å sette dagsprisen for resten av dagene i måneden, om den skulle bli veldig lav.
        .PARAMETER IgnoreNettleie
        Utelat nettleie fra prisen.
        .PARAMETER TekstResultat
        Skriv ut resultatet i tekst.
        .PARAMETER NettleieDag
        Nettleie dagtid 2022
        .PARAMETER NettleieNatt
        Nettleie kveldstid og helg 2022
        .PARAMETER NettleieDagRedusert
        Nettleie dagtid, januar til april 2023 (redusert avgift)
        .PARAMETER NettleieNattRedusert
        Nettleie kveldstid og helg, januar til april 2023 (redusert avgift)
        .PARAMETER Prosent
        Strømstøtteprosenten. For tiden 90%.
        .PARAMETER Grense
        Nedre grense for strømstøtten. 0,7 kr i 2022 eksl. mva.
        .PARAMETER MND
        Overstyre måned (1-12)
        .PARAMETER Dag
        Overstyre dag (1-31)
        .PARAMETER Anno
        Overstyre år.
        .PARAMETER Time
        Overstyre time på dagen. 
        .INPUTS
        Ingen
        .OUTPUTS
        Powershell objekt med priser i NOK.
        .EXAMPLE
        PS> Get-EnergiPris -Pris 1.4819

        Gjennomsnittspris                     : 1,4
        Strømstøtte                           : 0,4725
        Reell strømstøtteprosent              : 99,49
        Reell totalprosent                    : 35,00
        Nettleie                              : 0,2904
        Netto strømpris                       : 0,8774
        Netto totalpris                       : 1,1678
        Nullnivå                              : 0,1821
        Gjennomsnittspris Pessimistisk        : 0,6377
        Strømstøtte Pessimistisk              : 0
        Reell strømstøtteprosent Pessimistisk : 0
        Reell totalprosent Pessimistisk       : 0
        Netto strømpris Pessimistisk          : 1,3499
        Netto totalpris Pessimistisk          : 1,6403
        Nullnivpå Pessimistisk                : -0,2904
        Region                                : NO1 Øst-Norge


        .EXAMPLE
        PS> Get-EnergiPris -GjennomsnittsPris 3.6629 -Pris 1.4819
        
        Gjennomsnittspris                     : 3,6629
        Strømstøtte                           : 2,50911
        Reell strømstøtteprosent              : 528,34
        Reell totalprosent                    : 185,87
        Nettleie                              : 0,2904
        Netto strømpris                       : -1,15921
        Netto totalpris                       : -0,86881
        Nullnivå                              : 2,21871
        Gjennomsnittspris Pessimistisk        : 1,6597
        Strømstøtte Pessimistisk              : 0,70623
        Reell strømstøtteprosent Pessimistisk : 148,71
        Reell totalprosent Pessimistisk       : 52,32
        Netto strømpris Pessimistisk          : 0,64367
        Netto totalpris Pessimistisk          : 0,93407
        Nullnivpå Pessimistisk                : 0,41583
        Region                                : Gjennomsnittspris manuelt satt.

        .EXAMPLE
        PS> Get-EnergiPris Get-EnergiPris 1.3499 -GjennomsnittsPris 3.6629 -Dag 24 -Time 6 

        Gjennomsnittspris                     : 3,6629
        Strømstøtte                           : 2,50911
        Reell strømstøtteprosent              : 528,34
        Reell totalprosent                    : 185,87
        Nettleie                              : 0,2904
        Netto strømpris                       : -1,15921
        Netto totalpris                       : -0,86881
        Nullnivå                              : 2,21871
        Gjennomsnittspris Pessimistisk        : 2,8381
        Strømstøtte Pessimistisk              : 1,76679
        Reell strømstøtteprosent Pessimistisk : 372,03
        Reell totalprosent Pessimistisk       : 130,88
        Netto strømpris Pessimistisk          : -0,41689
        Netto totalpris Pessimistisk          : -0,12649
        Nullnivpå Pessimistisk                : 1,47639
        Region                                : Gjennomsnittspris manuelt satt.

        .EXAMPLE
        PS> Get-EnergiPris 1.3499 -LavestePris 4               

        Gjennomsnittspris                     : 1,4
        Strømstøtte                           : 0,4725
        Reell strømstøtteprosent              : 99,49
        Reell totalprosent                    : 35,00
        Nettleie                              : 0,2904
        Netto strømpris                       : 0,8774
        Netto totalpris                       : 1,1678
        Nullnivå                              : 0,1821
        Gjennomsnittspris Pessimistisk        : 2,8258
        Strømstøtte Pessimistisk              : 1,75572
        Reell strømstøtteprosent Pessimistisk : 369,70
        Reell totalprosent Pessimistisk       : 130,06
        Netto strømpris Pessimistisk          : -0,40582
        Netto totalpris Pessimistisk          : -0,11542
        Nullnivpå Pessimistisk                : 1,46532
        Region                                : NO1 Øst-Norge
  
        .EXAMPLE
        PS> Get-EnergiPris -Pris 3.5 -LavestePris 4 -TekstResultat

        Gir resultatet i tekst.
        .LINK
        Most Recent Version: https://github.com/toringe77/EnergiPris
        .Link
        Prices are based data from Gudbrandsdal Energi: https://www.ge.no/timepriser-spotpris-no1
    #>


    [cmdletbinding()]
    param(
        [Parameter(Position=0)]
        [Alias("Brutto","BruttoPris")]
        [decimal]
        $Pris = 0,
        [Alias("AveragePrice")]
        [decimal]
        $GjennomsnittsPris,
        [ValidateSet("NO1","NO2","NO3","NO4","NO5")]
        [string]
        $Region = "NO1",
        [switch]
        $Offline,
        [decimal]
        $LavestePris = 0.01,
        [switch]
        $IgnoreNettleie,
        [switch]
        $TekstResultat,
        [decimal]
        $NettleieDag = 0.4355,
        [decimal]
        $NettleieNatt = 0.3730,
        [decimal]
        $NettleieDagRedusert = 0.3520,
        [decimal]
        $NettleieNattRedusert = 0.2895,
        [decimal]
        $Prosent = 90,
        [decimal]
        $Grense = 0.70,
        [Alias("Month","Måned")]
        [int]
        $MND = (get-date).Month,
        [int]
        $Dag = (Get-Date).Day,
        [Alias("År","Year")]
        [string]
        $Anno = (Get-Date).Year,
        [Alias("Hour")]
        [int]
        $Time = (get-date).Hour
    )
    Begin
    {
    }
    Process
    {
        $cacheFile = "$($env:temp)\energipriscache$($Region).txt"
        if (-not $Gjennomsnittspris)
        {
            # Gjennomsnittspris is set automatically.
            switch ($Region)
            {
                "NO1" { $RegionTekst = "NO1 Øst-Norge" }
                "NO2" { $RegionTekst = "NO2 Sør-Norge" }
                "NO3" { $RegionTekst = "NO3 Midt-Norge" }
                "NO4" { $RegionTekst = "NO4 Nord-Norge" }
                "NO5" { $RegionTekst = "NO5 Vest-Norge" }
            }
            
            if (Test-Path $cacheFile )
            {
                $fileDate = [datetime](get-childitem $cacheFile | Select-Object -ExpandProperty LastWriteTime ) | get-date -Format "ddMMyyyy"
                if ($fileDate -eq (get-date -format "ddMMyyyy"))
                {
                    $GjennomsnittsPris = (get-content $cacheFile) / 100
                }
                else 
                {
                    $GjennomsnittsPris = $null
                }
            }
            if (-not ($GjennomsnittsPris) -and -not ($Offline))
            {
                Write-Warning "Henter priser fra https://elwin.ge.no/prishistorikk_$($Region)/PrisDiagram_.html"
                $webReq = Invoke-WebRequest https://elwin.ge.no/prishistorikk/PrisDiagram_$($Region).html -UseBasicParsing -DisableKeepAlive -ErrorAction Stop
                $webReqMatches = $webReq.content | select-string "Snittpris hittil denne m.ned: <b>(.{1,4})<\/b>"
                $GjennomsnittsPrisOre = $webReqMatches.matches.groups[1].value
                $GjennomsnittsPrisOre | Out-File $cacheFile
                $GjennomsnittsPris = $GjennomsnittsPrisOre / 100
            }
        }
        else 
        {
            $RegionTekst = "Gjennomsnittspris manuelt satt."
        }
        
        
        if (-not $GjennomsnittsPris)
        {
            Write-host "Trenger Gjennomsnittspris. Kunne ikke hente fra cache eller fra web."
            Return
        }
        if ( -not $IgnoreNettleie )
        {
            $Ukedag = ( Get-date -Day $Dag -Month $MND -Year $Anno ).DayOfWeek
            if ( $Ukedag -eq "Saturday" -or $Ukedag -eq "Sunday" -or $Ukedag -eq "Lørdag" -or $Ukedag -eq "Søndag" )
            {
                $nattHelg = $true
            }
            elseif ( $hour -lt 6 -or $hour -gt 22 )
            {
                $nattHelg = $true
            } 
            else
            {
                $nattHelg = $false
            }
            if ( $MND -ge 1 -and $MND -le 4 -and $nattHelg)
            {
                $nettLeie = $NettleieNattRedusert
            }
            elseif ( $MND -ge 1 -and $MND -le 4 -and -not $nattHelg)
            {
                $nettLeie = $NettleieDagRedusert
            }
            elseif ( -not ($MND -ge 1 -and $MND -le 4) -and $nattHelg)
            {
                $nettLeie = $NettleieNatt
            }
            else
            {
                $nettLeie = $NettleieDag
            }
        }
        else
        {
            $nettLeie = 0
        }
        # Calculate cost based on current average.
        $supportNetto =  ($GjennomsnittsPris - ( $Grense * 1.25 ) ) * $Prosent / 100
        if ( $supportNetto -lt 0 ) { $supportNetto = 0 }
        $stromPris = $pris - $supportNetto
        $nettoPris = $stromPris + $nettLeie
        $grenseverdi = $supportNetto - $nettLeie
        
        # Calculate what the actual % is
        $tempReellPris = ($Pris - ( $Grense * 1.25 ) )
        if ($tempReellPris -lt 0)
        {
            $reellProsent = $null
        }
        else 
        {
            $reellProsent =  [math]::round(($supportNetto / $tempReellPris * 100),2)
        }
        if ( $pris -gt 0)
        {
            $reellTotalProsent = [math]::round(((1-($stromPris/$pris)) * 100),2)
        }
        else 
        {
            $reellTotalProsent = $null
        }
        
        # Calculate Last day of month and days left of month
        $lastDayOfMonth = ((Get-date -Day 1 -Month $MND ).AddMonths(1).AddDays(-1)).Day
        $numDaysLeft = $lastDayOfMonth - $Dag

        # Calculate average based on "worst case scenario" 
        $pessimistiskGjennomsnitt = [math]::round( (( $GjennomsnittsPris * $Dag + $numDaysLeft * $LavestePris ) / $lastDayOfMonth ),4 )
        $pessimistiskSupportNetto =  ($pessimistiskGjennomsnitt - ( $Grense * 1.25 ) ) * $Prosent / 100
        if ( $pessimistiskSupportNetto -lt 0 ) { $pessimistiskSupportNetto = 0 }
        $pessimistiskStromPris = $pris - $pessimistiskSupportNetto
        $pessimistiskGrenseverdi = $pessimistiskSupportNetto - $nettLeie
        $pessimistiskNettoPris = $pris - $pessimistiskGrenseverdi

        # Calculate the worst case scenario actual % support
        if ($tempReellPris -lt 0)
        {
            $pessimistiskReellProsent =  $null
        }
        else {
            $pessimistiskReellProsent =  [math]::round(($pessimistiskSupportNetto / $tempReellPris * 100),2)
        }
        if ($pris -gt 0)
        {
            $pessimistiskReellTotalProsent = [math]::round(((1-($pessimistiskStromPris / $pris)) * 100),2) 
        }
        else 
        {
            $pessimistiskReellTotalProsent = $null
        }
        if ($TekstResultat)
        {
            if (-not $reellProsent)
            {
                $reellTekst = ""
            }
            else 
            {
                $reellTekst = "vil da i realiteten være $($reellProsent)%, og "
            }
            if ($supportNetto -gt 0)
            {
                $stotteTekst = "støtter staten med $supportNetto kr/kWh. Strømstøtten $($reellTekst)tilsvarer $($reellTotalProsent)% av prisen."

            }
            else 
            {
                $stotteTekst = "vil ikke staten betale ut noe da strømstøtten bortfaller."
            }
            if ($pessimistiskReellProsent -gt 0)
            {
                $pessimistiskStottetekst = "vil i realiteten bli $($pessimistiskReellProsent)%, og "

            }
            else 
            {
                $pessimistiskStottetekst = ""
            }
            if ($pessimistiskSupportNetto -gt 0)
            {
                $pessimistiskTekst = "og strømstøtten $pessimistiskSupportNetto kWh. Strømstøtten $($pessimistiskStottetekst)tilsvarer $($pessimistiskReellTotalProsent)% av strømprisen."
            }
            else 
            {
               $pessimistiskTekst = "men strømstøtten bortfaller."
            }

            "Med en pris på $Pris kr/kWh og månedlig gjennomsnittspris $GjennomsnittsPris kr/kWh, $stotteTekst Hvis dagsprisen blir $LavestePris kr/kWh resten av måneden ($numDaysLeft dager), blir gjennomsnittet $pessimistiskGjennomsnitt kr/kWh, $pessimistiskTekst Netto pris vil bli $nettoPris kr/kWh med dagens gjennomsnittspris. $pessimistiskNettoPris kr/kWh hvis dagsprisen resten av måneden blir $LavestePris kr/kWh. En tjener penger når prisen er under $grenseverdi kr/kWh med dagens gjennomsnitt, og $pessimistiskGrenseverdi kr/kWh, hvis dagsprisen resten av måneden blir $LavestePris kr/kWh."
        }
        else 
        {
            [pscustomobject]@{
                'Gjennomsnittspris' = $GjennomsnittsPris
                'Strømstøtte' = $supportNetto
                'Nettleie' = $nettLeie
                'Nullnivå' = $grenseverdi
                'Netto strømpris' = $stromPris
                'Reell strømstøtteprosent' = $reellProsent
                'Reell totalprosent' = $reellTotalProsent
                'Netto totalpris' = $nettoPris
                'Gjennomsnittspris Pessimistisk' = $pessimistiskGjennomsnitt
                'Strømstøtte Pessimistisk' = $pessimistiskSupportNetto
                'Netto strømpris Pessimistisk' = $pessimistiskStromPris
                'Reell strømstøtteprosent Pessimistisk' = $pessimistiskReellProsent
                'Reell totalprosent Pessimistisk' = $pessimistiskReellTotalProsent
                'Nullnivå Pessimistisk' = $pessimistiskGrenseverdi
                'Netto totalpris Pessimistisk' = $pessimistiskNettoPris
                'Region' = $RegionTekst
            } | Select-Object 'Gjennomsnittspris','Strømstøtte','Reell strømstøtteprosent','Reell totalprosent','Nettleie','Netto strømpris','Netto totalpris','Nullnivå','Gjennomsnittspris Pessimistisk','Strømstøtte Pessimistisk','Reell strømstøtteprosent Pessimistisk','Reell totalprosent Pessimistisk','Netto strømpris Pessimistisk','Netto totalpris Pessimistisk','Nullnivå Pessimistisk','Region'
        }
    }
    End
    {

    }
}